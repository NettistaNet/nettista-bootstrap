# Prepare a basic cluster for Kubernetes
This playbook prepares a cluster of linux-nodes (debian-based) for Kubernetes.

## Preparation steps

Execute the following steps to create the cluster and prepare it.

### Manual preparation 
1. Clone repository
2. Change do directory `nettista-bootstrap`
3. Install prerequisites 
    ```bash
    sudo pip install -r ./requirements.txt
    ```

### Generate keys (optional)
This is an optional step. You could also use an existing keypair or generate the key manually. 

Execute script to generate ssh-key pair. The keypair is needed to use SSH public-/private-key authentication to access the linux-nodes.

The script expects the cluster-name as parameter. 

```bash
./nettista-gen-keys.sh <clustername>
```

### Ansible - Configuration of the base-infrastructure

#### Prepare inventory

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
#### Retrieve roles
Retrieve needed roles.

```bash
ansible-galaxy install -r requirements.yml
```

#### Execute ansible

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