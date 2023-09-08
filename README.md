<!-- GETTING STARTED -->
## Getting Started

This is an attempt to present an alternative to the DOCKER setup installation method of HBLink3 with the PARROT (EchoTest) service
along with a monitoring dashboard using FDMR-Monitor.  FDMR-Monitor seems to be supported more than the actual HBMonv2 distribution
it derives from. To get your DMR Network up and running, follow the steps below:


## Prerequisites

First, this has been tested on Debian 10 and 11, 64 bit distributions only and it is assumed that you are doing the same along with using
the ufw firewall solution. If this works on other versions of Debian, and you have an iptables firewall setup, please let me know at k7ilo@outlook.com

* Temporarily disable your firewall for testing only (ufw in this case):
  ```sh
  ufw disable
  ```
* Confirm your Debian distribution is updated:
  ```sh
  apt update && apt full-upgrade -y
  ```
* Reboot to make sure updates are loaded:
  ```sh
  reboot
  ```
* Install git:
  ```sh
  apt install -y git
  ```


## HBLink3 Installation

Change to the /opt directory:
```
cd /opt
```
Download the repository hosting the scripts:
```
git clone https://github.com/k7ilo/HBLink3_Install.git
```
Change into the HBLink3_Install directory:
```
cd /opt/HBLink3_Install
```
Make the hblink3_install.sh file executable::
```
chmod +x hblink3_install.sh
```
Now run the hblink3_install.sh script.  When installation is completed,
you will be presented with instructions on testing HBlink3.  I suggest
doing so before moving on:
```
./hblink3_install.sh
```


## Firewall (ufw) Installation & Configuration (Optional but highly recommended)

The ufw-firewall_install.sh script is used to install the ufw firewall solution and open the appropriate network ports
for HBLink3, PARROT and FDMR-Monitor to communicate properlly.  If ufw is detected, the script will bypass installation
and configure its network ports.
To get your firewall up and running, follow the steps below:

Change into the HBLink3_Install directory if not already:
```
cd /opt/HBLink3_Install
```
Make the ufw-firewall_install.sh file executable:
```
chmod +x ufw-firewall_install.sh
```
If accessing the server HBLink3 is running on via ssh, edit ufw-firwall_install.sh
and change the ssh port parameter under the Global Parameters section if not using the
default of 22, otherwise there is no need to change anything:
```
nano /opt/HBLink3_Install/ufw-firewall_install.sh
```
Now run the ufw-firewall_install.sh script. When installation and/or configuration are complete, ufw will
be enabled and all neccessary network ports will be opened. All others will be closed, protecting the server:
```
./ufw-firewall_install.sh
```
 





This program is free software; you can redistribute it and/or modify it under the terms of the
GNU General Public License as published by the Free Software Foundation; either version 3 of the
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without
even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the 
GNU General Public License for more details.

You should have received a copy of the GNU General Public License when you downloaded these scripts.
