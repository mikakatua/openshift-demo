#!/bin/bash

# Install Base Packages

sudo yum install -y wget git net-tools bind-utils yum-utils iptables-services bridge-utils bash-completion kexec-tools sos psacct

sudo yum install -y epel-release

sudo yum install -y ansible pyOpenSSL
