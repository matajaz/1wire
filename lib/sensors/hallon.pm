package HALLON;
use strict;
our @ISA = qw(OneWireDevice);
use DateTime;
use DBI;
use DBD::mysql;
use DBI qw(:sql_types);

sub new
{
	my $class = shift;
	my $self;

	$self->{_hostName} = `hostname`;
	chomp $self->{_hostName};
	$self->{_Type} = 'HOST';
	$self->{_Address} = $self->{_hostName};
	$self->{_Alias} = $self->{_hostName};
	$self->{_TableName} = $self->{_hostName};
	
	my $cputemp0 = `cat /sys/class/thermal/thermal_zone0/temp`;
	chomp $cputemp0;
	my $cputemp1 = $cputemp0 / 1000;
	my $cputemp2 = $cputemp0 / 100;
	my $gputemp = `/opt/vc/bin/vcgencmd measure_temp`;
	chomp $gputemp;
	$gputemp =~ s/temp=([-+]?[0-9]*\.?[0-9]+)'C/$1/;
#	$gputemp =~ s/temp=([-+]?[0-9]*\.?[0-9]+)'C//;

	
	$self->{_cpuTemp} = $cputemp2 % $cputemp1;
	$self->{_gpuTemp} = $gputemp;
	$self->{_wifiId} = `lspci | egrep -i --color 'wifi|wlan|wireless'`;
	chomp $self->{_wifiId};
	my $wifi = `iwconfig wlan0 | grep -i quality`;
        chomp $wifi;
        my ($t,$n);
        my ($sign,$signal) = $wifi =~ /Signal level=(-)*(\S+)/;
        my ($quality) = $wifi =~ /Quality=(\S+)/;
        if ($wifi =~ /dBm/) {
                $signal = (($signal - 95)*5/3)/100*(-1);
        }else{
                ($t,$n) = $signal =~ /(\d+)\/(\d+)/;
                if ($n > 0){
                        $signal = $t/$n;
                }else{
                        $signal = 0;
                }
        }
        ($t,$n) = $quality =~ /(\d+)\/(\d+)/;
        if ($n > 0){
                $quality = $t/$n;
        }else{
                $quality = 0;
        }
        $signal = sprintf("%.2f", $signal);
        $quality = sprintf("%.2f", $quality);
        print "Wifi signal strength = $signal,  Wifi quality = $quality wifistring=\'$wifi\'\n";
        $self->{_wifiSignal} = $signal*100;
        $self->{_wifiQuality} = $quality*100;

	bless $self, $class;
	return $self;
}

sub getCpuTemperature {
	my( $self ) = @_;
	return $self->{_cpuTemp};
}
sub getGpuTemperature {
        my( $self ) = @_;
        return $self->{_gpuTemp};
}

sub getWifiSignalStrength {
	my( $self ) = @_;
	return $self->{_wifiSignal};
}
sub getWifiQuality {
        my( $self ) = @_;
        return $self->{_wifiQuality};
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
sub fetchAllValues {
	my( $self) = @_;
	
	my $cputemp0 = `cat /sys/class/thermal/thermal_zone0/temp`;
	chomp $cputemp0;
	my $cputemp1 = $cputemp0 / 1000;
	my $cputemp2 = $cputemp0 / 100;
	my $gputemp = `/opt/vc/bin/vcgencmd measure_temp`;
	chomp $gputemp;
	$gputemp =~ s/temp=([-+]?[0-9]*\.?[0-9]+)'C/$1/;
#	$gputemp =~ s/temp=([-+]?[0-9]*\.?[0-9]+)'C//;

	$self->{_cpuTemp} = $cputemp1 . ($cputemp2 % $cputemp1);
	$self->{_gpuTemp} = $gputemp;
	$self->{_wifiId} = `lspci | egrep -i --color 'wifi|wlan|wireless'`;
	chomp $self->{_wifiId};
	my $wifi = `iwconfig wlan0 | grep -i quality`;
	chomp $wifi;
	my ($t,$n);
	my ($sign,$signal) = $wifi =~ /Signal level=(-)*(\S+)/;
	my ($quality) = $wifi =~ /Quality=(\S+)/;
	if ($wifi =~ /dBm/) {
		$signal = (($signal - 95)*5/3)/100*(-1);
	}else{
		($t,$n) = $signal =~ /(\d+)\/(\d+)/; 
		if ($n > 0){
			$signal = $t/$n;
		}else{
			$signal = 0;
		}
	}
	($t,$n) = $quality =~ /(\d+)\/(\d+)/; 
	if ($n > 0){
		$quality = $t/$n;
	}else{
		$quality = 0;
	}
        $signal = sprintf("%.2f", $signal);
        $quality = sprintf("%.2f", $quality);
	print "Wifi signal strength = $signal,	Wifi quality = $quality	wifistring=\'$wifi\'\n";
	$self->{_wifiSignal} = $signal*100;
	$self->{_wifiQuality} = $quality*100;

	return $self;
}

sub printAllMeasurements {
	my( $self ) = @_;
	$self->SUPER::printAllMeasurements();
	print "CPU temperature:			$self->{_cpuTemp}°C\n";
	print "GPU temperature:			$self->{_gpuTemp}°C\n";
	print "WiFi Signal Strength:	" . $self->{_wifiSignal} . "%\n";
	print "WiFi Signal Quality:		" . $self->{_wifiQuality} . "%\n";
}
sub insertRowToDB {
	my ( $self,$dbh ) = @_;
	if ( defined $dbh ) {
		DateTime::TimeZone->names_in_country( "SE" );
		my $dt = DateTime->now;
		$dt->set_time_zone( 'Europe/Stockholm' );
		my $datetimestring = $dt->strftime('%Y-%m-%d %H-%M-%S');
		my $cputemp = sprintf("%.1f",$self->{_cpuTemp});
		my $gputemp = sprintf("%.1f",$self->{_gpuTemp});    
# 		my $wifiid = sprintf("%.1f",$self->{_wifiId});
		my $wifisignal = sprintf("%.1f",$self->{_wifiSignal});
		my $wifiquality = sprintf("%.1f",$self->{_wifiQuality});
		if ( $self->{_TableName} !~ /^$/ ){
#			print "HALLON::inserted $cputemp,$gputemp,$wifiid,$wifisignal,$wifiquality to $self->{_TableName} at $datetimestring\n";
			print "HALLON::inserted $cputemp,$gputemp,$wifisignal,$wifiquality to $self->{_TableName} at $datetimestring\n";

#			$dbh->do("INSERT INTO $self->{_TableName} VALUES (DEFAULT,\"$datetimestring\",$cputemp,$gputemp,$wifiid,$wifisignal,$wifiquality);");
			$dbh->do("INSERT INTO $self->{_TableName} VALUES (DEFAULT,\"$datetimestring\",$cputemp,$gputemp,$wifisignal,$wifiquality);");
		} else {
			print "HALLON::No table name is defined for $self->{_Address} ($self->{_Alias}\n";
		}
	}else {
		print "HALLON::No active db handler. You need to connect to db with 'connectToMySql' first.\n";
	}
	return $self;
}

1;

