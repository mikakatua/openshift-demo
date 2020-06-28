#!/bin/bash

EXTERNAL_IP=$(curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip")

# Setup ansible inventory
INVENTORY="$(dirname $(readlink -f $0))/../config/ansible-hosts"

# Run the RPM-based Installer
git clone -b release-3.11 https://github.com/openshift/openshift-ansible

export ANSIBLE_HOST_KEY_CHECKING=False
# Override DNS variables
EXTRA_VARS="-e openshift_master_cluster_public_hostname=$EXTERNAL_IP.nip.io -e openshift_master_default_subdomain=apps.$EXTERNAL_IP.nip.io"
ansible-playbook -i $INVENTORY $EXTRA_VARS ~/openshift-ansible/playbooks/prerequisites.yml
[ $? -eq 0 ] && ansible-playbook -i $INVENTORY $EXTRA_VARS ~/openshift-ansible/playbooks/deploy_cluster.yml

# Uninstall OKD cluster
#ansible-playbook -i $INVENTORY ~/openshift-ansible/playbooks/adhoc/uninstall.yml
