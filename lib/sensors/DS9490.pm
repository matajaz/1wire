package DS9490;
use OneWireDevice;
use strict;
our @ISA = qw(OneWireDevice);

sub new
{
	my $class = shift;
	my $self = $class->SUPER::new('DS9490',@_);
	bless $self, $class;
	return $self;
}
1;

