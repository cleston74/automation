#!/bin/bash
#---[ Execute command and save in variables ]
printJoinCommand=$(/usr/bin/kubeadm token create --print-join-command)
uploadCerts=$(/usr/bin/kubeadm init phase upload-certs --upload-certs | tail -1)
finalCommand="/usr/bin/$printJoinCommand --control-plane --certificate-key $uploadCerts"

#---[ Generate CP JOIN file ]
initialFile=$(echo "#!/bin/bash" > /var/tmp/controlplanejoin.sh)
generateFileJoin=$(echo $finalCommand >> /var/tmp/controlplanejoin.sh)
chmod a+x /var/tmp/controlplanejoin.sh

#---[ Generate WK JOIN file ]
initialFile=$(echo "#!/bin/bash" > /var/tmp/workernodejoin.sh)
generateFileJoin=$(echo $printJoinCommand >> /var/tmp/workernodejoin.sh)
chmod a+x /var/tmp/workernodejoin.sh
