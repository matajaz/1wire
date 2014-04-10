create a user called mathias with sudo priviliges and remove i user
===================================================================
sudo adduser mathias
sudo adduser mathias sudo
sudo deluser -remove-home pi

Upgrade raspberrypi
===================
sudo apt-get update
sudo apt-get upgrade
sudo rpi-update
sudo reboot
ifconfig -a
sudo ifup wlan0
ifconfig -a

Create iptabled firewall
========================
Create the file /etc/iptables.conf
# Allows all loopback (lo0) traffic and drop all traffic to 127/8 that doesn't use lo0
-A INPUT -i lo -j ACCEPT
-A INPUT ! -i lo -d 127.0.0.0/8 -j REJECT
-A INPUT -i wlan0 -j ACCEPT
-A INPUT -i eth0 -j ACCEPT
#-A INPUT ! -i wlan0 -d 127.0.0.0/8 -j REJECT

# Accepts all established inbound connections
-A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allows all outbound traffic
# You could modify this to only allow certain traffic
-A OUTPUT -j ACCEPT

# Allows HTTP and HTTPS connections from anywhere (the normal ports for websites)
-A INPUT -p tcp --dport 80 -j ACCEPT
-A INPUT -p tcp --dport 443 -j ACCEPT

# Allows SSH connections
# THE -dport NUMBER IS THE SAME ONE YOU SET UP IN THE SSHD_CONFIG FILE
-A INPUT -p tcp -m state --state NEW --dport 22000 -j ACCEPT

# Now you should read up on iptables rules and consider whether ssh access
# for everyone is really desired. Most likely you will only allow access from certain IPs.

# Allow ping
-A INPUT -p icmp -m icmp --icmp-type 8 -j ACCEPT

# log iptables denied calls (access via 'dmesg' command)
-A INPUT -m limit --limit 5/min -j LOG --log-prefix "iptables denied: " --log-level 7

# Reject all other inbound - default deny unless explicitly allowed policy:
-A INPUT -j REJECT
-A FORWARD -j REJECT

COMMIT


Save firewall configuration
---------------------------
sudo sh -c "iptables-save > /etc/iptables.rules"

Make it startup at boot
-----------------------
sudo nano /etc/network/interfaces
pre-up iptables-restore < /etc/network/iptables

alt:
pre-up iptables-restore < /etc/iptables.rules
post-down iptables-restore < /etc/iptables.downrules


Installera OWFS
===============
http://wiki.temperatur.nu/index.php/OWFS_p%C3%A5_Rasperry_Pi
sudo apt-get install owfs
sudo mkdir /mnt/1wire
cd /etc/init.d
sudo nano start1wire.sh
#!/bin/bash

### BEGIN INIT INFO
# Provides:          start1wire
# Required-Start:    $local_fs $syslog
# Required-Stop:     $local_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start OWFS at boot time
# Description:       Start OWFS at boot time
### END INIT INFO

# Starts OWFS
/usr/bin/owfs --i2c=ALL:ALL --allow_other /mnt/1wire

sudo chmod +x start1wire.sh
sudo update-rc.d start1wire.sh defaults

Mount other rasperrby pis
=========================
mkdir /home/mathias/hallon1
mkdir /home/mathias/hallon2
mkdir /home/mathias/hallon3
mkdir /home/mathias/hallon4
mkdir /home/mathias/hallon5

sshfs pi@hallon1:/home/pi /home/mathias/hallon1
sshfs mathias@hallon2:/home/mathias /home/mathias/hallon2
sshfs mathias@hallon3:/home/mathias /home/mathias/hallon3
sshfs mathias@hallon4:/home/mathias /home/mathias/hallon4
sshfs mathias@hallon5:/home/mathias /home/mathias/hallon5

Kopiera filer från hallon1
==========================
cp -r hallon1/bin/1wire hallon2/bin/
cp -r hallon1/bin/1wire hallon3/bin/
cp -r hallon1/bin/1wire hallon4/bin/
cp -r hallon1/bin/1wire hallon5/bin/

Gör så att scripten startas automatiskt
=======================================
sudo nano /etc/init.d/1wire.sh

