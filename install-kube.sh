#! /bin/bash
#######################################################################################################################################
# Program .....: install-kube.sh
# Version .....: 1.0
# Description .: Script for install Kubernetes Cluster (01 Control Plane / 02 Workers)
# Created .....: 07/Feb/2023
# Updated .....: 03/Jun/2024 - Fix repo Kubernetes
#######################################################################################################################################
set +x
clear

functionBanner()
{
  echo   ""
  echo   "╔════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╗"
  echo   "║                                                                                                                        ║"
  printf "║$(tput bold) %-118s $(tput sgr0)║\n" "$@"
  echo   "║                                                                                                                        ║"
  echo   "╚════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╝"
  echo ""
}


echo "      █████╗  ██████╗███╗   ███╗███████╗    ██████╗ ██████╗  ██████╗ "
echo "     ██╔══██╗██╔════╝████╗ ████║██╔════╝   ██╔═══██╗██╔══██╗██╔════╝ "
echo "     ███████║██║     ██╔████╔██║█████╗     ██║   ██║██████╔╝██║  ███╗"
echo "     ██╔══██║██║     ██║╚██╔╝██║██╔══╝     ██║   ██║██╔══██╗██║   ██║"
echo "     ██║  ██║╚██████╗██║ ╚═╝ ██║███████╗██╗╚██████╔╝██║  ██║╚██████╔╝"
echo "     ╚═╝  ╚═╝ ╚═════╝╚═╝     ╚═╝╚══════╝╚═╝ ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ "
echo "                                             Kubernetes - Single Node"
sleep 5

# Tests
hosts=(brspappcp01 brspappwk01 brspappwk02)
functionBanner "Connectivity test with all Servers ..."
for host in "${hosts[@]}"; do
  ping -c 3 "$host" &> /dev/null
  if [ $? -eq 0 ]; then
    echo "$host ping OK."
  else
    echo "$host unable to ping."
    echo "One or more Servers were not reached, check /etc/hosts settings or other settings."
    exit 1
  fi
done
sleep 3

functionBanner "Install cli HELM/KUBECTL on ANSIBLE server"
/usr/bin/which kubectl &> /dev/null
if [ $? = 1 ]; then # not install
  cd /var/tmp || exit
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" &> /dev/null
  if [ -f "./kubectl" ]; then
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    echo "kubectl installed."
    yes | rm -f ./kubectl &> /dev/null
  fi
fi
/usr/bin/which helm &> /dev/null
if [ $? = 1 ]; then # not install
  curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash &> /dev/null
fi
/usr/bin/which ansible &> /dev/null
if [ $? = 1 ]; then # not install
  yes | apt install ansible -y &> /dev/null
fi
sleep 3

functionBanner "Setting ANSIBLE server"
cp -Rap /storage/automation/configs/hosts /etc/hosts
sleep 3

functionBanner "Copying essential pre-installation scripts ..."
/usr/bin/ansible-playbook -i /storage/automation/ansible-files/kban-inventory-file /storage/automation/ansible-files/01-kban-copy-scripts.yaml
sleep 3

functionBanner "Installing Chrony on Servers ..."
/usr/bin/ansible-playbook -i /storage/automation/ansible-files/kban-inventory-file /storage/automation/ansible-files/02-kban-install-chrony.yaml
sleep 3

functionBanner "Copying hosts file to Servers ..."
/usr/bin/ansible-playbook -i /storage/automation/ansible-files/kban-inventory-file /storage/automation/ansible-files/03-kban-copy-hosts.yaml
sleep 3

functionBanner "Installing Kernel and ContainerD modules ..."
/usr/bin/ansible-playbook -i /storage/automation/ansible-files/kban-inventory-file /storage/automation/ansible-files/04-kban-install-containerd-modkernel.yaml
sleep 3

functionBanner "Installing kubeadm, kubectl e kubelet ..."
/usr/bin/ansible-playbook -i /storage/automation/ansible-files/kban-inventory-file /storage/automation/ansible-files/05-kban-install-kube-ctl-adm-let.yaml
sleep 3

functionBanner "Initializing the Kubernetes Cluster ..."
/usr/bin/ansible-playbook -i /storage/automation/ansible-files/kban-inventory-file /storage/automation/ansible-files/06-kban-start-k8s.yaml

functionBanner "Copying Cluster config file to Ansible server ..."
mkdir -p /root/.kube/ &> /dev/null
/usr/bin/scp -i /root/.ssh/ansible_automacao root@brspappcp01:/etc/kubernetes/admin.conf /root/.kube/config &> /dev/null
if [ $? -eq 1 ]; then
  echo "Unable to copy file /etc/kubernetes/admin.conf."
  echo "Without it, it will not be possible to access the Cluster or complete the installation.."
  exit 1
