if [ "$EUID" -ne 0 ]; then
	echo ""
	echo " You must be root to run this script!! "
	exit 1
fi

# Global Parameters -------------------------------------------------------------------------------------------------
HBLINKREPO=https://github.com/k7ilo/hblink3.git
INSDIR=/opt
HBLINKDIR=$INSDIR/hblink3


# HBlink3 Installation ----------------------------------------------------------------------------------------------
clear
echo ""
echo " Now let's tackle HBlink3 .... "
sleep 2
echo ""
echo "--------------------------------------------------"
echo " First let's download the HBlink3 repository .... "
echo "--------------------------------------------------"
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
echo " Creating a working hblink.cfg file for testing .... "
sleep 2
cat << EOF > $HBLINKDIR/hblink.cfg
# PROGRAM-WIDE PARAMETERS GO HERE
# PATH - working path for files, leave it alone unless you NEED to change it
# PING_TIME - the interval that peers will ping the master, and re-try registraion
#           - how often the Master maintenance loop runs
# MAX_MISSED - how many pings are missed before we give up and re-register
#           - number of times the master maintenance loop runs before de-registering a peer
#
# ACLs:
#
# Access Control Lists are a very powerful tool for administering your system.
# But they consume packet processing time. Disable them if you are not using them.
# But be aware that, as of now, the configuration stanzas still need the ACL
# sections configured even if you're not using them.
#
# REGISTRATION ACLS ARE ALWAYS USED, ONLY SUBSCRIBER AND TGID MAY BE DISABLED!!!
#
# The 'action' May be PERMIT|DENY
# Each entry may be a single radio id, or a hypenated range (e.g. 1-2999)
# Format:
# 	ACL = 'action:id|start-end|,id|start-end,....'
#		--for example--
#	SUB_ACL: DENY:1,1000-2000,4500-60000,17
#
# ACL Types:
# 	REG_ACL: peer radio IDs for registration (only used on HBP master systems)
# 	SUB_ACL: subscriber IDs for end-users
# 	TGID_TS1_ACL: destination talkgroup IDs on Timeslot 1
# 	TGID_TS2_ACL: destination talkgroup IDs on Timeslot 2
#
# ACLs may be repeated for individual systems if needed for granularity
# Global ACLs will be processed BEFORE the system level ACLs
# Packets will be matched against all ACLs, GLOBAL first. If a packet 'passes'
# All elements, processing continues. Packets are discarded at the first
# negative match, or 'reject' from an ACL element.
#
# If you do not wish to use ACLs, set them to 'PERMIT:ALL'
# TGID_TS1_ACL in the global stanza is used for OPENBRIDGE systems, since all
# traffic is passed as TS 1 between OpenBridges
[GLOBAL]
PATH: ./
PING_TIME: 5
MAX_MISSED: 3
USE_ACL: True
REG_ACL: PERMIT:ALL
SUB_ACL: DENY:1
TGID_TS1_ACL: PERMIT:ALL
TGID_TS2_ACL: PERMIT:ALL


# NOT YET WORKING: NETWORK REPORTING CONFIGURATION
#   Enabling "REPORT" will configure a socket-based reporting
#   system that will send the configuration and other items
#   to a another process (local or remote) that may process
#   the information for some useful purpose, like a web dashboard.
#
#   REPORT - True to enable, False to disable
#   REPORT_INTERVAL - Seconds between reports
#   REPORT_PORT - TCP port to listen on if "REPORT_NETWORKS" = NETWORK
#   REPORT_CLIENTS - comma separated list of IPs you will allow clients
#       to connect on. Entering a * will allow all.
#
# ****FOR NOW MUST BE TRUE - USE THE LOOPBACK IF YOU DON'T USE THIS!!!****
[REPORTS]
REPORT: True
REPORT_INTERVAL: 60
REPORT_PORT: 4321
REPORT_CLIENTS: 127.0.0.1


# SYSTEM LOGGER CONFIGURAITON
#   This allows the logger to be configured without chaning the individual
#   python logger stuff. LOG_FILE should be a complete path/filename for *your*
#   system -- use /dev/null for non-file handlers.
#   LOG_HANDLERS may be any of the following, please, no spaces in the
#   list if you use several:
#       null
#       console
#       console-timed
#       file
#       file-timed
#       syslog
#   LOG_LEVEL may be any of the standard syslog logging levels, though
#   as of now, DEBUG, INFO, WARNING and CRITICAL are the only ones
#   used.
#
[LOGGER]
LOG_FILE: /tmp/hblink.log
LOG_HANDLERS: file-timed,console-timed
LOG_LEVEL: DEBUG
LOG_NAME: HBlink


