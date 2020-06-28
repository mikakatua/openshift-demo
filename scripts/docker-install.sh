#!/bin/bash

# Install Docker

sudo yum install -y docker-1.13.1

sudo bash -c "cat > /etc/sysconfig/docker-storage-setup" <<!
DEVS=/dev/sdb
VG=docker-vg
!

sudo docker-storage-setup

sudo systemctl enable --now docker
