# Create necessary directories and clone repository
mkdir ${DATA_DIR}/NCT6687
mkdir -p /nct/lib/modules/${UNAME}
cd ${DATA_DIR}/NCT6687
git clone https://github.com/Fred78290/nct6687d
cd ${DATA_DIR}/NCT6687/nct*

# Patch Makefile and install the Kernel module to a temporary directory
echo -e 'obj-m += nct6687.o

all:
\tmake -C /lib/modules/$(shell uname -r)/build M=$(PWD) modules

install: all
\tmake -C /lib/modules/$(shell uname -r)/build M=$(PWD) modules_install

clean:
\tmake -C /lib/modules/$(shell uname -r)/build M=$(PWD) clean
' > ${DATA_DIR}/NCT6687/nct*/Makefile
make INSTALL_MOD_PATH=/nct install -j${CPU_COUNT}
cd /nct/lib/modules/${UNAME}/
rm /nct/lib/modules/${UNAME}/* 2>/dev/null
cd ${DATA_DIR}
mkdir -p /nct/usr/local/emhttp/plugins/nct6687-driver/images
wget -O /nct/usr/local/emhttp/plugins/nct6687-driver/images/nuvoton.png https://raw.githubusercontent.com/ich777/docker-templates/master/ich777/images/nuvoton.png

# Create Slackware package
PLUGIN_NAME="nct6687d"
BASE_DIR="/nct"
TMP_DIR="/tmp/${PLUGIN_NAME}_"$(echo $RANDOM)""
VERSION="$(date +'%Y.%m.%d')"

mkdir -p $TMP_DIR/$VERSION
cd $TMP_DIR/$VERSION
cp -R $BASE_DIR/* $TMP_DIR/$VERSION/
mkdir $TMP_DIR/$VERSION/install
tee $TMP_DIR/$VERSION/install/slack-desc <<EOF
       |-----handy-ruler------------------------------------------------------|
$PLUGIN_NAME: $PLUGIN_NAME
$PLUGIN_NAME:
$PLUGIN_NAME:
$PLUGIN_NAME: Custom $PLUGIN_NAME package for Unraid Kernel v${UNAME%%-*} by ich777
$PLUGIN_NAME: Source: https://github.com/Fred78290/nct6687d
$PLUGIN_NAME:
EOF
${DATA_DIR}/bzroot-extracted-$UNAME/sbin/makepkg -l n -c n $TMP_DIR/$TMP_DIR/$PLUGIN_NAME-plugin-$UNAME-1.txz
md5sum $TMP_DIR/$PLUGIN_NAME-plugin-$UNAME-1.txz | awk '{print $1}' > $TMP_DIR/$PLUGIN_NAME-plugin-$UNAME-1.txz.md5