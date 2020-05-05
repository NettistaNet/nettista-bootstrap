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
     This script is used to unprovision resources using terraform.
  
     The state from ../../clusters/<cluster-name>/tf/terraform.tfstate is used.
     --------------------------------------------------------------------------------
     
     Options:
     --help                   optional     Print this help message
     -n / --cluster-name      mandatory    Name of the cluster
     --token                  mandatory    Hetzner cloud api-token
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
    -c | --node-count)
      NODE_COUNT=$2
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
"ICAgICAgICAgICAgICAgIF8gICBfICAgXyAgICAgXyAgICAgICAgICAgICAgXyAgICBfXyAgICAg
ICAgICAgXyAgICAgICAgICAgXyAgICAgICAgICAgICAgICAgICAKICAgICBfIF9fICAgX19ffCB8
X3wgfF8oXylfX198IHxfIF9fIF8gICAgICB8IHxfIC8gX3wgICAgICAgX198IHwgX19fICBfX198
IHxfIF8gX18gX19fICBfICAgXyAKICAgIHwgJ18gXCAvIF8gXCBfX3wgX198IC8gX198IF9fLyBf
YCB8X19fX198IF9ffCB8XyBfX19fXyAvIF9gIHwvIF8gXC8gX198IF9ffCAnX18vIF8gXHwgfCB8
IHwKICAgIHwgfCB8IHwgIF9fLyB8X3wgfF98IFxfXyBcIHx8IChffCB8X19fX198IHxffCAgX3xf
X19fX3wgKF98IHwgIF9fL1xfXyBcIHxffCB8IHwgKF8pIHwgfF98IHwKICAgIHxffCB8X3xcX19f
fFxfX3xcX198X3xfX18vXF9fXF9fLF98ICAgICAgXF9ffF98ICAgICAgICBcX18sX3xcX19ffHxf
X18vXF9ffF98ICBcX19fLyBcX18sIHwKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICB8
X19fLyAK" | base64 --decode

TF=../../tools/terraform
CLUSTER_BASE_PATH=../../clusters/$CLUSTER_NAME
REPOS_PATH=../

echo "====================================================================================================="
echo "= Prepare resources using terraform ...                                                             ="
echo "====================================================================================================="
$TF destroy -state "$CLUSTER_BASE_PATH/tf/terraform.tfstate" -var "hcloud_token=$TOKEN" \
-var "cluster_base_path=$CLUSTER_BASE_PATH" $REPOS_PATH/nettista-terraform
rm -rf $CLUSTER_BASE_PATH/tf