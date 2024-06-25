#!/bin/bash
clear
set +x

#---[ Global Variables ]
src=/storage/automation/scripts
dst=/tmp
serverPrefix="brspapp"

#---[ Copy Script Update Servers ]
echo "Copying script file"
scp -i /root/.ssh/ansible_automacao $src/update-packets.sh root@"$serverPrefix"cp01:$dst &> /dev/null
scp -i /root/.ssh/ansible_automacao $src/update-packets.sh root@"$serverPrefix"cp02:$dst &> /dev/null
scp -i /root/.ssh/ansible_automacao $src/update-packets.sh root@"$serverPrefix"wk01:$dst &> /dev/null
scp -i /root/.ssh/ansible_automacao $src/update-packets.sh root@"$serverPrefix"wk02:$dst &> /dev/null
scp -i /root/.ssh/ansible_automacao $src/update-packets.sh root@"$serverPrefix"ha01:$dst &> /dev/null

set -x
ssh -i /root/.ssh/ansible_automacao root@"$serverPrefix"cp01 $dst/update-packets.sh
ssh -i /root/.ssh/ansible_automacao root@"$serverPrefix"cp02 $dst/update-packets.sh
ssh -i /root/.ssh/ansible_automacao root@"$serverPrefix"wk01 $dst/update-packets.sh
ssh -i /root/.ssh/ansible_automacao root@"$serverPrefix"wk02 $dst/update-packets.sh
ssh -i /root/.ssh/ansible_automacao root@"$serverPrefix"ha01 $dst/update-packets.sh

