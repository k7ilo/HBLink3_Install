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
HBMONDIR=$INSDIR/HBMonv2
HBMONREPO=https://github.com/sp2ong/HBMonv2.git
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
echo "-----------------------------------------------------------------------"
echo " Now lets download and configure the HBMonv2 Dashboard repository .... "
echo "-----------------------------------------------------------------------"
sleep 2
cd $INSDIR
git clone $HBMONREPO
cd $HBMONDIR
if [ -e monitor.py ]
then
echo ""
echo "---------------------------------------------------------------"
echo " I can see we are in the HBMonv2 director. Let's continue .... "
echo "---------------------------------------------------------------"
else
echo "------------------------------------------------------------------------------------------- "
echo " It doesn't seem like you're in the HBMonv2 directory. Please see if you are.  Exiting .... "
echo "------------------------------------------------------------------------------------------- "
exit 0
fi

echo "-----------------------------------------------------------"
echo " Downloading and installing other needed dependencies .... "
echo "-----------------------------------------------------------"
pip3 install setuptools wheel Twisted dmr_utils3 bitstring autobahn jinja2==2.11.3 markupsafe==2.0.1
sleep 2
echo "--------------------------------------"
echo " Creating the configuratoin file .... "
echo "--------------------------------------"
cp config_SAMPLE.py config.py
#chmod 644 config.py
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
echo "-------------------------------------------------"
echo " Installing the HBMonv2 Dashboard web files .... "
echo "-------------------------------------------------"
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
echo "--------------------------------------------------------"
echo " Creating, enabling and starting the hbmon service .... "
echo "--------------------------------------------------------"
cp utils/lastheard /etc/cron.daily/
chmod +x /etc/cron.daily/lastheard
cp $HBMONDIR/utils/hbmon.service /lib/systemd/system/
systemctl enable hbmon
systemctl start hbmon
echo " Done .... "
sleep 2

clear
echo " So now it looks like we're done with installing HBMonv2 "
echo " Check and see if it's running by typing: systemctl status hbmon "
echo " Access the Dashboard with your favorite browser by going to the "
echo " Dashboards URL at http://<server_address> "
echo ""
echo " The PARROT server should show under the Connected to Server section on " 
echo " the Home page if everything went well and should also show on the Peers page. "
echo " Have fun and 73 "
