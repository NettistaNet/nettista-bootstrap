#!/bin/bash
#
# (c) Copyright 2020 Sascha Retter, All Rights Reserved

VERSION=0.1.0

TOOLS_PATH=../../tools
HCLOUD_VERSION=v1.16.1
HCLOUD_DOWNLOAD_BASE_URL=https://github.com/hetznercloud/cli/releases/download/$HCLOUD_VERSION/
HCLOUD_ARCHIVE=hcloud-linux-amd64.tar.gz
TF_VERSION=0.12.21
TF_DOWNLOAD_BASE_URL=https://releases.hashicorp.com/terraform/$TF_VERSION/
TF_ARCHIVE=terraform_${TF_VERSION}_linux_amd64.zip
HCLOUD_TF_PROVIDER_VERSION=v1.1.0
HCLOUD_TF_PROVIDER_DOWNLOAD_BASE_URL=https://github.com/hetznercloud/terraform-provider-hcloud/releases/download/${HCLOUD_TF_PROVIDER_VERSION}/
HCLOUD_TF_PROVIDER_ARCHIVE=terraform-provider-hcloud_${HCLOUD_TF_PROVIDER_VERSION}_linux_amd64.zip
HELM_VERSION=v3.1.1
HELM_DOWNLOAD_BASE_URL=https://get.helm.sh/
HELM_ARCHIVE=helm-$HELM_VERSION-linux-amd64.tar.gz

# Take off
echo -e \
"ICAgICAgICAgICAgICAgICAgICAgICAgXyAgIF8gICBfICAgICBfICAgICAgICAgICAgICAgICAg
XyBfICAgICAgIF8gICAgICAgICAgICAgIF8gICAgIAogICAgICAgICAgICAgXyBfXyAgIF9fX3wg
fF98IHxfKF8pX19ffCB8XyBfXyBfICAgICAgICBfX3wgfCB8ICAgICB8IHxfIF9fXyAgIF9fXyB8
IHxfX18gCiAgICAgICAgICAgIHwgJ18gXCAvIF8gXCBfX3wgX198IC8gX198IF9fLyBfYCB8X19f
X18gLyBfYCB8IHxfX19fX3wgX18vIF8gXCAvIF8gXHwgLyBfX3wKICAgICAgICAgICAgfCB8IHwg
fCAgX18vIHxffCB8X3wgXF9fIFwgfHwgKF98IHxfX19fX3wgKF98IHwgfF9fX19ffCB8fCAoXykg
fCAoXykgfCBcX18gXAogICAgICAgICAgICB8X3wgfF98XF9fX3xcX198XF9ffF98X19fL1xfX1xf
XyxffCAgICAgIFxfXyxffF98ICAgICAgXF9fXF9fXy8gXF9fXy98X3xfX18vCiAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAK" | base64 --decode

echo "====================================================================================================="
echo "= Cleanup existing installation                                                                     ="
echo "====================================================================================================="
rm -rf $TOOLS_PATH
echo "=> Cleanup finished."

echo "====================================================================================================="
echo "= Downloading tools ...                                                                             ="
echo "====================================================================================================="
mkdir -p $TOOLS_PATH
(cd $TOOLS_PATH && curl -L -O $HCLOUD_DOWNLOAD_BASE_URL$HCLOUD_ARCHIVE)
(cd $TOOLS_PATH && curl -L -O $TF_DOWNLOAD_BASE_URL$TF_ARCHIVE)
(cd $TOOLS_PATH && curl -L -O $HELM_DOWNLOAD_BASE_URL$HELM_ARCHIVE)
(cd $TOOLS_PATH && curl -L -O $HCLOUD_TF_PROVIDER_DOWNLOAD_BASE_URL$HCLOUD_TF_PROVIDER_ARCHIVE)
echo "=> Tools downloaded to $TOOLS_PATH"

echo "====================================================================================================="
echo "= Extracting tools ...                                                                              ="
echo "====================================================================================================="
tar xvfz $TOOLS_PATH/$HCLOUD_ARCHIVE -C $TOOLS_PATH
unzip -o -u $TOOLS_PATH/$TF_ARCHIVE -d $TOOLS_PATH
tar xvfz $TOOLS_PATH/$HELM_ARCHIVE -C $TOOLS_PATH
unzip -o -u $TOOLS_PATH/$HCLOUD_TF_PROVIDER_ARCHIVE -d $TOOLS_PATH
echo "=> Extracted tools in $TOOLS_PATH"

echo "====================================================================================================="
echo "= Install HCLOUD TF Provider ...                                                                    ="
echo "====================================================================================================="
mkdir -p ~/.terraform.d/plugins/
mv $TOOLS_PATH/terraform-provider-hcloud ~/.terraform.d/plugins/