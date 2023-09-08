#!/bin/bash
# K7ILO's FDMR-Monitor Installer V1
#
#Lets begin-------------------------------------------------------------------------------------------------
if [ "$EUID" -ne 0 ];
then
echo ""
echo " You Must be root to run this script!! "
exit 1
fi
if [ ! -e "/etc/debian_version" ]
then
echo ""
echo " This script has been tested on NEWLY INSTALLED Debian 10 and 11 64-bit repo's only. "
echo " It is assumed you are doing the same. "
exit 0
fi

VERSION=$(sed 's/\..*//' /etc/debian_version)
INSDIR=/opt
HBMONDIR=$INSDIR/FDMR-Monitor
HBMONREPO=https://github.com/yuvelq/FDMR-Monitor.git
DEP="curl python3 python3-dev python3-pip libffi-dev libssl-dev sed apache2 php ca-certificates"

if [ $VERSION = 10 ];
then
echo " Debian 10 (Buster) is detected "
echo ""
echo "----------------------------------------------------------------------"
echo " Downloading and installing the required software & dependencies .... "
echo "----------------------------------------------------------------------"
sleep 2
apt update && apt install -y $DEP
apt autoremove && apt autoclean
echo ""
echo " Installing the Rust compilter.  Select default (1) when asked .... "
sleep 3
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source "$HOME/.cargo/env"
sleep 2

elif [ $VERSION = 11 ];
then
echo " Debian 11 (Bullseye) is detected "
echo ""
echo "----------------------------------------------------------------------"
echo " Downloading and installing the required software & dependencies .... "
echo "----------------------------------------------------------------------"
sleep 2
apt update && apt install -y $DEP
apt autoremove && apt autoclean
echo ""
echo " Installing the Rust compilter.  Select default (1) when asked .... "
sleep 3
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source "$HOME/.cargo/env"
sleep 2

else
echo "------------------------------------------------------------------------------------------"
echo " Operating system not supported! Please check your configuration or upgrade. Exiting .... "
echo "------------------------------------------------------------------------------------------"
exit 0
fi

echo ""
echo "----------------------------------------------------------------------------"
echo " Now lets download and configure the FDMR-Monitor Dashboard repository .... "
echo "----------------------------------------------------------------------------"
sleep 2
cd $INSDIR
git clone $HBMONREPO
cd $HBMONDIR
if [ -e monitor.py ]
then
echo ""
echo "--------------------------------------------------------------------"
echo " I can see we are in the FDMR-Monitor director. Let's continue .... "
echo "--------------------------------------------------------------------"
else
echo "------------------------------------------------------------------------------------------------ "
echo " It doesn't seem like you're in the FDMR-Monitor directory. Please see if you are.  Exiting .... "
echo "------------------------------------------------------------------------------------------------ "
exit 0
fi

echo "-----------------------------------------------------------------------------"
echo " Downloading and installing dependencies from the requirements.txt file .... "
echo "-----------------------------------------------------------------------------"
pip3 install -r requirements.txt
sleep 2
echo "--------------------------------------"
echo " Creating the configuratoin file .... "
echo "--------------------------------------"
cp fdmr-mon_SAMPLE.cfg fdmr-mon.cfg
chmod 644 fdmr-mon.cfg
sleep 2

echo ""
echo "---------------------------------------------------"
echo " Backing up Apache2's default index.html file .... "
echo "---------------------------------------------------"
cd /var/www/html/
if [ -e index.html ]
then
mv /var/www/html/index.html /var/www/html/index.html.bak
echo ""
echo " Done .... "
else
echo ""
echo "-------------------------------------------------------------------"
echo " No Apache2 default index.html file found.  Continuing anyway .... "
echo "-------------------------------------------------------------------"
fi

echo ""
echo "------------------------------------------------------"
echo " Installing the FDMR-Monitor Dashboard web files .... "
echo "------------------------------------------------------"
cp -a $HBMONDIR/html/. /var/www/html/
if [ -e info.php ]
then
echo ""
echo "------------------------------------------------------"
echo " It looks like the web files installed correctly .... "
echo "------------------------------------------------------"
else
echo ""
echo "----------------------------------------------------------------------------------------------"
echo " OOPS! I don't see the web files. Please check your configuration and try again. Exiting .... "
echo "----------------------------------------------------------------------------------------------"
exit 0
fi

echo ""
echo "---------------------------------------------------------------"
echo " Creating, enabling and starting the FDMR-Monitor service .... "
echo "---------------------------------------------------------------"
cp $HBMONDIR/utils/systemd/fdmr_mon.service /lib/systemd/system/
systemctl enable fdmr_mon
systemctl start fdmr_mon
echo " Done .... "
sleep 2

clear
echo " So now it looks like we're done with installing FDMR-Monitor "
echo " Check and see if it's running by typing: systemctl status fdmr_mon "
echo " Access the Dashboard with your favorite browserby going to the "
echo " Dashboards URL at http://<server_address> "
echo ""
echo " Click on Linked Systems.  If everything went well, you should see the PARROT server "
echo " under the Peers status section "
echo " Have fun and 73 "
