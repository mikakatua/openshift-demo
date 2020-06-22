#!/bin/bash

# Setup ansible inventory

cp -f $1/config/ansible-hosts /etc/ansible/hosts

# Run the RPM-based Installer

git clone -b release-3.11 https://github.com/openshift/openshift-ansible

cd openshift-ansible

ansible-playbook playbooks/prerequisites.yml
ansible-playbook playbooks/deploy-cluster.yml

