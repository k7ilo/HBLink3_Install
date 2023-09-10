#!/bin/bash
# K7ILO's HBlink3, HBMonv2, Firewall Installer, V2.1 ----------------------------------------------------------------

if [ "$EUID" -ne 0 ];
then
echo ""
echo " You must be root to run this script!! "
exit 1
fi

if [ ! -e "/etc/debian_version" ]
then
echo ""
echo " This script has been tested on NEWLY INSTALLED Debian 10 and 11 64-bit repo's only. "
echo " It is assumed you are doing the same. "
exit 0
fi

# Global Parameters -------------------------------------------------------------------------------------------------
VERSION=$(sed 's/\..*//' /etc/debian_version)
INSDIR=/opt
HBLINKDIR=$INSDIR/hblink3
HBMONDIR=$INSDIR/HBMonv2
DEP="git curl python3 python3-dev python3-pip sed libffi-dev libssl-dev apache2 php ca-certificates"
sshport=22

HBLINKREPO=https://github.com/HBLink-org/hblink3.git
HBMONREPO=https://github.com/sp2ong/HBMonv2.git

# Lets begin --------------------------------------------------------------------------------------------------------
if [ $VERSION = 10 ];
then
echo ""
echo " Debian 10 (Buster) is detected "
sleep 2
clear
echo ""
echo "-------------------------------------------------------------------------------"
echo " Downloading and installing the required software & dependencies from apt .... "
echo "-------------------------------------------------------------------------------"
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
echo ""
echo " Debian 11 (Bullseye) is detected "
sleep 2
clear
echo ""
echo "-------------------------------------------------------------------------------"
echo " Downloading and installing the required software & dependencies from apt .... "
echo "-------------------------------------------------------------------------------"
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
clear
echo "------------------------------------------------------------------------------------------"
echo " Operating system not supported! Please check your configuration or upgrade. Exiting .... "
echo "------------------------------------------------------------------------------------------"
exit 0
fi
clear


# HBlink3 Installation ----------------------------------------------------------------------------------------------
clear
echo ""
echo "------------------------------------------------------------"
echo " Now let's download and install the HBlink3 repository .... "
echo "------------------------------------------------------------"
sleep 2
cd $INSDIR
git clone $HBLINKREPO
cd $HBLINKDIR
if [ -e bridge.py ]
then
echo ""
echo "---------------------------------------------------------------------"
echo " It looks like HBlink3 was downloaded correctly. Let's continue .... "
echo "---------------------------------------------------------------------"
else
echo "----------------------------------------------------------------------------------------------"
echo " I dont see the HBlink3 downlaod! Please check your configuration and try again. Exiting .... "
echo "----------------------------------------------------------------------------------------------"
exit 0
fi

echo ""
echo "----------------------------------------------------------------------"
echo " Installing required dependencies from the requirements.txt file .... "
echo "----------------------------------------------------------------------"
sleep 2
pip3 install -r requirements.txt
echo ""
echo " Done .... "

echo ""
echo "---------------------------------------------------------"
echo "     Creating a working hblink.cfg file for testing      "
echo " Refer to hblink-SAMPLE.cfg for explanations and options " 
echo "---------------------------------------------------------"
sleep 2
cat << EOF > $HBLINKDIR/hblink.cfg
[GLOBAL]
PATH: ./
PING_TIME: 5
MAX_MISSED: 3
USE_ACL: True
REG_ACL: PERMIT:ALL
SUB_ACL: DENY:1
TGID_TS1_ACL: PERMIT:ALL
TGID_TS2_ACL: PERMIT:ALL

[REPORTS]
REPORT: True
REPORT_INTERVAL: 60
REPORT_PORT: 4321
REPORT_CLIENTS: 127.0.0.1

[LOGGER]
LOG_FILE: /tmp/hblink.log
LOG_HANDLERS: file-timed,console-timed
LOG_LEVEL: DEBUG
LOG_NAME: HBlink

