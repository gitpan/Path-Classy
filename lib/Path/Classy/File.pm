
package Path::Classy::File;

use 5.006;
use strict;
use warnings;

our $VERSION = '0.002_0';
our @ISA;

BEGIN {
  require Path::Classy::Entity;
  require Path::Class::File;
  @ISA = qw(Path::Class::File Path::Classy::Entity);
}

sub uri {
  my $self = shift;
  require URI::file;
  return URI::file->new( $self->absolute->stringify, ); # os?
}


1;
