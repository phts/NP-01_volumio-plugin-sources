#!/bin/bash
set -e

peppymeterpath=/data/plugins/user_interface/peppymeterbasic/BasicPeppyMeter
spath=/data/plugins/user_interface/peppymeterbasic
customfolder=/data/INTERNAL/PeppyMeterBasic/Templates
mkdir -p $customfolder
chmod 777 -R $customfolder
echo "Installing peppyalsa plugin dependencies"
#cp $spath/peppymeter.service.tar /
#		cd /
#		sudo tar -xvf peppymeter.service.tar
#		rm /peppymeter.service.tar
#
#

sudo apt-get update

echo "cloning peppymeter repo"
git clone --depth=1 --branch=master https://github.com/phts/NP-01_vu-meter.git $peppymeterpath || true
cd $peppymeterpath
git config user.email "volumio@volumio.com"
git config user.name "volumio"
git stash || true
git pull origin master
git stash pop || true
cd -
sudo chown -R volumio "$spath" "$customfolder"
sudo chgrp -R volumio "$spath" "$customfolder"
echo "installing apt packages"

sudo apt-get -y install python3-pygame python3-pip python3-dev libjpeg-dev zlib1g-dev
##echo "Installing peppyalsa plugin if needed"

ARCH="$(arch)"
PLUGIN_PATH="/data/plugins/user_interface/peppymeterbasic"
ALSA_BASE_PATH="${PLUGIN_PATH}/alsa-lib"

cleanup_exit_err() {
    rm -rf "${PLUGIN_PATH}"
    exit -1
}

# Check if ARCH is set
if [[ -z "$ARCH" ]]; then
    echo "ARCH variable is not set. Please set it to your system architecture."
    cleanup_exit_err
fi

# Determine the correct PEPPY_ALSA_PATH based on ARCH
case "$ARCH" in
"armv6l" | "armv7l" | "aarch64")
    PEPPY_ALSA_PATH="${ALSA_BASE_PATH}/armhf"

    cat >/etc/systemd/system/peppymeterbasic.service <<EOC
[Unit]
Description=peppymeterbasic Daemon
After=syslog.target
[Service]
Type=simple
WorkingDirectory=/data/plugins/user_interface/peppymeterbasic
ExecStart=/data/plugins/user_interface/peppymeterbasic/startpeppymeterbasic.sh
Restart=no
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=volumio
User=volumio
Group=volumio
TimeoutSec=1
[Install]
WantedBy=multi-user.target
EOC
    ;;
"x86_64")
    PEPPY_ALSA_PATH="${ALSA_BASE_PATH}/x86_64"

    cat >/etc/systemd/system/peppymeterbasic.service <<EOC
[Unit]
Description=peppymeterbasic Daemon
After=syslog.target
[Service]
Type=simple
WorkingDirectory=/data/plugins/user_interface/peppymeterbasic
ExecStart=/data/plugins/user_interface/peppymeterbasic/startpeppymeterbasic.sh
Restart=no
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=volumio
User=root
Group=root
TimeoutSec=1
[Install]
WantedBy=multi-user.target
EOC
    ;;
*)
    echo "Unknown arch: ${ARCH}. Installation cannot proceed."
    cleanup_exit_err
    ;;
esac

sudo systemctl daemon-reload

# Create the symbolic links
ln -sfn "${PEPPY_ALSA_PATH}/libpeppyalsa.so.0.0.0" "${ALSA_BASE_PATH}/libpeppyalsa.so"
ln -sfn "${PEPPY_ALSA_PATH}/libpeppyalsa.so.0.0.0" "${ALSA_BASE_PATH}/libpeppyalsa.so.0"

# Output the link creation command for verification
echo "Linked ${PEPPY_ALSA_PATH}/libpeppyalsa.so.0.0.0 to ${ALSA_BASE_PATH}/libpeppyalsa.so"
echo "Linked ${PEPPY_ALSA_PATH}/libpeppyalsa.so.0.0.0 to ${ALSA_BASE_PATH}/libpeppyalsa.so.0"

pip3 install Pillow
sudo chmod +x /data/plugins/user_interface/peppymeterbasic/startpeppymeterbasic.sh
#required to end the plugin install
echo "plugininstallend"
