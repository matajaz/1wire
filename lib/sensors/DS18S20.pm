package DS18S20;
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
	my $self = $class->SUPER::new('DS18S20',@_);
	bless $self, $class;
	return $self;
}

sub getTemperature {
	my( $self ) = @_;
	return $self->{_temperature};
}

sub fetchAllValues {
	my( $self) = @_;
#	print "basedir=$self->{_basedir},	";
#	print "Address=$self->{_Address}\n";
	$self->{_temperature} = $self->getValue("$self->{_basedir}\/$self->{_Address}\/temperature");
#	print "DS18S20: get temp=$self->{_temperature}\n";
	return $self;
}

sub printAllMeasurements {
	my( $self ) = @_;
	$self->SUPER::printAllMeasurements();
	print "Temperature:	$self->{_temperature}\n";
}
sub insertToSQL {
	my ( $self,$dbHandle ) = @_;
	
}
sub insertRowToDB {
	my ( $self,$dbh ) = @_;
	if ( defined $dbh ) {
		my $temp = sprintf("%.1f",$self->{_temperature});
		DateTime::TimeZone->names_in_country( "SE" );
		my $dt = DateTime->now;
		$dt->set_time_zone( 'Europe/Stockholm' );
		my $datetimestring = $dt->strftime('%Y-%m-%d %H-%M-%S');
		if ( $self->{_TableName} !~ /^$/ ){
			print "DS18S20::inserted $temp to $self->{_TableName} at $datetimestring\n";
			$dbh->do("INSERT INTO $self->{_TableName} VALUES (DEFAULT,\"$datetimestring\",$temp);");

		} else {
			print "DS18S20::No table name is defined for $self->{_Address} ($self->{_Alias})\n";
		}
	}else {
		print "DS18S20::No active db handler. You need to connect to db with 'connectToMySql' first.\n";
	}
	return $self;
}

1;

