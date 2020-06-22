#!/bin/bash
MY_HOST=$(terraform output | grep public_ip | tr -d ' ' | cut -f2 -d=)
SSH_KEY="ssh-certs/id_rsa"
TMP_DIR="/tmp/openshift-demo"
ssh -i $SSH_KEY ansible@$MY_HOST mkdir $TMP_DIR
scp -pri $SSH_KEY config scripts ansible@$MY_HOST:$TMP_DIR/

ssh -i $SSH_KEY ansible@$MY_HOST sudo $TMP_DIR/scripts/host-prep.sh
ssh -i $SSH_KEY ansible@$MY_HOST sudo $TMP_DIR/scripts/docker-install.sh
ssh -i $SSH_KEY ansible@$MY_HOST sudo $TMP_DIR/scripts/openshift-install.sh $TMP_DIR