### BEGIN INIT INFO
# Provides:          1wire.sh
# Required-Start:    $remote_fs $syslog $all
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Simple script to start a program at boot
# Description:       A simple script that will start/stop 1wire measurements at boot/shutdown.
### END INIT INFO

# If you want a command to always run, put it here

# Carry out specific functions when asked to by the system
case "$1" in
  start)
    echo "Starting 1wire"
    logger 1wire measurements started
    # run application you want to start
	cd /home/pi/bin/
	/home/pi/bin/1wire/1wire.pl
    ;;
  stop)
    echo "Stopping 1wire"
    logger 1wire measurements stopped
    # kill application you want to stop
    killall 1wire.pl
    ;;
  *)
    echo "Usage: /etc/init.d/1wire.sh {start|stop}"
    logger Wrong usage of /etc/init.d/1wire.sh
    exit 1
    ;;
esac

exit 0

Gör scriptet exekverbart
------------------------
sudo chmod +x /etc/init.d/1wire.sh

Se till att det startas vid boot
--------------------------------
sudo update-rc.d 1wire.sh defaults


Installera mysql
================
sudo apt-get install mysql-server mysql-client libmysqlclient-dev

Installera perl moduler
=======================
sudo perl -MCPAN -e shell
install CPAN
reload cpan
install DBI DBD::mysql DateTime

install DBI
install DBD
install DateTime

Ta bort root pwd för sql om nödvändigt
--------------------------------------
mysqladmin -u root -pCURRENTPASSWORD password ''

Create a SQL user called mathias with all priviliges
====================================================
apt-get install mysql-server mysql-client
mysql -u root -p


mysql> CREATE USER 'mathias'@'localhost' IDENTIFIED BY 'AldriN1972';
Query OK, 0 rows affected (0.01 sec)

mysql> GRANT ALL PRIVILEGES ON *.* TO 'mathias'@'localhost' WITH GRANT OPTION;
Query OK, 0 rows affected (0.00 sec)

mysql> CREATE USER 'mathias'@'%' IDENTIFIED BY 'AldriN1972';
Query OK, 0 rows affected (0.00 sec)

mysql> GRANT ALL PRIVILEGES ON *.* TO 'mathias'@'%' WITH GRANT OPTION;
Query OK, 0 rows affected (0.00 sec)


mysql> SHOW GRANTS FOR 'mathias'@'localhost';
+-------------------------------------------------------------------------------------------------------------------------------------------+
| Grants for mathias@localhost                                                                                                              |
+-------------------------------------------------------------------------------------------------------------------------------------------+
| GRANT ALL PRIVILEGES ON *.* TO 'mathias'@'localhost' IDENTIFIED BY PASSWORD '*A2CB4C7C4CA62B8A5D92CA9EF5ECB018B6C277B3' WITH GRANT OPTION |

+-------------------------------------------------------------------------------------------------------------------------------------------+
1 row in set (0.00 sec)


comment out 
#bind-address	 = 127.0.0.1
in file /etc/mysql /my.cnf




Create Tables
=============
mysql> show tables;
ERROR 2006 (HY000): MySQL server has gone away
No connection. Trying to reconnect...
Connection id:    1671
Current database: measure

show tables;
+-------------------+
| Tables_in_measure |
+-------------------+
| anlis_rum         |
| arbetsrum         |
| elmatare          |
| foradstemp        |
| guestroom         |
| ljustemp          |
| ljustemperatur    |
| sensors           |
| sovrum            |
| utetemp           |
+-------------------+

mysql> show columns from anlis_rum;
+-------------+------------+------+-----+---------+----------------+
| Field       | Type       | Null | Key | Default | Extra          |
+-------------+------------+------+-----+---------+----------------+
| Index       | bigint(20) | NO   | PRI | NULL    | auto_increment |
| TimeStamp   | datetime   | NO   |     | NULL    |                |
| Temperature | double     | NO   |     | NULL    |                |
+-------------+------------+------+-----+---------+----------------+
3 rows in set (0.01 sec)