[ALIASES]
TRY_DOWNLOAD: True
PATH: ./
PEER_FILE: peer_ids.json
SUBSCRIBER_FILE: subscriber_ids.json
TGID_FILE: talkgroup_ids.json
PEER_URL: https://www.radioid.net/static/rptrs.json
SUBSCRIBER_URL: https://www.radioid.net/static/users.json
STALE_DAYS: 7

[OBP-1]
MODE: OPENBRIDGE
ENABLED: False
IP:
PORT: 62035
NETWORK_ID: 3129100
PASSPHRASE: a_password
TARGET_IP: 1.2.3.4
TARGET_PORT: 62035
BOTH_SLOTS: True
USE_ACL: True
SUB_ACL: DENY:1
TGID_ACL: PERMIT:ALL

[MASTER-1]
MODE: MASTER
ENABLED: True
REPEAT: True
MAX_PEERS: 10
EXPORT_AMBE: False
IP:
PORT: 62030
PASSPHRASE: a_password
GROUP_HANGTIME: 5
USE_ACL: True
REG_ACL: DENY:1
SUB_ACL: DENY:1
TGID_TS1_ACL: PERMIT:ALL
TGID_TS2_ACL: PERMIT:ALL

[REPEATER-1]
MODE: PEER
ENABLED: False
LOOSE: False
EXPORT_AMBE: False
IP: 
PORT: 54001
MASTER_IP: 172.16.1.1
MASTER_PORT: 54000
PASSPHRASE: homebrew
CALLSIGN: W1ABC
RADIO_ID: 312000
RX_FREQ: 449000000
TX_FREQ: 444000000
TX_POWER: 25
COLORCODE: 1
SLOTS: 1
LATITUDE: 38.0000
LONGITUDE: -095.0000
HEIGHT: 75
LOCATION: Anywhere, USA
DESCRIPTION: This is a cool repeater
URL: www.w1abc.org
SOFTWARE_ID: 20170620
PACKAGE_ID: MMDVM_HBlink
GROUP_HANGTIME: 5
OPTIONS:
USE_ACL: True
SUB_ACL: DENY:1
TGID_TS1_ACL: PERMIT:ALL
TGID_TS2_ACL: PERMIT:ALL

[XLX-1]
MODE: XLXPEER
ENABLED: False
LOOSE: True
EXPORT_AMBE: False
IP: 
PORT: 54002
MASTER_IP: 172.16.1.1
MASTER_PORT: 62030
PASSPHRASE: a_password
CALLSIGN: W1ABC
RADIO_ID: 312000
RX_FREQ: 449000000
TX_FREQ: 444000000
TX_POWER: 25
COLORCODE: 1
SLOTS: 1
LATITUDE: 38.0000
LONGITUDE: -095.0000
HEIGHT: 75
LOCATION: Anywhere, USA
DESCRIPTION: This is a cool repeater
URL: www.w1abc.org
SOFTWARE_ID: 20170620
PACKAGE_ID: MMDVM_HBlink
GROUP_HANGTIME: 5
XLXMODULE: 4004
USE_ACL: True
SUB_ACL: DENY:1
TGID_TS1_ACL: PERMIT:ALL
TGID_TS2_ACL: PERMIT:ALL

[PARROT]
MODE: PEER
ENABLED: True
LOOSE: False
EXPORT_AMBE: False
IP:
PORT: 54111
MASTER_IP:  127.0.0.1
MASTER_PORT: 54112
PASSPHRASE: a_password
CALLSIGN: PARROT
RADIO_ID: 9999
RX_FREQ: 000000000
TX_FREQ: 000000000
TX_POWER: 1
COLORCODE: 1
SLOTS: 3
LATITUDE: 38.0000
LONGITUDE: -095.0000
HEIGHT: 0
LOCATION: PARROT Server: TG 9999
DESCRIPTION: PARROT Server: TG 9999
URL:
SOFTWARE_ID: 20170620
PACKAGE_ID: MMDVM_HBlink
GROUP_HANGTIME: 5
OPTIONS:
USE_ACL: True
SUB_ACL: DENY:1
TGID_TS1_ACL: PERMIT:ALL
TGID_TS2_ACL: PERMIT:ALL
EOF
echo ""
echo " Done .... "