else
  functionBanner "Exporting KUBECONFIG..."
  export KUBECONFIG=~/.kube/config
  sleep 3

  functionBanner "Testing Connectivity to the Kubernetes Cluster ..."
  /usr/local/bin/kubectl get nodes
  sleep 3
  if [ $? -eq 1 ]; then
    echo "Unable to test connectivity to the Cluster"
    exit 1
  else
    functionBanner "Changing Worker Node Labels ..."
    /usr/local/bin/kubectl label node brspappwk01 node-role.kubernetes.io/worker-node= &> /dev/null
    /usr/local/bin/kubectl label node brspappwk02 node-role.kubernetes.io/worker-node= &> /dev/null
    /usr/local/bin/kubectl get nodes

    functionBanner "Installing the MetalLB on Kubernetes Cluster ..."
    /usr/local/bin/helm repo add metallb https://metallb.github.io/metallb
    /usr/local/bin/helm install metallb metallb/metallb

    functionBanner "Installing the Ingress Controller on Kubernetes Cluster ..."
    helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
    helm install ingress-nginx ingress-nginx/ingress-nginx

    functionBanner "Installing Longhorn on Kubernetes Cluster ..."
    /usr/local/bin/helm repo add longhorn https://charts.longhorn.io &> /dev/null
    /usr/local/bin/helm repo update &> /dev/null
    /usr/local/bin/helm install longhorn longhorn/longhorn --namespace longhorn-system --create-namespace --values /storage/automation/kubernetes-files/longhorn-values.yaml

    functionBanner "Installing Rancher on Kubernetes Cluster ..."
    helm repo add rancher-stable https://releases.rancher.com/server-charts/stable
    helm install rancher rancher-stable/rancher \
      --create-namespace \
      --namespace cattle-system \
      --set hostname=rancher.cleiton.me \
      --set ingress.tls.source=secret \
      --set bootstrapPassword=admin
    kubectl --namespace cattle-system rollout status deploy/rancher
    kubectl --namespace cattle-system get deploy rancher
    /usr/local/bin/kubectl apply -f /storage/automation/kubernetes-files/rancher-service.yaml

    functionBanner "Installing the MetalLB Pool IP on Kubernetes Cluster ..."
    /usr/local/bin/kubectl apply -f /storage/automation/kubernetes-files/metallb/metallb-values.yaml

    functionBanner "Waiting for inicialization pods ..."
    found=false
    echo "1" > /var/tmp/total.log
    while [ "$found" = false ]
    do
      while read line
      do
        num=$(echo $line | awk '{print $1}')
        if [ "$num" -gt 40 ]; then
          functionBanner "KUBERNETES cluster is ready !!!"
          found=true
          break
        fi
        clear
        echo ""
        echo " Total PODs ready: $line of 40 "
        echo ""
      done < /var/tmp/total.log
      if [ "$found" = false ]; then
        /usr/local/bin/kubectl get po -A | egrep "Running|Completed" | wc -l > /var/tmp/total.log
        /usr/local/bin/kubectl get po -A -o wide | egrep -v "Running|Completed"
        sleep 5
      fi
    done

    functionBanner "Setting file /etc/hosts"
    rancherIP=$(kubectl get service --namespace cattle-system | grep rancher | awk '{print $4}' | grep -v none)
    rancherDNS=$(cat /etc/hosts | grep rancher.acme.org)
    longhornIP=$(kubectl get service --namespace longhorn-system | grep longhorn-frontend | awk '{print $4}')
    longhornDNS=$(cat /etc/hosts | grep longhorn.acme.org)
    [[ $longhornDNS = 0 ]] && {
      actualLonghorn=$( grep -E "^[0-9].*longhorn.*" /etc/hosts | awk '{print $1}' )
      actualRancher=$( grep -E "^[0-9].*rancher.*" /etc/hosts | awk '{print $1}' )
      sed -i "s/${actualLonghorn}/${longhornIP}/g" /etc/hosts
      sed -i "s/${actualRancher}/${rancherIP}/g" /etc/hosts
    } || {
      echo -e "$longhornIP\t longhorn.acme.org" >> /etc/hosts
      echo -e "$rancherIP\t rancher.acme.org" >> /etc/hosts
    }

    ###
    # Join New ControlPlane if high availability
    # functionBanner "Generating ingress file for new Control Planes ..."
    # /usr/bin/ansible-playbook -i /storage/automation/ansible-files/kban-inventory-file /storage/automation/ansible-files/08-kban-gen-join-cplanes.yaml
    # sleep 3

    functionBanner "Your Kubernetes Cluster can be accessed through Ansible Server."                             \
                   ""                                                                                            \
                   "Testing Access"                                                                              \
                   "kubectl cluster-info"                                                                        \
                   ""                                                                                            \
                   "Longhorn Access"                                                                             \
                   "http://longhorn.acme.org/"                                                                   \
                   ""                                                                                            \
                   "*** Note: It is necessary to configure the /etc/hosts file if access is from another server" \
                   ""                                                                                            \
                   "Official documentation."                                                                     \
                   "https://longhorn.io/docs/"                                                                   \
                   ""                                                                                            \
                   "Rancher Access"                                                                              \
                   "https://rancher.acme.org/"                                                                   \
                   ""                                                                                            \
                   "*** Note: Initial password: admin"                                                           \
                   ""                                                                                            \
                   "To test your Cluster, run the command below from Ansible Server"                             \
                   "One volume will be dynamically created in Longhorn and mongodb deployed"                     \
                   "kubectl apply -f /storage/automation/exemplos/example-deploy-svc-pvc-ns_mongo-mongo.yaml"    \
                   ""                                                                                            \
                   "To check if the deployment was successful"                                                   \
                   "kubectl get all -n mongo -o wide"                                                            \

  fi
fi
