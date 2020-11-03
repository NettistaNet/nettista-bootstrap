#!/bin/bash
#
# (c) Copyright 2020 Sascha Retter, All Rights Reserved

PARAMS=""
VERSION=0.2.0

# Determine information
this_path=$(readlink -f $0)
dir_name=`dirname ${this_path}`
myname=`basename ${this_path}`

function usage() {
   echo "
     usage: $myname [options]

     --------------------------------------------------------------------------------
     This script is used to generate a SSH key-pair.
  
     The keys are saved to ../../clusters/<cluster-name>/keys/{node.key,node.key.pub}
     --------------------------------------------------------------------------------
     
     Options:
     --help                   optional     Print this help message
   "
   exit 1
}

while (("$#" )); do
  case "$1" in
    --help)
      usage
      exit 0
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

PUBLIC_KEY=node.key.pub
PRIVATE_KEY=node.key

# Take off
echo -e \
"ICAgICAgICAgICAgICAgICAgICBfICAgXyAgIF8gICAgIF8gICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgXyAgICAgICAgICAgICAgICAgIAogICAgICAgICBfIF9fICAgX19ffCB8
X3wgfF8oXylfX198IHxfIF9fIF8gICAgICAgIF9fIF8gIF9fXyBfIF9fICAgICAgIHwgfCBfX19f
XyBfICAgXyBfX18gCiAgICAgICAgfCAnXyBcIC8gXyBcIF9ffCBfX3wgLyBfX3wgX18vIF9gIHxf
X19fXyAvIF9gIHwvIF8gXCAnXyBcIF9fX19ffCB8LyAvIF8gXCB8IHwgLyBfX3wKICAgICAgICB8
IHwgfCB8ICBfXy8gfF98IHxffCBcX18gXCB8fCAoX3wgfF9fX19ffCAoX3wgfCAgX18vIHwgfCB8
X19fX198ICAgPCAgX18vIHxffCBcX18gXAogICAgICAgIHxffCB8X3xcX19ffFxfX3xcX198X3xf
X18vXF9fXF9fLF98ICAgICAgXF9fLCB8XF9fX3xffCB8X3wgICAgIHxffFxfXF9fX3xcX18sIHxf
X18vCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICB8X19f
LyAgICAgICAgICAgICAgICAgICAgICAgICAgIHxfX18vICAgICAK" | base64 --decode

echo "====================================================================================================="
echo "= Generating ssh-keys ...                                                                           ="
echo "====================================================================================================="
if [[ -f "$PRIVATE_KEY" ]]; then
   echo "# Private key already exists ... skipping."
else
   ssh-keygen -t ed25519 -a 100 -f $PRIVATE_KEY -q -N ""
   echo "=> Keys created."
fi