CREATE TABLE `anlis_rum` (
	`Index` bigint(20) NOT NULL AUTO_INCREMENT,
	`TimeStamp` datetime NOT NULL,
	`Temperature` double NOT NULL,
	PRIMARY KEY (`Index`)
) ENGINE=InnoDB AUTO_INCREMENT=134 DEFAULT CHARSET=latin1;

CREATE TABLE `arbetsrum` (
	`Index` bigint(20) NOT NULL AUTO_INCREMENT,
	`TimeStamp` datetime NOT NULL,
	`Temperature` double NOT NULL,
	PRIMARY KEY (`Index`)
) ENGINE=InnoDB AUTO_INCREMENT=2277 DEFAULT CHARSET=latin1;

CREATE TABLE `guestroom` (
	`Index` bigint(20) NOT NULL AUTO_INCREMENT,
	`TimeStamp` datetime NOT NULL,
	`Temperature` double NOT NULL,
	PRIMARY KEY (`Index`)
) ENGINE=InnoDB AUTO_INCREMENT=109 DEFAULT CHARSET=latin1

CREATE TABLE `ljustemp` (
	`Index` bigint(20) NOT NULL AUTO_INCREMENT,
	`TimeStamp` datetime NOT NULL,
	`Temperature` double NOT NULL,
	PRIMARY KEY (`Index`)
) ENGINE=InnoDB AUTO_INCREMENT=109 DEFAULT CHARSET=latin1

CREATE TABLE `ljustemperatur` (
	`Index` bigint(20) NOT NULL AUTO_INCREMENT,
	`TimeStamp` datetime NOT NULL,
	`Temperature` double NOT NULL,
	PRIMARY KEY (`Index`)
) ENGINE=InnoDB AUTO_INCREMENT=109 DEFAULT CHARSET=latin1

CREATE TABLE `sovrum` (
	`Index` bigint(20) NOT NULL AUTO_INCREMENT,
	`TimeStamp` datetime NOT NULL,
	`Temperature` double NOT NULL,
	PRIMARY KEY (`Index`)
) ENGINE=InnoDB AUTO_INCREMENT=109 DEFAULT CHARSET=latin1

CREATE TABLE `utetemp` (
	`Index` bigint(20) NOT NULL AUTO_INCREMENT,
	`TimeStamp` datetime NOT NULL,
	`Temperature` double NOT NULL,
	PRIMARY KEY (`Index`)
) ENGINE=InnoDB AUTO_INCREMENT=109 DEFAULT CHARSET=latin1

CREATE TABLE `foradstemp` (
	`Index` bigint(20) NOT NULL AUTO_INCREMENT,
	`TimeStamp` datetime NOT NULL,
	`Temperature` double NOT NULL,
	PRIMARY KEY (`Index`)
) ENGINE=InnoDB AUTO_INCREMENT=109 DEFAULT CHARSET=latin1

