#!/bin/bash
#
# (c) Copyright 2020 Sascha Retter, All Rights Reserved

PARAMS=""
VERSION=0.1.0

# Determine information
this_path=$(readlink -f $0)
dir_name=`dirname ${this_path}`
myname=`basename ${this_path}`

function usage() {
   echo "
     usage: $myname [options]

     --------------------------------------------------------------------------------
     This script is used to generate ansible-inventories to prepare servers and 
     use kubespray to setup Kubernetes.
  
     The inventories are created in:
      ../../clusters/<cluster-name>/inventories/{boostrap,kubespray}
     --------------------------------------------------------------------------------
     
     Options:
     --help                   optional     Print this help message
     -n / --cluster-name      mandatory    Name of the cluster
     --token                  mandatory    Hetzner cloud api-token
     --backup-url             mandatory    URL of a webdav location
     --backup-mount-location  mandatory    Mount point of backup-space
     --backup-user            mandatory    User for webdav location
     --backup-password        mandatory    Password for webdav location  
   "
   exit 1
}

while (("$#" )); do
  case "$1" in
    --help)
      usage
      exit 0
      ;;
    -n | --cluster-name)
      CLUSTER_NAME=$2
      shift 2
      ;;
    --token)
      TOKEN=$2
      shift 2
      ;;
    --backup-url)
      BACKUP_URL=$2
      shift 2
      ;; 
    --backup-mount-location)
      BACKUP_MOUNT=$2
      shift 2
      ;; 
    --backup-user)
      BACKUP_USER=$2
      shift 2
      ;; 
    --backup-password)
      BACKUP_PASSWORD=$2
      shift 2
      ;; 
    --var)
      TF_VARIABLES="${TF_VARIABLES} -var $2"
      shift 2
      ;;
    --) # end argument parsing
      shift
      break
      ;;
    -*|--*=) # unsupported flags
      echo "Error: unsupported flag $1" >&2
      usage
      exit 1
      ;;
    *) # positional arguments
      PARAMS="$PARAMS $1"
      shift
      ;;
  esac
done

# set positional arguments properly
eval set -- "$PARAMS"

# validate if mandatory params have been set
if [ -z ${TOKEN+x} ]; then usage; exit 0; fi;
if [ -z ${CLUSTER_NAME+x} ]; then usage; exit 0; fi;
if [ -z ${BACKUP_URL+x} ]; then usage; exit 0; fi;
if [ -z ${BACKUP_MOUNT+x} ]; then usage; exit 0; fi;
if [ -z ${BACKUP_PASSWORD+x} ]; then usage; exit 0; fi;
if [ -z ${BACKUP_USER+x} ]; then usage; exit 0; fi;

# Take off
echo -e \
"ICAgICAgICAgICAgICAgICAgICAgICBfICAgXyAgIF8gICAgIF8gICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgXyAgICAgICAgICAgIAogICAgICAgICAgICBfIF9fICAgX19ffCB8
X3wgfF8oXylfX198IHxfIF9fIF8gICAgICAgIF9fIF8gIF9fXyBfIF9fICAgICAgIChfKV8gX19f
XyAgIF9fCiAgICAgICAgICAgfCAnXyBcIC8gXyBcIF9ffCBfX3wgLyBfX3wgX18vIF9gIHxfX19f
XyAvIF9gIHwvIF8gXCAnXyBcIF9fX19ffCB8ICdfIFwgXCAvIC8KICAgICAgICAgICB8IHwgfCB8
ICBfXy8gfF98IHxffCBcX18gXCB8fCAoX3wgfF9fX19ffCAoX3wgfCAgX18vIHwgfCB8X19fX198
IHwgfCB8IFwgViAvIAogICAgICAgICAgIHxffCB8X3xcX19ffFxfX3xcX198X3xfX18vXF9fXF9f
LF98ICAgICAgXF9fLCB8XF9fX3xffCB8X3wgICAgIHxffF98IHxffFxfLyAgCiAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICB8X19fLyAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAK" | base64 --decode

export HCLOUD_TOKEN=$TOKEN

BACKUP_MOUNT=/backup

