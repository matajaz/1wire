package OneWireNet;
use strict;
use Exporter;
use vars qw(@ISA @EXPORT @EXPORT_OK);
use Switch;

use DBI;
use DBD::mysql;
use DBI qw(:sql_types);
use Sys::Syslog;

use DS18B20;
use DS18S20;
use DS2438;
use DS2450;
use DS2423;
use DS2405;
use DS9490;	#USB 1-wire adapter
use hallon;

#our @ISA = qw(OneWireDevice);

#@ISA = qw(Exporter);
#@EXPORT = qw(connectToMySql);  # symbols to export on request

my %sensors;
my %sensorfamily = (
			'10' => 'DS18S20',	# High-Precision 1-Wire Digital Thermometer
			'05' => 'DS2405',	# Addressable switch
			'20' => 'DS2450',	# Quad A/D Converter
			'81' => 'DS9490',	# USB 1-wire adapter
			'28' => 'DS18B20',	# Programmable Resolution 1-Wire Digital Thermometer
			'26' => 'DS2438',	# Smart Battery Monitor
			'1D' => 'DS2423',	# 4kbit 1-Wire RAM with Counter
			'HOST' => 'HOST' # Raspberry host
		);
	
sub new
{
	my $class = shift;
	my $self = {
		_MountDir => shift,
		_DBName => shift,
		_Alias => shift,
		_ExtraInfo => shift
	};
	$self->{_dbh} = 0;

	my $hostname = `hostname`;
	chomp $hostname;
	$sensors{$hostname}{PATH} = "/home/pi/";
	$sensors{$hostname}{TYPE} = "HOST";
	$sensors{$hostname}{READY} = 0;
	$sensors{$hostname}{OBJECT} = new HALLON( $hostname,$sensors{$hostname}{PATH} );
	#$sensors{$hostname}{OBJECT}->setAddress($hostname);

	bless $self, $class;
	return $self;
}
sub scanForSensors {
	my ( $self ) = @_;
	if (-d $self->{_MountDir} ) {
		opendir(DIR, $self->{_MountDir});
		if (! -e $self->{_MountDir}){
			print "Can't access $self->{_MountDir}\n";
		}
		print "First scanning in $self->{_MountDir}\n";
		my @dirs = readdir(DIR);
		foreach my $onewiredir (@dirs){
			print "Second scanning: $onewiredir\n";
			if ($onewiredir =~ /(1wire\S*)/){
				opendir(DIR2, "$self->{_MountDir}\/$onewiredir" );
				my @files = readdir(DIR2);
				foreach my $device (@files){
					print "Scanning device $device\n";
					if ($device =~ /^(\d\S+)/){
						if ( !defined $sensors{$device}{READY} or $sensors{$device}{READY} == 0 ) {
							my $family = substr($device,0,2);
							$sensors{$device}{PATH} = "$self->{_MountDir}\/$onewiredir";
#							$sensors{$device}{PATH} = "$self->{_MountDir}\/$onewiredir\/$device";
							$sensors{$device}{TYPE} = "$sensorfamily{$family}";
							$sensors{$device}{READY} = 0;
							print "Found $device	$sensors{$device}{TYPE}\n";
						}
					}
				}
				closedir(DIR2);
			}
		}
		closedir(DIR);
	}else{
		print "There is no mount dir specified for 1wire devices.\n\n";
	}
	return $self;
}
sub createAllObjects {
	my ( $self ) = @_;
	$self->connectToMySql('access/accessDB');
	foreach my $sensor (keys %sensors) {
		my $object;
		if ( !defined $sensors{$sensor}{READY} or $sensors{$sensor}{READY} == 0 ) {
			switch ($sensors{$sensor}{TYPE}) {
				case ('DS2438')	{ $object = new DS2438(  $sensor,$sensors{$sensor}{PATH}); }
				case ('DS18B20'){ $object = new DS18B20( $sensor,$sensors{$sensor}{PATH}); }
				case ('DS18S20'){ $object = new DS18S20( $sensor,$sensors{$sensor}{PATH}); }
				case ('DS2450')	{ $object = new DS2450(  $sensor,$sensors{$sensor}{PATH}); }
				case ('DS2423')	{ $object = new DS2423(  $sensor,$sensors{$sensor}{PATH}); }
#
				case ('DS2405')	{ $object = new DS2405(  $sensor,$sensors{$sensor}{PATH}); }
				case ('DS9490')	{ $object = new DS9490(  $sensor,$sensors{$sensor}{PATH}); }
				case ('HOST')	{ $object = new HALLON(  $sensor,$sensors{$sensor}{PATH}); }
			}
			$sensors{$sensor}{OBJECT} = $object;
			$sensors{$sensor}{READY} = 0;
			print "sensor=$sensor,	object=$object,	type=$sensors{$sensor}{TYPE}\n";
			$object->setAddress($sensor);
			print "Created $sensor, with address " . $sensors{$sensor}{OBJECT}->getAddress() . "\n";
			if (!$object->doesDeviceExistInDB($self->{_dbh})){
				$object->addDeviceToSensorTable($self->{_dbh})
			}
		}
	}
	$self->disconnectFromMySql();
}
sub updateDevicesWithTableNames {
	my ($self,$hashref) = @_;
	foreach my $sensor (keys %sensors) {
		$sensors{$sensor}{OBJECT}->setTableName(${$hashref}{$sensor}{tablename});
	}
	return $self;
}
sub updateDevicesWithAliases {
	my ($self,$hashref) = @_;
	foreach my $sensor (keys %sensors) {
		$sensors{$sensor}{OBJECT}->setAlias(${$hashref}{$sensor}{alias});
	}
	return $self;
}

