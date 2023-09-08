#!/bin/bash
# K7ILO's ufw firewall Installer and configurer

if [ "$EUID" -ne 0 ];
then
  echo ""
  echo " You must be root to run this script!! "
  exit 1
fi

if [ ! -e "/etc/debian_version" ]
then
  echo ""
  echo "This script has been tested on Debian 10 and 11 64-bit repo's only."
  exit 0
fi

# Global Parameters -------------------------------------------------------------------------------------------------
VERSION=$(sed 's/\..*//' /etc/debian_version)
DEP="ufw"
sshport=22

# Lets begin --------------------------------------------------------------------------------------------------------
if [ $VERSION = 10 ];
then
	echo " Debian 10 (Buster) is detected "
	sleep 2
	clear
	if pgrep -x ufw >/dev/null
	then
		echo "--------------------------------------------------------------------------"
		echo " ufw is already installed.  The ports just need to be opened.  Moving on! "
		echo "--------------------------------------------------------------------------"
	else 
		echo "--------------------------------------------------------------------"
		echo " About to download and install ufw and its dependencies.  STANDBY!! "
		echo "--------------------------------------------------------------------"
		apt update && apt install -y $DEP
		apt autoremove && apt autoclean
		echo ""
		echo " Done.  Now to open the required ports .... "
fi

elif [ $VERSION = 11 ];
then
	echo " Debian 11 (Bullseye) is detected "
	sleep 2
	clear
	if pgrep -x ufw >/dev/null
	then
		echo "--------------------------------------------------------------------------"
		echo " ufw is already installed.  The ports just need to be opened.  Moving on! "
		echo "--------------------------------------------------------------------------"
	else
		echo "--------------------------------------------------------------------"
		echo " About to download and install ufw and its dependencies.  STANDBY!! "
		echo "--------------------------------------------------------------------"
		apt update && apt install -y $DEP
		apt autoremove && apt autoclean
		echo ""
		echo " Done.  Now to open the required ports .... "
fi

else
clear
echo "------------------------------------------------------------------------------------------"
echo " Operating system not supported! Please check your configuration or upgrade. Exiting .... "
echo "------------------------------------------------------------------------------------------"
exit 0
fi

sleep 3
echo "------------------------------------------------------------"
echo " Enabling ufw and opening the proper ports for HBlink3 .... "
echo "------------------------------------------------------------"
ufw allow $sshport/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 4321/tcp
ufw allow 9000/tcp
ufw allow 62030:62050/udp
sleep 2
ufw enable
sleep 2
ufw status
echo ""
echo "---------------------------------------------------"
echo " ufw enabled and required ports are opened now and "
echo "       All other ports are closed.  73             "
echo "---------------------------------------------------"