HCLOUD=../../tools/hcloud
CLUSTER_BASE_PATH=../../clusters/$CLUSTER_NAME
INVENTORY_BASE_PATH=$CLUSTER_BASE_PATH/inventories
KUBESPRAY_BASE_PATH=../kubespray

ACTIVE_CONTEXT=$($HCLOUD context active)

export OLD_IFS=$IFS
export IFS=$'\n'

SERVER_IP=$($HCLOUD server list -o noheader -o columns=ipv4)
INVENTORYIP=()
serverIndex=0

rm -rf $CLUSTER_BASE_PATH/inventories/*
mkdir -p $INVENTORY_BASE_PATH/bootstrap/host_vars
mkdir -p $INVENTORY_BASE_PATH/bootstrap/group_vars
cp bootstrap_all.yml $INVENTORY_BASE_PATH/bootstrap/group_vars/all.yml
echo "[vpn]" > $INVENTORY_BASE_PATH/bootstrap/hosts.ini

rm -rf $INVENTORY_BASE_PATH/kubespray/*
cp -rfp $KUBESPRAY_BASE_PATH/inventory/sample $INVENTORY_BASE_PATH/kubespray
export CONFIG_FILE=$INVENTORY_BASE_PATH/kubespray/hosts.yml 

for ip in $SERVER_IP; do
   serverIndex=$((serverIndex+1))
   echo "Add to $INVENTORYIP"
   INVENTORYIP+=("10.0.1.$serverIndex,$ip")
   echo $INVENTORYIP
   python3 $KUBESPRAY_BASE_PATH/contrib/inventory_builder/inventory.py "10.0.1.$serverIndex,$ip"
   echo $ip >> $INVENTORY_BASE_PATH/bootstrap/hosts.ini
   echo -e "---\nwireguard_address: 10.0.1.$serverIndex/24" > $INVENTORY_BASE_PATH/bootstrap/host_vars/$ip
   echo -e "PrivateKey: $(wg genkey | tee privatekey)" >> $INVENTORY_BASE_PATH/bootstrap/host_vars/$ip
   echo -e "wireguard_persistent_keepalive: '30'" >> $INVENTORY_BASE_PATH/bootstrap/host_vars/$ip
   echo -e "wireguard_endpoint: $ip" >> $INVENTORY_BASE_PATH/bootstrap/host_vars/$ip
done

sed -i "s#<backup-url>#$BACKUP_URL#" $INVENTORY_BASE_PATH/bootstrap/group_vars/all.yml
sed -i "s#<backup-mount>#$BACKUP_MOUNT#" $INVENTORY_BASE_PATH/bootstrap/group_vars/all.yml
sed -i "s/<backup-user>/$BACKUP_USER/" $INVENTORY_BASE_PATH/bootstrap/group_vars/all.yml
sed -i "s/<backup-password>/$BACKUP_PASSWORD/" $INVENTORY_BASE_PATH/bootstrap/group_vars/all.yml
sed -i 's/CONTEXT/'"$CLUSTER_NAME"'/' $INVENTORY_BASE_PATH/bootstrap/group_vars/all.yml
sed -i "s/helm_enabled: false/helm_enabled: true/" $INVENTORY_BASE_PATH/kubespray/group_vars/k8s-cluster/addons.yml
sed -i "s/# kubeconfig_localhost: false/kubeconfig_localhost: true/" $INVENTORY_BASE_PATH/kubespray/group_vars/k8s-cluster/k8s-cluster.yml
sed -i "s/# calico_mtu: 1500/calico_mtu: 1400/" $INVENTORY_BASE_PATH/kubespray/group_vars/k8s-cluster/k8s-net-calico.yml
echo "calico_ipv4pool_ipip: Always" >> $INVENTORY_BASE_PATH/kubespray/group_vars/k8s-cluster/k8s-net-calico.yml

serverIndex=0
for ip in $SERVER_IP; do
   serverIndex=$((serverIndex+1))
   echo "Replacing access_ip $ip with 10.0.1.$serverIndex"
   sed -i "0,/access_ip: $ip/s//access_ip: 10.0.1.$serverIndex/" $INVENTORY_BASE_PATH/kubespray/hosts.yml
done