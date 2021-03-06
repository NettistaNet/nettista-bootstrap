# Create a basic cluster for Kubernetes
These scripts integrate and document the creation and preparation of base-infrastructure at Hetzner Cloud for a Kubernetes setup.

## Preparation steps

Execute the following steps to create the cluster and prepare it.

### Manual preparation 
1. Create folders `<clusterbase>/repos`
   
   `mkdir -p <clusterbase>/repos`
2. Clone repository to `<clusterbase>/repos/`

   `git clone ...  <clusterbase>/repos/`
3. Change do directory `<clusterbase>/repos/nettista-bootstrap`
   
   `cd clusterbase/repos/nettista-bootstrap`
4. Install prequisites 
    ```bash
    sudo pip install -r ./client_requirements.txt
    sudo pip install -r ../kubernetes/requirements.txt
    ```

### Generate keys
Execute script to generate ssh-key pair. This keypair will be used to access the virtual-servers. 

The script expects the cluster-name as parameter. 

You could also use an existing pair of keys or generate the key manually. If you choose to do so you need to copy the pair of keys to `<clusterbase>/clusters/<clustername>/keys/{node.key,node.key.pub}`

```bash
./nettista-gen-keys.sh <clustername>
```

### Download and prepare tools
Exexute script to download necessary tools like terraform. 

The tools will be downloaded to `<clusterbase>\tools`

```bash
./nettista-dl-tools.sh
```

## Terraform - Creation of the base-infrastructure
Execute script `nettista-tf.sh` to execute the actual terraform script. Provide the following parameters:

1. <clustername> - Name of the cluster 
2. <api-token> - API-Token for Hetzner Cloud

The terraform-script is located in repository `https://github.com/NettistaNet/nettista-terraform.git` and will be cloned / pulled by the script. 

```bash
./nettista-tf.sh --cluster-name <clustername> --token <api-token>
```

:information_source: By default the values from terraform values-file are used.

* node_count - Number of servers / default is 5
* node_image - OS image / default is ubuntu-18.04
* node_type - type of virtual-server / default: cx21
* node_location - location of nodes / default: nbg1

If you prefer to override one of these variables append `--var "<key>=<value>"` to the above script parameter-list.

## Ansible - Configuration of the base-infrastructure

Execute script `nettista-gen-inv.sh` to generate ansible-inventories for [Kubespray](https://kubespray.io) and the preparation of the base-infrastructure.

Prerequisite is that Kubespray is available in `../kubespray`.

```bash
# Cloning of the Kubespray repository
git clone -C ../kubespray https://github.com/kubernetes-sigs/kubespray.git
# Checkout a specific release-tag
git checkout <tag>
# Create ansible inventories
./nettista-gen-inv.sh \
--cluster-name <clustername> \
--token <hetzner-api-token> \
--backup-url <webdav-backup-url> \
--backup-mount-location <backup-mount-location> \ 
--backup-user <backup-user> \
--backup-password <backup-password>
```
Now everything is prepared to start ansible. 

```bash
# Execute ansible-roles
sudo ansible-playbook \
-e 'host_key_checking=False' \
-e 'ansible_python_interpreter=/usr/bin/python3' \
-i ../../clusters/<clustername>/inventories/bootstrap/hosts.ini \
--user=root --private-key=../../clusters/<clustername>/keys/node.key \
--become \
bootstrap.yml
```