# DOWNLOAD AND IMPORT SUBSCRIBER, PEER and TGID ALIASES
# Ok, not the TGID, there's no master list I know of to download
# This is intended as a facility for other applcations built on top of
# HBlink to use, and will NOT be used in HBlink directly.
# STALE_DAYS is the number of days since the last download before we
# download again. Don't be an ass and change this to less than a few days.
[ALIASES]
TRY_DOWNLOAD: True
PATH: ./
PEER_FILE: peer_ids.json
SUBSCRIBER_FILE: subscriber_ids.json
TGID_FILE: talkgroup_ids.json
PEER_URL: https://www.radioid.net/static/rptrs.json
SUBSCRIBER_URL: https://www.radioid.net/static/users.json
STALE_DAYS: 7


# OPENBRIDGE INSTANCES - DUPLICATE SECTION FOR MULTIPLE CONNECTIONS
# OpenBridge is a protocol originall created by DMR+ for connection between an
# IPSC2 server and Brandmeister. It has been implemented here at the suggestion
# of the Brandmeister team as a way to legitimately connect HBlink to the
# Brandemiester network.
# It is recommended to name the system the ID of the Brandmeister server that
# it connects to, but is not necessary. TARGET_IP and TARGET_PORT are of the
# Brandmeister or IPSC2 server you are connecting to. PASSPHRASE is the password
# that must be agreed upon between you and the operator of the server you are
# connecting to. NETWORK_ID is a number in the format of a DMR Radio ID that
# will be sent to the other server to identify this connection.
# other parameters follow the other system types.
#
# ACLs:
# OpenBridge does not 'register', so registration ACL is meaningless.
# Proper OpenBridge passes all traffic on TS1.
# HBlink can extend OPB to use both slots for unit calls only.
# Setting "BOTH_SLOTS" True ONLY affects unit traffic!
# Otherwise ACLs work as described in the global stanza
[OBP-1]
MODE: OPENBRIDGE
ENABLED: False
IP:
PORT: 62035
NETWORK_ID: 3129100
PASSPHRASE: password
TARGET_IP: 1.2.3.4
TARGET_PORT: 62035
BOTH_SLOTS: True
USE_ACL: True
SUB_ACL: DENY:1
TGID_ACL: PERMIT:ALL


# MASTER INSTANCES - DUPLICATE SECTION FOR MULTIPLE MASTERS
# HomeBrew Protocol Master instances go here.
# IP may be left blank if there's one interface on your system.
# Port should be the port you want this master to listen on. It must be unique
# and unused by anything else.
# Repeat - if True, the master repeats traffic to peers, False, it does nothing.
#
# MAX_PEERS -- maximun number of peers that may be connect to this master
# at any given time. This is very handy if you're allowing hotspots to
# connect, or using a limited computer like a Raspberry Pi.
#
# ACLs:
# See comments in the GLOBAL stanza
[MASTER-1]
MODE: MASTER
ENABLED: True
REPEAT: True
MAX_PEERS: 10
EXPORT_AMBE: False
IP:
PORT: 62030
PASSPHRASE: passw0rd
GROUP_HANGTIME: 5
USE_ACL: True
REG_ACL: DENY:1
SUB_ACL: DENY:1
TGID_TS1_ACL: PERMIT:ALL
TGID_TS2_ACL: PERMIT:ALL


