package DS2438;
use OneWireDevice;
use strict;
our @ISA = qw(OneWireDevice);
use DateTime;
use DBI;
use DBD::mysql;
use DBI qw(:sql_types);

sub new
{
	my $class = shift;
	my $self = $class->SUPER::new('DS2438',@_);
	bless $self, $class;
	return $self;
}

sub getTemperature {
	my( $self ) = @_;
	return $self->{_temperature};
}

sub setHumidity {
	my ( $self, $temp ) = @_;
	$self->{_humidity} = $temp if defined($temp);
	return $self->{_humidity};
}
sub getHumidity {
	my( $self ) = @_;
	return $self->{_humidity};
}

sub fetchAllValues {
	my( $self ) = @_;
	_waitUntilSensorExists();
	if ( _directoryExists($self->{_basedir} ) ){
		$self->{_temperature} = $self->getValue("$self->{_basedir}\/$self->{_Address}\/temperature");
		$self->{_humidity} = $self->getValue("$self->{_basedir}\/$self->{_Address}\/humidity");
		$self->{_HIH3600_humidity} = $self->getValue("$self->{_basedir}\/$self->{_Address}\/HIH3600\/humidity");
		$self->{_HIH4000_humidity} = $self->getValue("$self->{_basedir}\/$self->{_Address}\/humidity");
		$self->{_HTM1735_humidity} = $self->getValue("$self->{_basedir}\/$self->{_Address}\/humidity");
		$self->{_B1R1A_pressure} = $self->getValue("$self->{_basedir}\/$self->{_Address}\/B1-R1-A\/pressure");
		$self->{_B1R1A_gain} = $self->getValue("$self->{_basedir}\/$self->{_Address}\/B1-R1-A\/gain");
		$self->{_B1R1A_offset} = $self->getValue("$self->{_basedir}\/$self->{_Address}\/B1-R1-A\/offset");
		$self->{_S3R1A_current} = $self->getValue("$self->{_basedir}\/$self->{_Address}\/S3-R1-A\/current");
		$self->{_S3R1A_illuminance} = $self->getValue("$self->{_basedir}\/$self->{_Address}\/S3-R1-A\/illuminance");
		$self->{_S3R1A_gain} = $self->getValue("$self->{_basedir}\/$self->{_Address}\/S3-R1-A\/gain");
	}else{
		print "Device $self->{_basedir} does not exist\n";
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
#	while ($unhappy){
		if (-d $file){
			$unhappy = 0;
		}else{
			print "Device is not ready, sleeping 1s.	" . `date`;
#			sleep (1);
		}
#	}
}

sub printAllMeasurements {
	my( $self ) = @_;
	$self->SUPER::printAllMeasurements();
	print "temperature:	$self->{_temperature}\n";
	print "humidity:	$self->{_humidity}\n";
	print "HIH3600_humidity:	$self->{_HIH3600_humidity}\n";
	print "HIH4000_humidity:	$self->{_HIH4000_humidity}\n";
	print "HTM1735_humidity:	$self->{_HTM1735_humidity}\n";
	print "B1R1A_pressure:	$self->{_B1R1A_pressure}\n";
	print "B1R1A_offset:	$self->{_B1R1A_offset}\n";
	print "B1R1A_gain:	$self->{_B1R1A_gain} \n";
	print "S3R1A_current:	$self->{_S3R1A_current}\n";
	print "S3R1A_illuminance:	$self->{_S3R1A_illuminance}\n";
	print "S3R1A_gain:	$self->{_S3R1A_gain}\n";
}
sub insertRowToDB {
	my ( $self,$dbh ) = @_;
	if ( defined $dbh ) {
		$self->SUPER::insertRowToDB($dbh);
		DateTime::TimeZone->names_in_country( "SE" );
		my $dt = DateTime->now;
		$dt->set_time_zone( 'Europe/Stockholm' );
		my $datetimestring = $dt->strftime('%Y-%m-%d %H-%M-%S');
		my $temp = sprintf("%.1f",$self->{_temperature});
		my $humidity = sprintf("%.1f",$self->{_humidity});
		my $pressure = sprintf("%.1f",$self->{_B1R1A_pressure});
		my $illuminance = sprintf("%.1f",$self->{_S3R1A_illuminance});
		if ( $self->{_TableName} !~ /^$/ ){
			print "DS2438::inserted $temp,$humidity,$pressure,$illuminance to $self->{_TableName} at $datetimestring\n";

			$dbh->do("INSERT INTO $self->{_TableName} VALUES (DEFAULT,\"$datetimestring\",$temp,$humidity,$pressure,$illuminance);");
		} else {
			print "DS2438::No table name is defined for $self->{_Address} ($self->{_Alias}\n";
		}
	}else {
		print "DS2438::No active db handler. You need to connect to db with 'connectToMySql' first.\n";
	}
	return $self;
}

1;

