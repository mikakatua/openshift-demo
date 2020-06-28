
# openshift-demo
This demo creates a Openshift cluster with 1 master and 2 nodes.

Login to your Google Cloud account. You will need to download a JSON file containing the API Keys for your service account. Copy this file to `gcp-credentials.json` in the root folder of the project.

Run the following commands to deploy the cluster:
```
terraform apply
./setup.sh
```

Your cluster will have a public hostname like **\<IP Address>.nip.io**

To delete all the GCP resources, run:
```
terraform destroy
```