# PEER INSTANCES - DUPLICATE SECTION FOR MULTIPLE PEERS
# There are a LOT of errors in the HB Protocol specifications on this one!
# MOST of these items are just strings and will be properly dealt with by the program
# The TX & RX Frequencies are 9-digit numbers, and are the frequency in Hz.
# Latitude is an 8-digit unsigned floating point number.
# Longitude is a 9-digit signed floating point number.
# Height is in meters
# Setting Loose to True relaxes the validation on packets received from the master.
# This will allow HBlink to connect to a non-compliant system such as XLXD, DMR+ etc.
#
# ACLs:
# See comments in the GLOBAL stanza
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
PASSPHRASE: passw0rd
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
PASSPHRASE: passw0rd
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
echo " Creating a working rules.py file for testing .... "
sleep 2
cat << EOF > $HBLINKDIR/rules.py
# THIS EXAMPLE WILL NOT WORK AS IT IS - YOU MUST SPECIFY YOUR OWN VALUES!!!
# This file is organized around the "Conference Bridges" that you wish to use. If you're a C-Bridge
# person, think of these as "bridge groups". You might also liken them to a "reflector". If a particular
# system is "ACTIVE" on a particular conference bridge, any traffid from that system will be sent
# to any other system that is active on the bridge as well. This is not an "end to end" method, because
# each system must independently be activated on the bridge.
# The first level (e.g. "FREESTAR" or "CQ-UK" in the examples) is the name of the conference
# bridge. This is any arbitrary ASCII text string you want to use. Under each conference bridge
# definition are the following items -- one line for each HBSystem as defined in the main HBlink
# configuration file.
#    * SYSTEM - The name of the sytem as listed in the main hblink configuration file (e.g. hblink.cfg)
#        This MUST be the exact same name as in the main config file!!!
#    * TS - Timeslot used for matching traffic to this confernce bridge
#        XLX connections should *ALWAYS* use TS 2 only.
#    * TGID - Talkgroup ID used for matching traffic to this conference bridge
#        XLX connections should *ALWAYS* use TG 9 only.
#    * ON and OFF are LISTS of Talkgroup IDs used to trigger this system off and on. Even if you
#        only want one (as shown in the ON example), it has to be in list format. None can be
#        handled with an empty list, such as " 'ON': [] ".
#    * TO_TYPE is timeout type. If you want to use timers, ON means when it's turned on, it will
#        turn off afer the timout period and OFF means it will turn back on after the timout
#        period. If you don't want to use timers, set it to anything else, but 'NONE' might be
#       a good value for documentation!
#    * TIMOUT is a value in minutes for the timout timer. No, I won't make it 'seconds', so don't
#        ask. Timers are performance "expense".
#    * RESET is a list of Talkgroup IDs that, in addition to the ON and OFF lists will cause a running
#        timer to be reset. This is useful   if you are using different TGIDs for voice traffic than
#        triggering. If you are not, there is NO NEED to use this feature.

BRIDGES = {
    'HBLink-Local-TG11': [
            {'SYSTEM': 'MASTER-1',    'TS': 1,  'TGID': 11,    'ACTIVE': True,  'TIMEOUT': 30, 'TO_TYPE':'OFF',  'ON': [11],  'OFF': [55],  'RESET': []},
        ],

    'HBLink-PARROT-TG9999': [
            {'SYSTEM': 'PARROT',    'TS': 2,  'TGID': 9999,  'ACTIVE': True,  'TIMEOUT': 0,  'TO_TYPE':'NONE', 'ON': [],    'OFF': [],    'RESET': []},
            {'SYSTEM': 'MASTER-1',    'TS': 2,  'TGID': 9999,  'ACTIVE': True,  'TIMEOUT': 0,  'TO_TYPE':'NONE', 'ON': [],    'OFF': [],    'RESET': []},
        ]
}

#List the names of each system that should bridge unit to unit (individual) calls.
UNIT = ['ONE', 'TWO']

#This is for testing the syntax of the file. It won't eliminate all errors, but running this file
#like it were a Python program itself will tell you if the syntax is correct!
if __name__ == '__main__':
    from pprint import pprint
    pprint(BRIDGES)
    print(UNIT)
EOF
echo ""
echo " Done .... "


echo ""
echo " Creating a working playback.cfg file for the Echotest (PARROT) service .... "
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
PASSPHRASE: passw0rd
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
echo " Creating the directory for log files .... "
sleep 2
mkdir /var/log/hblink
echo ""
echo " Done .... "


echo ""
echo " Creating the service file and enabling the hblink service. It will auto-start on reboot .... "
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
echo " Creating the service file for enabling and starting the parrot service .... "
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

clear
echo " All finished .... "
sleep 2


echo ""
echo " Now manually test hblink3 by typing: python3 /opt/hblink3/bridge.py "
echo " Now go check and see if parrot is running by: systemctl status parrot "
echo " Issue the command: systemctl start hblink after confirming operation or just reboot "
echo ""
echo " The installed configuration has 1 working Talk Group (TG11) and a working PARROT (Echotest, TG 9999) service "
echo " After confirming a good test, stop the test (control c) and start the hblink service: systemctl start hblink "
echo " or just reboot since PARROT and HBlink3 were enabled to start on system boot earlier. "
echo ""
echo " 73 de K7ILO "