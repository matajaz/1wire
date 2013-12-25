package DS2423;
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
	my $self = $class->SUPER::new('DS2423',@_);
	bless $self, $class;
	return $self;
}
sub getCountersA {
	my( $self ) = @_;
	return $self->{_countersA};
}
sub getCountersB {
	my( $self ) = @_;
	return $self->{_countersB};
}
sub getCounter {
	my ( $self, $count ) = @_;
	return $self->{"$count"};
}

sub fetchAllValues {
	my( $self) = @_;
	$self->{_countersA} = $self->getValue("$self->{_basedir}\/$self->{_Address}\/counters\.A");
	$self->{_countersB} = $self->getValue("$self->{_basedir}\/$self->{_Address}\/counters\.B");
	$self->{_countersC} = $self->getValue("$self->{_basedir}\/$self->{_Address}\/counters\.A");
	$self->{_countersD} = $self->getValue("$self->{_basedir}\/$self->{_Address}\/counters\.B");
	return $self;
}

sub printAllMeasurements {
	my( $self ) = @_;
	$self->SUPER::printAllMeasurements();
	print "Counters.A:	$self->{_countersA}\n";
	print "Counters.B:	$self->{_countersB}\n";
	print "Counters.C:	$self->{_countersC}\n";
	print "Counters.D:	$self->{_countersD}\n";
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
			print "DS2423::inserted $self->{_CountersA},$self->{_CountersB},$self->{_CountersC},$self->{_CountersD} to $self->{_TableName} at $datetimestring\n";

			$dbh->do("INSERT INTO $self->{_TableName} VALUES (DEFAULT,\"$datetimestring\",0,0,$self->{_countersC},$self->{_countersD});");
		} else {
			print "DS2423::No table name is defined for $self->{_Address} ($self->{_Alias}\n";
		}
	}else {
		print "DS2423::No active db handler. You need to connect to db with 'connectToMySql' first.\n";
	}
	return $self;
}

1;

