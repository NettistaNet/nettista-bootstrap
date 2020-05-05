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
     This script is used to
     * clone, respectively pull a terraform-script-repository 
     * execute tf init, tf plan and tf apply
  
     The tf-state is saved to ../../clusters/<cluster-name>/tf/terraform.tfstate
     --------------------------------------------------------------------------------
     
     Options:
     --help                   optional     Print this help message
     -n / --cluster-name      mandatory    Name of the cluster
     --token                  mandatory    Hetzner cloud api-token
     --var                    optional     Override default variables \"<key>=<value>\"
   "
   exit 1
}

TF_VARIABLES=""

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

# Take off
echo -e \
"ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIF8gICBfICAgXyAgICAgXyAgICAg
ICAgICAgICAgXyAgICBfXyAKICAgICAgICAgICAgICAgICAgICAgICAgICBfIF9fICAgX19ffCB8
X3wgfF8oXylfX198IHxfIF9fIF8gICAgICB8IHxfIC8gX3wKICAgICAgICAgICAgICAgICAgICAg
ICAgIHwgJ18gXCAvIF8gXCBfX3wgX198IC8gX198IF9fLyBfYCB8X19fX198IF9ffCB8XyAKICAg
ICAgICAgICAgICAgICAgICAgICAgIHwgfCB8IHwgIF9fLyB8X3wgfF98IFxfXyBcIHx8IChffCB8
X19fX198IHxffCAgX3wKICAgICAgICAgICAgICAgICAgICAgICAgIHxffCB8X3xcX19ffFxfX3xc
X198X3xfX18vXF9fXF9fLF98ICAgICAgXF9ffF98ICAKICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAK" | base64 --decode

#Additional variables
REPOS_PATH=..
CLUSTER_BASE_PATH=../../clusters/$CLUSTER_NAME
PRIVATE_KEY=$CLUSTER_BASE_PATH/keys/node.key
PUBLIC_KEY=$PRIVATE_KEY.pub
TF_REPO_NAME=nettista-terraform
TF_REPO_URL=https://github.com/NettistaNet/$TF_REPO_NAME.git
TF=../../tools/terraform

echo "====================================================================================================="
echo "= Clone terraform repository                                                                        ="
echo "====================================================================================================="
#clone Repo nach $REPOS_PATH/terraform
if [[ -d "$REPOS_PATH/$TF_REPO_NAME" ]]; then
   echo "$REPOS_PATH/$TF_REPO_NAME exists."
   git -C $REPOS_PATH/nettista-terraform pull
else
  echo "Cloning $TF_REPO_URL."
  git clone $TF_REPO_URL $REPOS_PATH/$TF_REPO_NAME
fi

echo "====================================================================================================="
echo "= Provision resources using terraform ...                                                           ="
echo "====================================================================================================="
$TF init $REPOS_PATH/$TF_REPO_NAME

mkdir -p ../../clusters/$CLUSTER_NAME/tf

$TF plan -state "$CLUSTER_BASE_PATH/tf/terraform.tfstate" \
 -var "cluster_base_path=$CLUSTER_BASE_PATH" \
 -var "hcloud_token=$TOKEN" \
 -var "ssh_private_key=$PRIVATE_KEY" \
 -var "ssh_public_key=$PUBLIC_KEY" \
 ${TF_VARIABLES} \
 $REPOS_PATH/$TF_REPO_NAME

$TF apply -state "$CLUSTER_BASE_PATH/tf/terraform.tfstate" \
-var "cluster_base_path=$CLUSTER_BASE_PATH" \
-var "hcloud_token=$TOKEN" \
-var "ssh_private_key=$PRIVATE_KEY" \
-var "ssh_public_key=$PUBLIC_KEY" \
${TF_VARIABLES} \
$REPOS_PATH/$TF_REPO_NAME