#!/bin/bash
# This script must be run after provisioning the infrastructure with:
# terraform apply

MY_HOST=$(terraform output | grep public_ip | tr -d ' ' | cut -f2 -d=)
SSH_KEY="ssh-certs/id_rsa"
TMP_DIR="/tmp/openshift-demo"

ssh-keygen -f ~/.ssh/known_hosts -R "$MY_HOST"

ssh -t -i $SSH_KEY -o StrictHostKeyChecking=no ansible@$MY_HOST mkdir $TMP_DIR
scp -pri $SSH_KEY config scripts ansible@$MY_HOST:$TMP_DIR/

ssh -t -i $SSH_KEY ansible@$MY_HOST $TMP_DIR/scripts/host-prep.sh
ssh -t -i $SSH_KEY ansible@$MY_HOST $TMP_DIR/scripts/docker-install.sh
ssh -t -i $SSH_KEY ansible@$MY_HOST $TMP_DIR/scripts/openshift-install.sh

echo -e "\nOpenshift console address:"
echo "https://$MY_HOST.nip.io:8443/console"
