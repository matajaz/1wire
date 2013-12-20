#!/usr/bin/perl
no warnings;
no locale;
use strict;
use DBI;
use DBD::mysql;
use DBI qw(:sql_types);
use DateTime;
use Cwd qw( abs_path );
use File::Basename qw( dirname );

BEGIN{
	my $BASE = dirname(abs_path($0));
	unshift(@INC,$BASE . '/lib');
	unshift(@INC,$BASE . '/lib/sensors');
}

use OneWireNet;
use DS18B20;
use DS18S20;
use DS2438;
use DS2450;
use DS2423;
use DS2405;

my $sleeptime = 10;	# sleep 10 seconds between every device scan

my $stopfile = '/home/pi/1wirestop';
print "1wire script starts\n";

print "stopfile=$stopfile\n\n";

DateTime::TimeZone->names_in_country( "SE" );
my $dt = DateTime->now;
$dt->set_time_zone( 'Europe/Stockholm' );

my %devicesqltable =	(
#USB
				'28.604E70020000' => {					# DS18B20
							tablename =>	'anlis_rum',	# db table name
							alias => 	'anlis rum',	# Alias
						},
				'20.8E0014000000' => {					# DS2450
							tablename =>	'ljusmatare_DS2450',
							alias => 	'ljustmätning',
						},
#				'20.8E0014000000' => {					# DS2450
#							tablename =>	'ljus',
#							alias => 	'ljustmätning',
#						},
				'28.1A5E70020000' => {					# DS18B20
							tablename =>	'ljustemp',
							alias => 	'ljustemperatur',
						},
				'28.1B6170020000' => {					# DS18B20
							tablename =>	'sovrum',
							alias => 	'sovrum',
						},
				'10.67C6697351FF' => {					# DS18S20
							tablename =>	'',
							alias => 	'usb_okand1_DS18S20',
						},
#serial1
				'05.4AEC29CDBAAB' => {					# DS2405_addressable_switch
							tablename =>	'',
							alias => 	'serial1_okand1', 
						},
				'10.67C6697351FF' => {					# DS18S20
							tablename =>	'',
							alias => 	'serial1_okand2_DS18S20',
						},
				'1D.D3B20D000000' => {					# DS2423
							tablename =>	'elmatare',
							alias => 	'elmätare',
						},
				'26.5B2E11010000' => {					# DS2438
							tablename =>	'fuktmatare_DS2438',
							alias => 	'fuktmätning',
						},
#				'26.5B2E11010000' => {					# DS2438
#							tablename =>	'badrumsfukt',
#							alias => 	'badrumsfukt',
#						},
				'28.379F70020000' => {					# DS18B20
							tablename =>	'foradstemp',
							alias => 	'foradstemp',
						},
				'28.EC5470020000' => {					# DS18B20
							tablename =>	'badrumstemp',
							alias => 	'badrumstemp',
						},
#serial2
				'10.C58384010800' => {					# DS18S20
							tablename =>	'utetemp',
							alias => 	'utetemp',
						},
				'10.728892010800' => {					# DS18S20
							tablename =>	'arbetsrum',
							alias => 	'arbetsrum',
						},
				'10.67C6697351FF' => {					# DS18S20
							tablename =>	'',
							alias => 	'serial2_okand1',
						},
				'05.4AEC29CDBAAB' => {					# DSDS2405_addressable_switch
							tablename =>	'',
							alias => 	'serial2_okand2',
						},
			);
undef %devicesqltable;

my $onewire = new OneWireNet( '/mnt', 'measure');
my $exitflag = 0;
my $datetimestring;
my $minute = $dt->strftime('%M');
my $lastminute = -1;

$onewire->connectToMySql('access/accessDB');
#my %dev = (	'DUMMY_ADDRESS' => {					# DS18B20
#					tablename =>	'DUMMY_TABLE',	# db table name
#					alias => 	'DUMMY ROOM',	# Alias
#					type => 	'DUMMY_TYPE',	# Alias
#					address =>	'DUMMY_ADDRESS',
#					host =>		'DUMMY_HOST'
#				}
#			);

#$onewire->addNewDeviceInfo(\%dev,\%devicesqltable);
$onewire->readDeviceInfo(\%devicesqltable);
$onewire->disconnectFromMySql;
#exit;

print "Wait until a new minute starts....\n";
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
printf("Time: %02d:%02d:%02d\n", $hour, $min, $sec);
my $wait = 60-$sec;
if ($wait < 60){
	print "Sleeping $wait seconds.\n";
	sleep ($wait);
}
print "Contiueing\n";
($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
printf("Time:	%02d:%02d:%02d\n", $hour, $min, $sec);
my $inserted;

while ( $exitflag == 0) {
	if ( -e $stopfile){
		print "stop\n";
		$exitflag = 1;
		last;
	}
	$dt = DateTime->now;
	$datetimestring = $dt->strftime('%Y-%m-%d %H-%M-%S');
	$minute = $dt->strftime('%M');
	print "minute=$minute	lastminue=$lastminute	$datetimestring\n";
	if ( $minute != $lastminute ){
		$onewire->scanForSensors();
		$onewire->createAllObjects();
		$onewire->updateDevicesWithTableNames(\%devicesqltable);
		$onewire->updateDevicesWithAliases(\%devicesqltable);
		$onewire->fetchAllValues();
		$onewire->printAllMeasurements;
		$lastminute = $minute;
	}else {
		print "Wait until a new minute starts....\n";
		($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
		printf("Time: %02d:%02d:%02d\n", $hour, $min, $sec);
		$wait = 60-$sec;
		if ($wait < 60){ 
			$lastminute = $min;
			print "sleeping $wait seconds.\n";              
			sleep ($wait);  
		}
		print "Contiueing\n";        
		($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
		printf("Time:   %02d:%02d:%02d\n", $hour, $min, $sec);
		$minute = $min;
		undef $inserted;
	}
	if ($minute % 5 == 0 and !defined $inserted){
		$onewire->connectToMySql('access/accessDB');
#		$onewire->updateSQLWithDevices(\%devicesqltable);
		$onewire->insertRowToDB("row");
		$onewire->disconnectFromMySql;
		$inserted = 1;
	}
}
exit;

