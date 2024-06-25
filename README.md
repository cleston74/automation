# Projeto de Instalação Automática de um Cluster Kubernetes

  Este projeto destina-se a um Laboratório de testes e não deve ser utilizado em produção.
  
  A versão do Kubernetes que será instalada: 1.26.5. 
  
  Se necessário instalar outra versão, edite o arquivo kban-variables.yaml localizado em /storage/automation/ansible-files
  
É necessário ter o VirtualBox instalado (Pode-se utilizar outros virtualizadores, porém, achei mais simples com esse);
-	Necessário adicionar uma nova rede no VirtualBox.
  
  ![image](https://github.com/cleston74/automacao/assets/42645665/31d5feca-45a9-49fd-bf9e-a74a34dde30e) ![image](https://github.com/cleston74/automacao/assets/42645665/d9fa8645-a30b-4873-89de-692eaa73a6a9)

- IP fixo em todos os servidores, conforme diagrama abaixo;

  ![image](https://github.com/cleston74/automacao/assets/42645665/e63f8b5e-21c6-450c-9099-c342b0870ddb)

  *** O IP 192.168.0.X é a sua rede 

# Descrição dos Servidores:

  - Servidor: BRSPAPPFW01 \
  Sistema Operacional: FreeBSD \
  CPU: 1 vCPU \
  Memória: 1 GB \
  HD: 10GB \
  IP1: 192.168.99.254 \
  IP2: 192.168.0.10 [Configuração DHCP de sua rede] \
  Papel: Este servidor tem a característica de prover papel de Firewall, Gateway e DNS do Laboratório. \
  Placa de rede 1: configurada como DHCP com saída para internet \
  Placa de rede 2: configurada com IP fixo no barramento 192.168.99.X


- Servidor: BRSPAPPAN01 \
Sistema Operacional: Ubuntu Server 22.04 \
CPU: 1 vCPU \
Memória: 1GB \
HD: 10 GB \
IP: 192.168.99.199 \
Papel: Este servidor será usado para realizar toda configuração e ajustes nos Servidores para a correta instalação do Kubernetes.

- Servidor: BRSPAPPCP01 \
Sistema Operacional: Ubuntu Server 22.04 \
CPU: 4 vCPU \
Memória: 4 GB \
HD: 60 GB \
IP: 192.168.99.200 \
Papel: Servidor de Control Plane

- Servidor: BRSPAPPWK01 \
Sistema Operacional: Ubuntu Server 22.04 \
CPU: 4 vCPU \
Memória: 3 GB \
HD: 60 GB \
IP: 192.168.99.205 \
Papel: Servidor worker-node

- Servidor: BRSPAPPWK02
Sistema Operacional: Ubuntu Server 22.04 \
CPU: 4 vCPU \
Memória: 3 GB \
HD: 60 GB \
IP: 192.168.99.206 \
Papel: Servidor worker-node

- Acesso SSH configurado com chave \
  Para gerar sua chave SSH, execute o comando abaixo em seu Servidor ansible (BRSPAPPAN01) \
  *** Salve com o nome de “ansible_automacao” no diretório /root/.ssh
  
      ssh-keygen -t rsa -b 2048
  

- Para copiar sua chave SSH para os demais servidores, execute o comando abaixo: \
  *** Altere XXXX para o nome correto do Servidor
  
      ssh-copy-id -i /root/.ssh/ansible_automacao.pub root@brspappXXXX
  

- Executar um primeiro acesso da máquina Ansible (BRSPAPPAN01) ao Control Plane (BRSPAPPCP01) e a cada Worker Node (BRSPAPPWK01 e BRSPAPPWK02). \
  *** Altere XXXX para o nome correto do Servidor
  
      ssh -i /root/.ssh/ansible_automacao root@brspappXXXX
  

- Defina o hostname de cada Servidor com o comando abaixo: \
  *** Altere XXXX para o nome correto do Servidor (vide diagrama)
  
      hostnamectl set-hostname brspappXXXX
  

- Defina o IP para cada Servidor editando o arquivo 00-installer-config.yaml (o nome pode variar de acordo com a versão do sistema operacional) que está no diretório /etc/netplan

      vim /etc/netplan/00-installer-config.yaml
  
  Ajustar de acordo com arquivo abaixo alterando IP quando necessário:

      # This is the network config written by 'subiquity'
      network:
        ethernets:
          enp0s3:
            addresses:
            - 192.168.99.200/24
            nameservers:
              addresses:
              - 192.168.99.254
              search:
              - acme.org
            routes:
            - to: default
              via: 192.168.99.254
        version: 2

  Execute o comando abaixo para saber se o arquivo de configuração está correto

      netplan try

   ![image](https://github.com/cleston74/automacao/assets/42645665/8efc3af4-ea2e-4ee9-9530-1491bbf36362) \
    Tecle [ENTER] se não ocorrer nenhum erro.


- Desabilite o swap editando o arquivo fstab \
  *** Reiniciar para que todas as alterações tenham efeito. \
  
  ![image](https://github.com/cleston74/automacao/assets/42645665/997042d7-50e4-4363-833c-0e6a6d38f6a8)


      vim /etc/fstab
 

- Executar um teste de conectividade para certificar que todas as máquinas tenham saída para internet, um simples “ping” já é o suficiente; \
  ![image](https://github.com/cleston74/automacao/assets/42645665/a7bee55f-76f1-4b5c-ad5a-04713facebc6)

- Esse laboratório utiliza Linux Ubuntu Server versão 22.04, onde o usuário root não vem habilitado por padrão para login remoto, logo, será necessário habilitar em todos os Servidores.

      sudo su -
      passwd

- Edite o arquivo sshd_config em /etc/ssh e faça a alteração abaixo: \
  de: PermitRootLogin #prohibit-password \
  para: PermitRootLogin yes

      vim /etc/ssh/sshd_config

-	Garantir que os Sistemas Operacionais estejam atualizados.

        apt update && apt -y upgrade && apt autoremove && apt autoclean

# Instalação
- De seu Servidor Ansible (BRSPAPPAN01), executar os comandos abaixo:
  
      mkdir -p /storage/
      cd /storage/
      git clone https://github.com/cleston74/automacao.git

- Copiar o conteúdo do arquivo /storage/automation/configs/hosts para o /etc/hosts

      cd /storage/automation
      chmod +x install-kube.sh
      time ./install-kube.sh

- Resumo da instalação
  
  ![image](https://github.com/cleston74/automacao/assets/42645665/692adf7c-6359-4227-be38-5de3d8f698a2)

  *** O tempo de instalação pode variar de acordo com sua internet e performance de seu laboratório.

- Longhorn

  ![image](https://github.com/cleston74/automacao/assets/42645665/b59d8249-86f9-4a46-876b-f36a746a7aa7)

- Kubernetes Dashboard

  ![image](https://github.com/cleston74/automacao/assets/42645665/0d844153-4712-475d-8e45-2d9a30e02235)

