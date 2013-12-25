package DS2450;
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
	my $self = $class->SUPER::new('DS2450',@_);
	bless $self, $class;
	return $self;
}

sub getVolt {
	my ( $self, $volt ) = @_;
	return $self->{"$volt"};
}

sub fetchAllValues {
	my( $self ) = @_;
	$self->{_voltA} = $self->getValue("$self->{_basedir}\/$self->{_Address}\/volt\.A");
	$self->{_voltB} = $self->getValue("$self->{_basedir}\/$self->{_Address}\/volt\.B");
	$self->{_voltC} = $self->getValue("$self->{_basedir}\/$self->{_Address}\/volt\.C");
	$self->{_voltD} = $self->getValue("$self->{_basedir}\/$self->{_Address}\/volt\.D");
	$self->{_volt2A} = $self->getValue("$self->{_basedir}\/$self->{_Address}\/volt2\.A");
	$self->{_volt2B} = $self->getValue("$self->{_basedir}\/$self->{_Address}\/volt2\.B");
	$self->{_volt2C} = $self->getValue("$self->{_basedir}\/$self->{_Address}\/volt2\.C");
	$self->{_volt2D} = $self->getValue("$self->{_basedir}\/$self->{_Address}\/volt2\.D");
	return $self;
}

sub printAllMeasurements {
	my( $self ) = @_;
	$self->SUPER::printAllMeasurements();
	print "volt.A:	$self->{_voltA}\n";
	print "volt.B:	$self->{_voltB}\n";
	print "volt.C:	$self->{_voltC}\n";
	print "volt.D:	$self->{_voltD}\n";
	print "volt2.A:	$self->{_volt2A}\n";
	print "volt2.B:	$self->{_volt2B}\n";
	print "volt2.C:	$self->{_volt2C}\n";
	print "volt2.D:	$self->{_volt2D}\n";
}

sub insertRowToDB {
	my ( $self,$dbh ) = @_;
	if ( defined $dbh ) {
		$self->SUPER::insertRowToDB($dbh);
		DateTime::TimeZone->names_in_country( "SE" );
		my $dt = DateTime->now;
		$dt->set_time_zone( 'Europe/Stockholm' );
		my $datetimestring = $dt->strftime('%Y-%m-%d %H-%M-%S');
		if ( $self->{_TableName} !~ /^$/ ){
			print "DS2450::inserted $self->{_voltA},$self->{_voltB},$self->{_voltC},$self->{_volt2D},$self->{_volt2A},$self->{_volt2B},$self->{_volt2C},$self->{_voltD} to $self->{_TableName} at $datetimestring\n";

			$dbh->do("INSERT INTO $self->{_TableName} VALUES (DEFAULT,\"$datetimestring\",$self->{_voltA},$self->{_voltB},$self->{_voltC},$self->{_voltD},$self->{_volt2A},$self->{_volt2B},$self->{_volt2C},$self->{_volt2D});");
		} else {
			print "DS2450::No table name is defined for $self->{_Address} ($self->{_Alias}\n";
		}
	}else {
		print "DS2450::No active db handler. You need to connect to db with 'connectToMySql' first.\n";
	}
	return $self;
}

1;

