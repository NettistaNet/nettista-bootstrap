#!/bin/bash
#
# (c) Copyright 2020 Sascha Retter, All Rights Reserved


ROLES_PATH=./roles
WIREGUARD_ROLE_NAME=wireguard
HARDEN_LINUX_ROLE_NAME=harden-linux
HA_PROXY_ROLE_NAME=ha-proxylb
WEBDAV_CLIENT_ROLE_NAME=webdav-client

# Take off
echo -e \
"ICAgICAgICAgICAgICAgICAgICAgICBfICAgXyAgIF8gICAgIF8gICAgICAgICAgICAgICAgICBf
IF8gICAgICAgICAgICAgICAgIF8gICAgICAgICAgIAogICAgICAgICAgICBfIF9fICAgX19ffCB8
X3wgfF8oXylfX198IHxfIF9fIF8gICAgICAgIF9ffCB8IHwgICAgICBfIF9fIF9fXyB8IHwgX19f
ICBfX18gCiAgICAgICAgICAgfCAnXyBcIC8gXyBcIF9ffCBfX3wgLyBfX3wgX18vIF9gIHxfX19f
XyAvIF9gIHwgfF9fX19ffCAnX18vIF8gXHwgfC8gXyBcLyBfX3wKICAgICAgICAgICB8IHwgfCB8
ICBfXy8gfF98IHxffCBcX18gXCB8fCAoX3wgfF9fX19ffCAoX3wgfCB8X19fX198IHwgfCAoXykg
fCB8ICBfXy9cX18gXAogICAgICAgICAgIHxffCB8X3xcX19ffFxfX3xcX198X3xfX18vXF9fXF9f
LF98ICAgICAgXF9fLF98X3wgICAgIHxffCAgXF9fXy98X3xcX19ffHxfX18vCiAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAK" | base64 --decode

echo "====================================================================================================="
echo "= Retrieve ansible-roles from github ...                                                            ="
echo "====================================================================================================="
mkdir -p $ROLES_PATH
if [[ -d "$ROLES_PATH/$WIREGUARD_ROLE_NAME" ]]; then
   echo "$ROLES_PATH/$WIREGUARD_ROLE_NAME exists"
   git -C $ROLES_PATH/$WIREGUARD_ROLE_NAME pull
else
   git clone https://github.com/githubixx/ansible-role-wireguard.git $ROLES_PATH/$WIREGUARD_ROLE_NAME
fi
if [[ -d "$ROLES_PATH/$HARDEN_LINUX_ROLE_NAME" ]]; then
   echo "$ROLES_PATH/$HARDEN_LINUX_ROLE_NAME exists"
   git -C $ROLES_PATH/$HARDEN_LINUX_ROLE_NAME pull
else
   git clone https://github.com/githubixx/ansible-role-harden-linux.git $ROLES_PATH/$HARDEN_LINUX_ROLE_NAME 
fi
if [[ -d "$ROLES_PATH/$HA_PROXY_ROLE_NAME" ]]; then
   echo "$ROLES_PATH/$HA_PROXY_ROLE_NAME exists"
   git -C $ROLES_PATH/$HA_PROXY_ROLE_NAME pull
else
   git clone https://github.com/NettistaNet/ansible-role-ha-proxy.git $ROLES_PATH/$HA_PROXY_ROLE_NAME 
fi
if [[ -d "$ROLES_PATH/$WEBDAV_CLIENT_ROLE_NAME" ]]; then
   echo "$ROLES_PATH/$WEBDAV_CLIENT_ROLE_NAME exists"
   git -C $ROLES_PATH/$WEBDAV_CLIENT_ROLE_NAME pull
else
   git clone https://github.com/NettistaNet/ansible-role-webdav-client.git $ROLES_PATH/$WEBDAV_CLIENT_ROLE_NAME
fi


#Modifications
sed -i "s/root/$(whoami)/" $ROLES_PATH/$WIREGUARD_ROLE_NAME/defaults/main.yml
