#!/bin/bash

# Install Docker

yum install -y docker-1.13.1

cat <<! > /etc/sysconfig/docker-storage-setup
DEVS=/dev/sdb
VG=docker-vg
!

docker-storage-setup

systemctl enable --now docker
