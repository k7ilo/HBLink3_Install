# HBLink3_Install
  - hblink3_install.sh =>>       Installs HBLink3 with one test talkgroup and parrot echotest service
  - ufw-firewall_install.sh =>>  Installs the ufw firewall solution and opens basic required network ports    
  - fdmr-mon_install.sh =>>      Installs the FDMR-Monitor dashboard for HBLink3

To start the installation process, as ROOT ....
1. Make sure your Debian 10/11 system is fully updated:     apt update && apt full-upgrade -y
2. Reboot to make sure any updates are loaded.
3. Install git:     apt install -y git
4. Change to the /opt directory and download these scripts:     cd /opt
5. Download these scripts:     git clone https://github.com/k7ilo/HBLink3_Install.git







This program is free software; you can redistribute it and/or modify it under the terms of the
GNU General Public License as published by the Free Software Foundation; either version 3 of the
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without
even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the 
GNU General Public License for more details.

You should have received a copy of the GNU General Public License when you downloaded these scripts.