sub setBaseDir {
	my ( $self, $dir ) = @_;
	$self->{_basedir} = $dir if defined($dir);
	return $self->{_basedir};
}
sub getBasedir {
	my( $self ) = @_;
	return $self->{_basedir};
}

sub fetchAllValues {
	my( $self ) = @_;
	foreach my $sensor (keys %sensors) {
		if ( !defined $sensors{$sensor}{READY} or $sensors{$sensor}{READY} == 0 ) {
			$sensors{$sensor}{OBJECT}->fetchAllValues();
		}else {
			print "Sensor $sensors{$sensor}{OBJECT}->{_Address} ($sensors{$sensor}{OBJECT}->{_Alias}) is already done, READY=$sensors{$sensor}{READY}.\n";
		}
		$sensors{$sensor}{READY} = 1

	}
	return $self;
}
sub printAllMeasurements {
	my( $self ) = @_;
	foreach my $sensor (keys %sensors) {
		$sensors{$sensor}{OBJECT}->printAllMeasurements();
	}
}

sub logit {
	my ($priority, $msg) = @_; 
	return 0 unless ($priority =~ /info|err|debug/);
	setlogsock('unix');
	my $programname = $0;
	my $pid = $$;
	# $programname is assumed to be a global.  Also log the PID
	# and to CONSole if there's a problem.  Use facility 'user'.
	openlog($programname, 'pid,cons', 'user');
	syslog($priority, $msg);
	closelog();
	return 1;
}

