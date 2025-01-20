#!/bin/bash
# K7ILO's HBlink3 Installer, V3

if [ "$EUID" -ne 0 ]; then
	echo ""
	echo " You must be root to run this script!! "
	exit 1
fi


# Global Parameters -------------------------------------------------------------------------------------------------
INSDIR=/opt
DEP="sudo curl git make build-essential libusb-1.0-0-dev python python3 python3-pip \
chkconfig git-core libi2c-dev i2c-tools lm-sensors python3-websockets python3-gpiozero \
python3-psutil python3-serial wget python3-dev python3-venv libffi-dev libssl-dev \
cargo pkg-config sed default-libmysqlclient-dev libmysqlclient-dev build-essential zip unzip \
python3-distutils python3-twisted python3-bitarray rrdtool openssl wavemon gcc g++ cmake \
libasound2-dev libudev-dev gpsd libgps-dev gpsd-clients gpsd-tools chrony conntrack \
apache2 php figlet ca-certificates gnupg lsb-release"


# Lets begin --------------------------------------------------------------------------------------------------------
clear
echo ""
echo "-----------------------------------------------------------"
echo " Downloading and installing the required dependencies .... "
echo "-----------------------------------------------------------"
sleep 2
apt update && apt install -y $DEP
apt autoremove && apt autoclean


echo ""
echo " Installing packages in the virtual environment .... "
python3 -m pip install pip setuptools
python3 -m pip install cryptography Twisted bitstring MarkupSafe bitarray configparser aprslib \
attrs wheel service_identity pyOpenSSL mysqlclient tinydb ansi2html mysql-connector-python pandas \
xlsxwriter cursor pynmea2 maidenhead flask folium mysql-connector resettabletimer setproctitle \
requests libscrc Pyro5
echo ""
echo " Disabling virtual environment .... "
deactivate
sleep 3


# Install and configure Rust
cd $INSDIR
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source $HOME/.cargo/env
rustup install 1.72.0
rustup default 1.72.0


/usr/bin/python3 -m pip install --upgrade pyOpenSSL
/usr/bin/python3 -m pip install --upgrade autobahn
/usr/bin/python3 -m pip install --upgrade jinja2
/usr/bin/python3 -m pip install --upgrade dmr-utils3
/usr/bin/python3 -m pip install --upgrade ansi2html
/usr/bin/python3 -m pip install --upgrade aprslib
/usr/bin/python3 -m pip install --upgrade tinydb
/usr/bin/python3 -m pip install --upgrade mysqlclient
/usr/bin/python3 -m pip install --upgrade setproctitle
/usr/bin/python3 -m pip install --upgrade pynmea2
/usr/bin/python3 -m pip install --upgrade maidenhead
/usr/bin/python3 -m pip install --upgrade Twisted
/usr/bin/python3 -m pip install --upgrade spyne
echo "Installation Complete."


####
bash -c "$(curl -fsSL https://github.com/k7ilo/HBLink3_Install/blob/main/hbl3.sh)"