CREATE TABLE `sensors` (
	`SensorIndex` int(11) NOT NULL AUTO_INCREMENT,
	`Type` text NOT NULL,
	`Address` text NOT NULL,
	`TableName` text NOT NULL,
	`Alias` text NOT NULL,
	PRIMARY KEY (`SensorIndex`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1

CREATE TABLE `elmatare` (
  `index` bigint(20) NOT NULL AUTO_INCREMENT,
  `TimeStamp` datetime NOT NULL,
  `Counter_A` bigint(20) NOT NULL,
  `Counter_B` bigint(20) NOT NULL,
  `Counter_C` bigint(20) NOT NULL,
  `Counter_D` bigint(20) NOT NULL,
  PRIMARY KEY (`index`)
) ENGINE=InnoDB AUTO_INCREMENT=267817 DEFAULT CHARSET=latin1;

CREATE TABLE `hallon1` (
	`Index` bigint(20) NOT NULL AUTO_INCREMENT,
	`TimeStamp` datetime NOT NULL,
	`CPUTemp` double NOT NULL,
	`GPUTemp` double NOT NULL,
	`WifiSignal` double NOT NULL,
	`WifiQuality` double NOT NULL,
	PRIMARY KEY (`Index`)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=latin1;

CREATE TABLE `hallon2` (
	`Index` bigint(20) NOT NULL AUTO_INCREMENT,
	`TimeStamp` datetime NOT NULL,
	`CPUTemp` double NOT NULL,
	`GPUTemp` double NOT NULL,
	`WifiSignal` double NOT NULL,
	`WifiQuality` double NOT NULL,
	PRIMARY KEY (`Index`)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=latin1;

CREATE TABLE `hallon3` (
	`Index` bigint(20) NOT NULL AUTO_INCREMENT,
	`TimeStamp` datetime NOT NULL,
	`CPUTemp` double NOT NULL,
	`GPUTemp` double NOT NULL,
	`WifiSignal` double NOT NULL,
	`WifiQuality` double NOT NULL,
	PRIMARY KEY (`Index`)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=latin1;

INSERT INTO sensors (Type, Address, TableName, Alias, Host)
VALUES ('DS18B20','28.604E70020000','anlis_rum','Anlis rum','hallon1');


INSERT INTO sensors (Type, Address, TableName, Alias, Host)
VALUES ('DS2450','20.8E0014000000','ljusmatare_DS2450','ljustmätning','');

INSERT INTO sensors (Type, Address, TableName, Alias, Host)
VALUES ('DS2450','20.8E0014000000','ljus','ljustmätning','');

INSERT INTO sensors (Type, Address, TableName, Alias, Host)
VALUES ('DS18B20','28.1A5E70020000','ljustemp','ljustemperatur','');

INSERT INTO sensors (Type, Address, TableName, Alias, Host)
VALUES ('DS18B20','28.1B6170020000','sovrum','sovrum''hallon3');

INSERT INTO sensors (Type, Address, TableName, Alias, Host)
VALUES ('DS18B20','28.EF9D70020000','guestroom','guestroom''hallon3');

INSERT INTO sensors (Type, Address, TableName, Alias, Host)
VALUES ('DS18S20','10.67C6697351FF','','usb_okand1_DS18S20','');

INSERT INTO sensors (Type, Address, TableName, Alias, Host)
VALUES ('DS2405','05.4AEC29CDBAAB','','serial1_okand1_DS2405','');

INSERT INTO sensors (Type, Address, TableName, Alias, Host)
VALUES ('DS18S20','10.67C6697351FF','','serial1_okand2_DS18S20','');

INSERT INTO sensors (Type, Address, TableName, Alias, Host)
VALUES ('DS2423','1D.D3B20D000000','elmatare','elmätare','');

INSERT INTO sensors (Type, Address, TableName, Alias, Host)
VALUES ('DS2438','26.5B2E11010000','fuktmatare_DS2438','fuktmätning','');

INSERT INTO sensors (Type, Address, TableName, Alias, Host)
VALUES ('DS18B20','28.379F70020000','foradstemp','förådstemp','');

INSERT INTO sensors (Type, Address, TableName, Alias, Host)
VALUES ('DS18B20','28.EC5470020000','badrumstemp','badrumstemp','');

INSERT INTO sensors (Type, Address, TableName, Alias, Host)
VALUES ('DS18B20','28.EC5470020000','badrumstemp','badrumstemp','');

INSERT INTO sensors (Type, Address, TableName, Alias, Host)
VALUES ('DS18S20','10.C58384010800','utetemp','utetemp','hallon1');

INSERT INTO sensors (Type, Address, TableName, Alias, Host)
VALUES ('DS18S20','10.728892010800','arbetsrum','arbetsrum','hallon1');

INSERT INTO sensors (Type, Address, TableName, Alias, Host)
VALUES ('DS18S20','10.67C6697351FF','arbetsrum','serial2_okand1_DS18S20','');

INSERT INTO sensors (Type, Address, TableName, Alias, Host)
VALUES ('DSDS2405','05.4AEC29CDBAAB','arbetsrum','serial2_okand2_DSDS2405','');


mysql> show columns from sensors;
+-------------+---------+------+-----+---------+----------------+
| Field       | Type    | Null | Key | Default | Extra          |
+-------------+---------+------+-----+---------+----------------+
| SensorIndex | int(11) | NO   | PRI | NULL    | auto_increment |
| Type        | text    | NO   |     | NULL    |                |
| Address     | text    | NO   |     | NULL    |                |
| TableName   | text    | NO   |     | NULL    |                |
| Alias       | text    | NO   |     | NULL    |                |
| Host        | text    | NO   |     | NULL    |                |
+-------------+---------+------+-----+---------+----------------+
6 rows in set (0.01 sec)

On remote machine
==================
mysql -h hallon1 -u mathias -p

ref:
http://www.raspberrypi.org/phpBB3/viewtopic.php?f=36&t=20214

Backup DB
=========
crontab -e
35 2 * * * mysqldump -u mathias -pAldriN1972 -h hallon1 --databases measure | gzip > /home/mathias/sqldb/database_`date '+%m-%d-%Y'`.sql.gz


Firewall
========
https://wiki.debian.org/iptables


===============================================================================================================0


#USB
                                '28.604E70020000' => {                                  # DS18B20
                                                        tablename =>    'anlis_rum',    # db table name
                                                        alias =>        'anlis rum',    # Alias
                                                },
                                '20.8E0014000000' => {                                  # DS2450
                                                        tablename =>    'ljusmatare_DS2450',
                                                        alias =>        'ljustmätning',
                                                },
#                               '20.8E0014000000' => {                                  # DS2450
#                                                       tablename =>    'ljus',
#                                                       alias =>        'ljustmätning',
#                                               },
                                '28.1A5E70020000' => {                                  # DS18B20
                                                        tablename =>    'ljustemp',
                                                        alias =>        'ljustemperatur',
                                                },
                                '28.1B6170020000' => {                                  # DS18B20
                                                        tablename =>    'sovrum',
                                                        alias =>        'sovrum',
                                                },
                                '28.EF9D70020000' => {                                  # DS18B20
                                                        tablename =>    'guestroom',
                                                        alias =>        'guestroom',
                                                },

                                '10.67C6697351FF' => {                                  # DS18S20
                                                        tablename =>    '',
                                                        alias =>        'usb_okand1_DS18S20',
                                                },
#serial1
                                '05.4AEC29CDBAAB' => {                                  # DS2405_addressable_switch
                                                        tablename =>    '',
                                                        alias =>        'serial1_okand1',
                                                },
                                '10.67C6697351FF' => {                                  # DS18S20
                                                        tablename =>    '',
                                                        alias =>        'serial1_okand2_DS18S20',
                                                },
                                '1D.D3B20D000000' => {                                  # DS2423
                                                        tablename =>    'elmatare',
                                                        alias =>        'elmätare',
                                                },
                                '26.5B2E11010000' => {                                  # DS2438
                                                        tablename =>    'fuktmatare_DS2438',
                                                        alias =>        'fuktmätning',
                                                },
                                '28.379F70020000' => {                                  # DS18B20
                                                        tablename =>    'foradstemp',
                                                        alias =>        'foradstemp',
                                                },
                                '28.EC5470020000' => {                                  # DS18B20
                                                        tablename =>    'badrumstemp',
                                                        alias =>        'badrumstemp',
                                                },
#serial2
                                '10.C58384010800' => {                                  # DS18S20
                                                        tablename =>    'utetemp',
                                                        alias =>        'utetemp',
                                                },
                                '10.728892010800' => {                                  # DS18S20
                                                        tablename =>    'arbetsrum',
                                                        alias =>        'arbetsrum',
                                                },
                                '10.67C6697351FF' => {                                  # DS18S20
                                                        tablename =>    '',
                                                        alias =>        'serial2_okand1',
                                                },
                                '05.4AEC29CDBAAB' => {                                  # DSDS2405_addressable_switch
                                                        tablename =>    '',
                                                        alias =>        'serial2_okand2',
                                                },




GIT info
========
mkdir ~/1wire
cd ~/1wire
git init
git add README
git commit -m 'first commit'
git remote add origin https://github.com/matajaz/1wire.git
.
.
.
git pull 1wire master
git remote add origin https://github.com/matajaz/1wire.git
git push origin master

https://help.github.com/articles/create-a-repo


