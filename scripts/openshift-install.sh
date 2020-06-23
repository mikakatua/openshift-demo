#!/bin/bash

# Setup ansible inventory
INVENTORY="$(dirname $(readlink -f $0))/../config/ansible-hosts"

# Run the RPM-based Installer
git clone -b release-3.11 https://github.com/openshift/openshift-ansible

export ANSIBLE_HOST_KEY_CHECKING=False
ansible-playbook -i $INVENTORY ~/openshift-ansible/playbooks/prerequisites.yml
[ $? -eq 0 ] && ansible-playbook -i $INVENTORY ~/openshift-ansible/playbooks/deploy_cluster.yml

# Uninstall OKD cluster
#ansible-playbook -i $INVENTORY ~/openshift-ansible/playbooks/adhoc/uninstall.yml
