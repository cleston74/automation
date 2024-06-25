#! /bin/bash
#######################################################################################################################################
# Program .....: restart.sh
# Version .....: 1.0
# Description .: Script for restart KUBERNETES servers
# Created .....: 07/Feb/2023
# Updated .....: 
#######################################################################################################################################

set +x
clear
functionBanner()
{
    clear
    echo   "+--------------------------------------------------------------+"
    echo   "|                                                              |"
    printf "|$(tput bold) %-60s $(tput sgr0)|\n" "$@"
    echo   "|                                                              |"
    echo   "+--------------------------------------------------------------+"
}

functionBanner "Restarting environment KUBERNETES" 
sleep 5

functionBanner "Restarting Server BRSPAPPCP01"
ssh -i /root/.ssh/ansible_automacao root@brspappcp01 init 6 &> /dev/null
functionBanner "Restarting Server BRSPAPPCP02"
ssh -i /root/.ssh/ansible_automacao root@brspappcp02 init 6 &> /dev/null
functionBanner "Restarting Server BRSPAPPWK01"
ssh -i /root/.ssh/ansible_automacao root@brspappwk01 init 6 &> /dev/null
functionBanner "Restarting Server BRSPAPPWK02"
ssh -i /root/.ssh/ansible_automacao root@brspappwk02 init 6 &> /dev/null
functionBanner "Restarting Server BRSPAPPHA01"
ssh -i /root/.ssh/ansible_automacao root@brspappha01 init 6 &> /dev/null

