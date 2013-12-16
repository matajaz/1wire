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
		_ExtraInfo => shift
	};
	$self->{_hostName} = `hostname`;
	chomp $self->{_hostName};
	
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
	}
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
		my $sqlquery = "SELECT Address FROM sensors WHERE address = \"$self->{_Address}\"";

print "sqlquery: $sqlquery\n";
		my $sth = $dbh->prepare($sqlquery)
			or die "Couldn't prepare statement: " . $dbh->errstr;

		my @sqlresult = $sth->execute() or die "Couldn't execute statement: " . $sth->errstr;
		my $res = "@sqlresult";
		if ($res =~/1/){
			print "Device $self->{_Address} exists in DB\n";
			$result = 1;
		}else{
			print "Device $self->{_Address} does not exist in DB\n";
		}
	}else {
		print "Device::No active db handler. You need to connect to db with 'connectToMySql' first.\n";
	}
	return $result;
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
1;


