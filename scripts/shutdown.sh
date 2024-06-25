#! /bin/bash
#######################################################################################################################################
# Program .....: shutdown.sh
# Version .....: 1.0
# Description .: Script for shutdown KUBERNETES servers
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

functionBanner "Shutdown environment KUBERNETES"
sleep 5

functionBanner "Shutdown Server BRSPAPPCP01"
ssh -i /root/.ssh/ansible_automacao root@brspappcp01 init 0 &> /dev/null
functionBanner "Shutdown Server BRSPAPPCP02"
ssh -i /root/.ssh/ansible_automacao root@brspappcp02 init 0 &> /dev/null
functionBanner "Shutdown Server BRSPAPPCP03"
ssh -i /root/.ssh/ansible_automacao root@brspappcp03 init 0 &> /dev/null
functionBanner "Shutdown Server BRSPAPPWK01"
ssh -i /root/.ssh/ansible_automacao root@brspappwk01 init 0 &> /dev/null
functionBanner "Shutdown Server BRSPAPPWK02"
ssh -i /root/.ssh/ansible_automacao root@brspappwk02 init 0 &> /dev/null
functionBanner "Shutdown Server BRSPAPPHA01"
ssh -i /root/.ssh/ansible_automacao root@brspappha01 init 0 &> /dev/null

