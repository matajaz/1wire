package OneWireDevice;
use strict;
use Exporter;
use vars qw(@ISA @EXPORT @EXPORT_OK);
@ISA = qw( Exporter );
@EXPORT = qw( getValue );  # symbols to export on request

sub new
{
	my $class = shift;
	my $self = {
		_Type => shift,
		_Address => shift,
		_basedir => shift,
		_TableName => shift,
		_Alias => shift,
		_ExtraInfo => shift,
	};
	$self->{_hostName} = `hostname`;
	chomp $self->{_hostName};
	$self->{_tempvalue} = -1;
	
	bless $self, $class;
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
sub setTableName {
	my ( $self, $name ) = @_;
	$self->{_TableName} = $name if defined($name);
	return $self->{_TableName};
}
sub getTableName {
	my( $self ) = @_;
	return $self->{_TableName};
}
sub setAddress {
	my ( $self, $name ) = @_;
	$self->{_Address} = $name if defined($name);
	return $self->{_Address};
}
sub getAddress {
	my( $self ) = @_;
	return $self->{_Address};
}
sub setAlias {
	my ( $self, $name ) = @_;
	$self->{_Alias} = $name if defined($name);
	return $self->{_Alias};
}
sub getAlias {
	my( $self ) = @_;
	return $self->{_Alias};
}
sub setType {
	my ( $self, $type ) = @_;
	$self->{_Type} = $type if defined($type);
	return $self->{_Type};
}
sub getType {
	my( $self ) = @_;
	return $self->{_Type};
}
sub setHost {
	my ( $self ) = @_;
	$self->{_hostName} = `hostname`;
	chomp $self->{_hostName};
	return $self->{_hostName};
}
sub getHost {
	my( $self ) = @_;
	return $self->{_hostName};
}

sub fetchAllValues {
	my( $self ) = @_;
	_waitUntilSensorExists();
	if ( _directoryExists($self->{_basedir}) ){
		print "Device $self->{_Address} ($self->{_Alias}) in $self->{_basedir} exists in $self->{_hostName}\n";
	}else{
		print "Device $self->{_basedir} does not exist in $self->{_hostName}\n";
	}
	return $self;
}
sub _directoryExists {
	my $file = shift;
	if (-d $file){
		return 1;
	}else{
		return 0;
	}
}
sub _waitUntilSensorExists {
	my $file = shift;
	my $unhappy = 1;
	my $timeout = 1000;
	my $cnt = 0;
#	while ($unhappy){
#		if (-d $file){
#			$unhappy = 0;
#		}else{
#			print "Device is not ready, sleeping 1s.	" . `date`;
#			$cnt++;
#			sleep (1);
#		}
#		if ( $cnt >= $timeout ){
#			last;
#		}
#	}
}

sub getValue {
	my( $self,$file ) = @_;
	my $result = "N/A";
	if (-e $file){
		$result = `cat $file`;
		chomp $result;
		if ($result eq 85){
			$result = $self->{_tempvalue};	# Something has gone wrong reading the temp so use last valid measurement.
		}else{
			$self->{_tempvalue} = $result;
		}
	}
	return $result;
}
sub readFile {
	my( $self,$file ) = @_;
	my $result = "N/A";
	if (!defined $self->{_basedir}){
		$self->{_basedir} = "/mnt/1wire";
	}
	my $file = "$self->{_basedir}\/$file";
	if (-e $file){
		$result = `cat $file`;
		chomp $result;
	}else { 
		print "$file does not exist!\n";
	}
	return $result;
}
sub get1wireReadAttempts {
	my( $self ) = @_;
	$self->{_readattempts} = $self->readFile("statistics/read/calls");
	return $self->{_readattempts};
}
sub get1wireReadSuccesses {
	my( $self ) = @_;
	$self->{_readsuccesses} = $self->readFile("statistics/read/success");
	return $self->{_readsuccesses};
}
sub get1wireReadAttemptTry0 {
	my( $self ) = @_;
	$self->{_readattempttries0} = $self->readFile("statistics/read/tries.0");
	return $self->{_readattempttries0};
}
sub get1wireReadAttemptTry1 {
	my( $self ) = @_;
	$self->{_readattempttries1} = $self->readFile("statistics/read/tries.1");
	return $self->{_readattempttries1};
}
sub get1wireReadAttemptTry2 {
	my( $self ) = @_;
	$self->{_readattempttries2} = $self->readFile("statistics/read/tries.2");
	return $self->{_readattempttries2};
}
sub get1wireReadCacheSuccesses {
	my( $self ) = @_;
	$self->{_readcachesuccesses} = $self->readFile("statistics/read/cachesuccess");
	return $self->{_readcachesuccesses};
}
sub get1wire1stAttemptSuccessRate {
# echo "scale=2; 100*(`cat $path/statistics/read/tries.0`-`cat $path/statistics/read/tries.1`)/`cat $path/statistics/read/calls`" | bc
	my( $self ) = @_;
	print "self=$self\n";
	my $val0 = $self->get1wireReadAttemptTry0();
	my $val1 = $self->get1wireReadAttemptTry1();
	my $result = ($val0-$val1) / $self->get1wireReadAttempts();
	return $result;
}
sub get1wire2ndAttemptSuccessRate {
	my( $self ) = @_;
	my $val1 = $self->get1wireReadAttemptTry1();
	my $val2 = $self->get1wireReadAttemptTry2();
	my $result = ($val1-$val2) / $self->get1wireReadAttempts();
	return $result;
}
sub get1wire3rdAttemptSuccessRate {
	my( $self ) = @_;
	my $val1 = $self->get1wireReadAttemptTry2();
	my $val2 = $self->get1wireReadAttempts();
	my $val3 = $self->get1wireReadSuccesses();
	my $result = ($val1-($val2-$val3)) / $self->get1wireReadAttempts();
	return $result;
}
sub get1wireCacheSuccessRate {
	my( $self ) = @_;
	my $result = $self->get1wireReadCacheSuccesses() / $self->get1wireReadAttempts();
	return $result;
}
sub get1wireFailureRate {
	my( $self ) = @_;
	my $result = ($self->get1wireReadAttempts() - $self->get1wireReadSuccesses() ) / $self->get1wireReadAttempts();
	return $result;
}

sub printAllMeasurements {
	my( $self ) = @_;
	print "\nType:		$self->{_Type}";
	if ($self->{_Alias}) {
		print "	($self->{_Alias})";
	}
	if ($self->{_ExtraInfo}) {
		print "	($self->{_ExtraInfo})";
	}
	print "\n";
	print "Address:	$self->{_Address}\n";
	print "Mount point:	$self->{_basedir}\n";
	print "Host name: 	$self->{_hostName}\n";
	print "Number of 1wire read attempts: " . $self->get1wireReadAttempts() . "\n";
	printf ("1Wire 1st attempt success rate = %.2f %\n", $self->get1wire1stAttemptSuccessRate()*100 );
	printf ("1Wire 2nd attempt success rate = %.2f %\n", $self->get1wire2ndAttemptSuccessRate()*100 );
	printf ("1Wire 3rd attempt success rate = %.2f %\n", $self->get1wire3rdAttemptSuccessRate()*100 );
	printf ("1Wire cache success rate = %.2f %\n", $self->get1wireCacheSuccessRate()*100 );
	printf ("1Wire failure rate = %.2f %\n", $self->get1wireFailureRate()*100 );
}

#my %dev = (	'DUMMY_ADDRESS' => {					# DS18B20
#					tablename =>	'DUMMY_TABLE',	# db table name
#					alias => 	'DUMMY ROOM',	# Alias
#					type => 	'DUMMY_TYPE',	# Alias
#					address =>	'DUMMY_ADDRESS',
#					host =>		'DUMMY_HOST'
#				}
#			);

sub doesDeviceExistInDB
{
	my ( $self,$dbh ) = @_;
	my $result;
	if ( defined $dbh ) {
		my $sqlquery = "SELECT SensorIndex,Address FROM sensors WHERE address = \"$self->{_Address}\"";

#		print "sqlquery: $sqlquery\n";
		my $sth = $dbh->prepare($sqlquery)
			or die "Couldn't prepare statement: " . $dbh->errstr;

		my @sqlresult = $sth->execute() or die "Couldn't execute statement: " . $sth->errstr;
		while (my @row = $sth->fetchrow_array) {
			$result = $row[0];
			chomp $result;
			$self->{_Index} = $result;
			print "Device $self->{_Address} exists in DB with index $self->{_Index}\n";
		}
		my $res = "@sqlresult";
		if ($res =~/1/){
#			print "Device $self->{_Address} exists in DB\n";
#			$result = 1;
		}else{
			print "Device $self->{_Address} does not exist in DB\n";
		}
	}else {
		print "Device::No active db handler. You need to connect to db with 'connectToMySql' first.\n";
	}
	return $result;	#returns SensorIdex if sensor exist in DB
}
sub addDeviceToSensorTable {
	my ( $self,$dbh ) = @_;
	if ( defined $dbh ) {
		my $sqlquery = "INSERT INTO sensors (Type, Address, TableName, Alias, Host) VALUES ( \"$self->{_Type}\", \"$self->{_Address}\", \"$self->{_TableName}\", \"$self->{_Alias}\", \"$self->{_hostName}\" );";

		my $sth = $dbh->prepare($sqlquery)
			or die "Couldn't prepare statement: " . $dbh->errstr;

		my @sqlresult = $sth->execute() or die "Couldn't execute statement: " . $sth->errstr;
		print "Device::inserted new sensor of type $self->{type} with address $self->{_Address} to table sensors\n";

	}else {
		print "Device::No active db handler. You need to connect to db with 'connectToMySql' first.\n";
	}
	return $self;
}

sub insertRowToDB {
	my ( $self,$dbh ) = @_;
	if ( defined $dbh ) {
		my $readattempts = $self->get1wireReadAttempts() ;
		my $readsuccess1 = sprintf ( "%.2f" , $self->get1wire1stAttemptSuccessRate()*100 );
		my $readsuccess2 = sprintf ( "%.2f" , $self->get1wire2ndAttemptSuccessRate()*100 );
		my $readsuccess3 = sprintf ( "%.2f" , $self->get1wire3rdAttemptSuccessRate()*100 );
		my $readcachesuccess = sprintf ( "%.2f" , $self->get1wireCacheSuccessRate()*100 );
		my $readfailrate = sprintf ( "%.2f" , $self->get1wireFailureRate()*100 );
		DateTime::TimeZone->names_in_country( "SE" );
		my $dt = DateTime->now;
		$dt->set_time_zone( 'Europe/Stockholm' );
		my $datetimestring = $dt->strftime('%Y-%m-%d %H-%M-%S');
		if ( $self->{_TableName} !~ /^$/ ){
			print "$self->{_Type}::inserted 1wire read attempts $readattempts to $self->{_TableName} at $datetimestring\n";
			print "$self->{_Type}::inserted 1wire 1st attempt successes $readsuccess1 to $self->{_TableName} at $datetimestring\n";
			print "$self->{_Type}::inserted 1wire 2nd attempt successes $readsuccess2 to $self->{_TableName} at $datetimestring\n";
			print "$self->{_Type}::inserted 1wire 3rd attempt successes $readsuccess3 to $self->{_TableName} at $datetimestring\n";
			print "$self->{_Type}::inserted 1wire cache successes $readcachesuccess to $self->{_TableName} at $datetimestring\n";
			print "$self->{_Type}::inserted 1wire failure successes $readfailrate to $self->{_TableName} at $datetimestring\n";

			my $sqlquery = "INSERT INTO OneWireStats (SensorIndex, Timestamp, ReadAttempts, Read1stAttemptSuccessRatio, Read2ndtAttemptSuccessRatio, Read3rdAttemptSuccessRatio, ReadCacheSuccessRate, ReadFailureRate ) VALUES ( $self->{_Index}, \"$datetimestring\", $readattempts, $readsuccess1, $readsuccess2, $readsuccess3, $readcachesuccess, $readfailrate);";
#print "sqlquery=$sqlquery\n\n";
			my $sth = $dbh->prepare($sqlquery)
				or die "Couldn't prepare statement: " . $dbh->errstr;

			my @sqlresult = $sth->execute() or die "Couldn't execute statement: " . $sth->errstr;
		}
#		$dbh->do("INSERT INTO $self->{_TableName} VALUES (DEFAULT,\"$datetimestring\",$temp);");
#		} else {
#			print "DS18B20::No table name is defined for $self->{_Address} ($self->{_Alias}\n";
#		}
	}else {
		print "1WireDevice::No active db handler. You need to connect to db with 'connectToMySql' first.\n";
	}
	return $self;
}

1;


