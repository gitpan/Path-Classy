
package Path::Classy::Dir;

use 5.006;
use strict;
use warnings;

our $VERSION = '0.002_0';
our @ISA;

BEGIN {
  require Path::Classy::Entity;
  require Path::Class::Dir;
  @ISA = qw(Path::Class::Dir Path::Classy::Entity);
}

1;