echo ""
echo "-------------------------------------------------------"
echo "     Creating a working rules.py file for testing      "
echo " Refer to rules_SAMPLE.py for explanations and options " 
echo "-------------------------------------------------------"
sleep 2
cat << EOF > $HBLINKDIR/rules.py
BRIDGES = {
    'HBLink-Local-TG11': [
            {'SYSTEM': 'MASTER-1',    'TS': 1,  'TGID': 11,    'ACTIVE': True,  'TIMEOUT': 30, 'TO_TYPE':'OFF',  'ON': [11],  'OFF': [55],  'RESET': []},
        ],

    'HBLink-PARROT-TG9999': [
            {'SYSTEM': 'PARROT',    'TS': 2,  'TGID': 9999,  'ACTIVE': True,  'TIMEOUT': 0,  'TO_TYPE':'NONE', 'ON': [],    'OFF': [],    'RESET': []},
            {'SYSTEM': 'MASTER-1',    'TS': 2,  'TGID': 9999,  'ACTIVE': True,  'TIMEOUT': 0,  'TO_TYPE':'NONE', 'ON': [],    'OFF': [],    'RESET': []},
        ]
}

UNIT = ['ONE', 'TWO']

if __name__ == '__main__':
    from pprint import pprint
    pprint(BRIDGES)
    print(UNIT)
EOF
echo ""
echo " Done .... "

echo ""
echo "------------------------------------------------------------------------"
echo " Creating a working playback.cfg file for the Echotest (PARROT) service "
echo "------------------------------------------------------------------------"
sleep 2
cat << EOF > $HBLINKDIR/playback.cfg
[GLOBAL]
PATH: ./
PING_TIME: 5
MAX_MISSED: 3
USE_ACL: True
REG_ACL: PERMIT:ALL
SUB_ACL: DENY:1
TGID_TS1_ACL: PERMIT:ALL
TGID_TS2_ACL: PERMIT:ALL


[REPORTS]
REPORT: True
REPORT_INTERVAL: 60
REPORT_PORT: 4322
REPORT_CLIENTS: 127.0.0.1


[LOGGER]
LOG_FILE: /tmp/hblink.log
LOG_HANDLERS: console-timed,file-timed
LOG_LEVEL: INFO
LOG_NAME: HBlink


[ALIASES]
TRY_DOWNLOAD: True
PATH: ./
PEER_FILE: peer_ids.json
SUBSCRIBER_FILE: subscriber_ids.json
TGID_FILE: talkgroup_ids.json
PEER_URL: https://www.radioid.net/static/rptrs.json
SUBSCRIBER_URL: https://www.radioid.net/static/users.json
STALE_DAYS: 7


[MASTER-1]
MODE: MASTER
ENABLED: True
REPEAT: False
MAX_PEERS: 10
EXPORT_AMBE: False
IP:
PORT: 54112
PASSPHRASE: a_password
GROUP_HANGTIME: 5
USE_ACL: True
REG_ACL: DENY:1
SUB_ACL: DENY:1
TGID_TS1_ACL: PERMIT:ALL
TGID_TS2_ACL: PERMIT:ALL
EOF
echo ""
echo " Done .... "

echo ""
echo "-------------------------------------------"
echo " Creating the directory for log files .... "
echo "-------------------------------------------"
sleep 2
mkdir /var/log/hblink
echo ""
echo " Done .... "

echo ""
echo "----------------------------------------------------------------------------------------------"
echo " Creating the service file and enabling the hblink service. It will auto-start on reboot .... "
echo "----------------------------------------------------------------------------------------------"
sleep 2
cat << EOF > /lib/systemd/system/hblink.service
[Unit]
Description=Start HBlink
After=multi-user.target