sub connectToMySql {
	my( $self,$accessfile ) = @_;
	open(ACCESS_INFO, "<$accessfile") || die "Can't access login credentials";
	my $database = <ACCESS_INFO>;
	my $host = <ACCESS_INFO>;
	my $userid = <ACCESS_INFO>;
	my $passwd = <ACCESS_INFO>;
	close (ACCESS_INFO);
	chomp $database;
	chomp $host;
	chomp $userid;
	chomp $passwd;

	my $dbh;
	until ( $dbh = DBI->connect(
		"DBI:mysql:database=$database;host=$host",
		"$userid",
		"$passwd",
		{ RaiseError => 0, AutoCommit => 1, PrintError => 0 },
	)) {
		warn "Can't connect: $DBI::errstr. Pausing before retrying.\n";
		logit('err', "Error connecting to db $database at hot $host: $!");
		sleep( 5 );
	}

      eval {      ### Catch _any_ kind of failures from the code within

          ### Enable auto-error checking on the database handle
          $dbh->{PrintError} = 1;
          $dbh->{RaiseError} = 1;

	}; warn "Monitoring aborted by error: $@\n" if $@;

# or die "Could not connect to database: $DBI::errstr";;

	$dbh->{PrintError} = 1;
	$dbh->{RaiseError} = 1;
	$self->{_dbh} = $dbh;
	print "Connected successfully to SQL DB\n";
	return $self;
}
sub disconnectFromMySql {
	my ( $self,$row ) = @_;
	$self->{_dbh}->disconnect();
	undef $self->{_dbh};
	print "Disconnected from SQL DB\n";
	undef $self->{_dbh};
	return $self;
}
sub readDeviceInfo
{
	my ($self,$tableref) = @_;
	if ( defined $self->{_dbh} ) {
		my $sth = $self->{_dbh}->prepare('SELECT * FROM sensors')
                or die "Couldn't prepare statement: " . $self->{_dbh}->errstr;

		my @sqlresult = $sth->execute() or die "Couldn't execute statement: " . $sth->errstr;
		while (@sqlresult = $sth->fetchrow_array()) {
			my $index = $sqlresult[0];
			my $type = $sqlresult[1];
			my $address = $sqlresult[2];
			my $tablename = $sqlresult[3];
			my $alias = $sqlresult[4];
			my $host = $sqlresult[5];
			${$tableref}{$address}{index} = $index;
			${$tableref}{$address}{type} = $type;
			${$tableref}{$address}{tablename} = $tablename;
			${$tableref}{$address}{alias} = $alias;
			${$tableref}{$address}{host} = $host;
		}
		
		print "=========== The following sensors were found in DB sensor table ===========\n";
		foreach my $sensor (sort keys %$tableref) {
			print "Index: ${$tableref}{$sensor}{index},	Type: ${$tableref}{$sensor}{type},	Address: $sensor,	Table name: ${$tableref}{$sensor}{tablename},	Alias = ${$tableref}{$sensor}{alias}\n";
		}
	}
}
sub addNewDeviceInfo
{
	my ($self,$deviceref,$tableref) = @_;
	if ( defined $self->{_dbh} ) {
		my $addr;
		foreach my $key (keys %$deviceref){
			print "addr=$key\n";
			$addr = $key;
		}
		$addr = $deviceref->{$addr}->{address};
		my $type = $deviceref->{$addr}->{type};
		my $tablename = $deviceref->{$addr}->{tablename};
		my $alias = $deviceref->{$addr}->{alias};

		print "devinfo:	type=$type, addr=$addr, table=$tablename, alias=$alias\n";
		my $sqlquery = "INSERT INTO sensors (Type, Address, TableName, Alias) VALUES ( \"$type\", \"$addr\", \"$tablename\", \"$alias\" );";
#		my $sqlquery = "INSERT INTO sensors SET Type=\"$deviceref->{$addr}->{type}\", Address=\"$deviceref->{$addr}->{address}\", TableName=\"$deviceref->{$addr}->{tablename}\", Alias=\"$deviceref->{$addr}->{alias}\";";
		print "sqlquery=$sqlquery\n";
		my $sth = $self->{_dbh}->prepare($sqlquery)
			or die "Couldn't prepare statement: " . $self->{_dbh}->errstr;

		my @sqlresult = $sth->execute() or die "Couldn't execute statement: " . $sth->errstr;
#		${$tableref}{$addr}{index} = $index;	#not know at this stage
		${$tableref}{$addr}{type} = $type;
		${$tableref}{$addr}{tablename} = $tablename;
		${$tableref}{$addr}{alias} = $alias;
		
		print "=========== The following sensors were found in DB sensor table ===========\n";
		foreach my $sensor (sort keys %$tableref) {
			print "Index: ${$tableref}{$sensor}{index},	Type: ${$tableref}{$sensor}{type},	Address: $sensor,	Table name: ${$tableref}{$sensor}{tablename},	Alias = ${$tableref}{$sensor}{alias}\n";
		}
		print "Successfully added $type, $addr, $tablename, $alias to sensors\n";
	}
}
sub insertRowToDB {
	my ( $self, $row) = @_;
	if ( defined $self->{_dbh} ) {
#		print "insert row, dbh is defined, sensors=" . %sensors . "\n";;
		foreach my $sensor (keys %sensors) {
			if ( $sensors{$sensor}{READY} == 1 ) {
				print "insert rows to DB $sensors{$sensor}{OBJECT}->getType\n";
				switch ($sensors{$sensor}{OBJECT}->getType) {
					case ('DS18B20')	{ $sensors{$sensor}{OBJECT}->insertRowToDB($self->{_dbh}); }
					case ('DS18S20')	{ $sensors{$sensor}{OBJECT}->insertRowToDB($self->{_dbh}); }
					case ('DS2423')		{ $sensors{$sensor}{OBJECT}->insertRowToDB($self->{_dbh}); }
					case ('DS2438')		{ $sensors{$sensor}{OBJECT}->insertRowToDB($self->{_dbh}); }
					case ('DS2450')		{ $sensors{$sensor}{OBJECT}->insertRowToDB($self->{_dbh}); }
					case ('HOST')		{ $sensors{$sensor}{OBJECT}->insertRowToDB($self->{_dbh}); }
				}
				$sensors{$sensor}{READY} = 0;
			}
		}
	}else {
		print "OneWireNet::No active db handler. You need to connect to db with 'connectToMySql' first.\n";
	}
	return $self;
}
1;


