Create a user called mathias with all priviliges
================================================

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




Make 1wire script starts at boot
================================
http://www.stuffaboutcode.com/2012/06/raspberry-pi-run-program-at-start-up.html

Make script executable
	sudo chmod 755 /etc/init.d/1wire.sh

Test starting the program
	sudo /etc/init.d/1wire.sh start

Test stopping the program
	sudo /etc/init.d/1wire.sh stop

Register script to be run at start-up
To register your script to be run at start-up and shutdown, run the following command:
	sudo update-rc.d 1wire.sh defaults

Note - The header at the start is to make the script LSB compliant and provides details about the start up script and you should only need to change the name.  If you want to know more about creating LSB scripts for managing services, see http://wiki.debian.org/LSBInitScripts

If you ever want to remove the script from start-up, run the following command:
	sudo update-rc.d -f 1wire.sh remove