[Service]
ExecStart=/usr/bin/python3 /opt/hblink3/bridge.py

[Install]
WantedBy=multi-user.target
EOF
systemctl enable hblink
echo ""
echo " Done .... "

echo ""
echo "-----------------------------------------------------------------------------"
echo " Creating the service file for enabling and starting the parrot service .... "
echo "-----------------------------------------------------------------------------"
sleep 2
cat << EOF > /lib/systemd/system/parrot.service
[Unit]
Description=HB bridge all Service
After=network-online.target syslog.target
Wants=network-online.target

[Service]
StandardOutput=null
WorkingDirectory=/opt/hblink3
RestartSec=3
ExecStart=/usr/bin/python3 /opt/hblink3/playback.py -c /opt/hblink3/playback.cfg
Restart=on-abort

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
chmod +x $HBLINKDIR/playback.py
systemctl start parrot.service
systemctl enable parrot.service
echo " Done .... "

echo "--------------------------------------------------------------------"
echo " HBLink3 installation is complete.  Moving on to the next task .... "
echo "--------------------------------------------------------------------"
sleep 2


# HBMonv2 Installation ----------------------------------------------------------------------------------------------
clear
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
cp $HBMONDIR/utils/lastheard /etc/cron.daily/
chmod +x /etc/cron.daily/lastheard
cp $HBMONDIR/utils/hbmon.service /lib/systemd/system/
systemctl enable hbmon
systemctl start hbmon
echo " Done .... "
sleep 2

echo "------------------------------------------------------------------"
echo " The HBMonv2 installation is complete.  One more thing to do .... "
echo "------------------------------------------------------------------"
sleep 2


# ufw Installation --------------------------------------------------------------------------------------------------
clear
echo ""
echo "----------------------------------------------------------------------------------"
echo " Installing the ufw firewall solution and open the appropriate network ports .... "
echo "----------------------------------------------------------------------------------"

if command -v ufw >/dev/null
then
echo "--------------------------------------------------------------------------"
echo " ufw is already installed.  The ports just need to be opened.  Moving on! "
echo "--------------------------------------------------------------------------"
else
echo "--------------------------------------------------------------------"
echo " About to download and install ufw and its dependencies.  STANDBY!! "
echo "--------------------------------------------------------------------"
apt update && apt install -y ufw
apt autoremove && apt autoclean
fi

echo "------------------------------------------------------------"
echo " Enabling ufw and opening the proper ports for HBlink3 .... "
echo "------------------------------------------------------------"
sleep 2
ufw allow $sshport/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 4321/tcp
ufw allow 9000/tcp
ufw allow 62030:62050/udp
sleep 1
ufw enable
sleep 1
ufw status
echo ""
echo "------------------------------------------------------"
echo " ufw is enabled and the required ports are opened now "
echo "             All other ports are closed               "
echo "------------------------------------------------------"
sleep 3

clear
echo ""
echo " Check to see if the parrot service is running by: systemctl status parrot "
echo " Also check to see if HBMonv2 is running by typing: systemctl status hbmon "
echo " Manually start and test hblink by typing: python3 /opt/hblink3/bridge.py "
echo " You should see plenty of data scrolling the screen "
echo " The installed configuration has 1 working Talk Group (TG11) and a working PARROT (Echotest, TG 9999) service "
echo ""
echo " Now access the HBMonv2 Dashboard with your favorite browser by going to the "
echo " dashboards server URL at http://<server_address> "
echo " The PARROT server should show under the Connected to Server section on " 
echo " the Home page if everything went well and should also show on the Peers page. "
echo ""
echo " After confirming a good test, stop the test (control c) and start the hblink service: systemctl start hblink "
echo " or just reboot since PARROT and HBlink3 were enabled to start on system boot earlier. "
echo " Have fun and 73 "
