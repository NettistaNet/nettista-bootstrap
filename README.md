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
./nettista-gen-keys.sh 
```

### Ansible - Configuration of the base-infrastructure

#### Prepare inventory

Create the file `inventories/group_vars/all.yml` and use the below yaml as template.

```yaml
harden_linux_ufw_rules:
  - rule: allow
    to_port: 51820
    protocol: udp
  - rule: allow
    to_port: 22
    protocol: tcp

harden_linux_ufw_allow_networks:
  - "10.0.0.0/8"
  - "172.16.0.0/12"
  - "192.168.0.0/16"

harden_linux_ufw_defaults_user:
  "^DEFAULT_FORWARD_POLICY": 'DEFAULT_FORWARD_POLICY="ACCEPT"'

harden_linux_sysctl_settings_user:
  "net.ipv4.ip_forward": 1
  "net.ipv6.conf.default.forwarding": 1
  "net.ipv6.conf.all.forwarding": 1

harden_linux_root_password: your_encrypted_password_here
harden_linux_deploy_user: ansible
harden_linux_deploy_user_password: your_encrypted_password_here
harden_linux_deploy_user_home: /home/ansible
harden_linux_deploy_user_public_keys:
  - path_to_public_key

```

Create the file `inventories/hosts.ini` containing `[vpn]` and one line per host with the public IPs. 

Create a file per node `inventories/host_vars/<public ip>` containing:

```yaml
---
wireguard_address: internal_ip/24 
PrivateKey: $(wg genkey | tee privatekey)
wireguard_persistent_keepalive: '30'
wireguard_endpoint: public_ip
```

#### Retrieve roles
Retrieve needed roles.

```bash
ansible-galaxy install -r requirements.yml
```

#### Execute ansible
Now everything is prepared to start ansible. 

```bash
# Execute ansible-roles
sudo ansible-playbook \
-e 'host_key_checking=False' \
-e 'ansible_python_interpreter=/usr/bin/python3' \
-i inventories/hosts.ini \
--user=root --private-key=<path to private-key> \
--become \
bootstrap.yml
```
