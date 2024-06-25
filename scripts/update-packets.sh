#!/bin/bash
apt-mark hold kubeadm kubelet kubectl containerd
yes|apt update && yes|apt upgrade && yes|apt autoremove && yes|apt autoclean
