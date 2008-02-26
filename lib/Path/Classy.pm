
package Path::Classy;

use 5.006;
use strict;
use warnings;

our $VERSION = '0.002_0';

our @ISA;
our @EXPORT_OK;
BEGIN {
  require Path::Class;

  @EXPORT_OK = @Path::Class::EXPORT_OK;

  require Exporter;
  @ISA = qw( Exporter );
}

use Path::Classy::File ();
use Path::Classy::Dir ();

sub file { Path::Classy::File->new(@_) }
sub dir  { Path::Classy::Dir ->new(@_) }
sub foreign_file { Path::Classy::File->new_foreign(@_) }
sub foreign_dir  { Path::Classy::Dir ->new_foreign(@_) }

1;

__END__

=head1 NAME

Path::Classy - Augmented Path::Class (fancy stuff)

=head1 SYNOPSIS

    use Path::Classy qw( file );

    my $f = file( 'my/file' );

    my $size = $f->size(); # size in bytes
    my $h_size = $f->size({ format => 'h'}); # eg. '12K'

    my $mtime = $f->mtime; # secs since epoch
    my $mtime_days = $f->mtime({ as => 'days' }); # days since epoch
    my $mtime_dt = $f->mtime({ as => 'dt' }); # as a DateTime

    my $uri = $f->uri; # URI->new( 'file://...' );

=head1 DESCRIPTION

    This module is pretty much an experience by now.
    It is quite superfluous.

This module augments the API of L<Path::Class> objects with
a few more methods. The idea is: since you turned your paths
into objects, why not take it as far as possible?

For example, after creating a L<Path::Class> object:

    use Path::Class qw( file );

    my $f = file( 'foo.txt' );

there are some info you can get from the file attached
to the current path:

    my $st = $f->stat;

But if you want to know if it exists already or
its size (preferably in a nice format like '1G')?
With Path::Class, you have to say

    print "exists already\n" if -e $f;
    printf "size: %s\n", -s $f;
                       # $f->stat->size works too

The filetest operators are quite nice and short.
But if you want more consistency, you would expect
methods to access this info:

    print "exists already\n" if $f->exists;
    printf "size: %s\n", $f->size;

C<Path::Classy> provides some of these
missing methods. It is far complete, as it is
a very recent code. But it may occasionally be useful.

B<ATTENTION:> C<Path::Classy> does not export anything by default,
while C<Path::Class> exports 'file' and 'dir'.

=head1 METHODS

So far, only files were contemplated with extra methods.
These are described below.

In the description below, C<$f> is typically created
with statements like

  use Path::Classy qw( file );
  $f = file( 'Path-Classy-0.001_0.tar.gz' );

=over 4

=item B<size> [ equiv: -s ]

  $size = $f->size(); 
  $size = $f->size(\%options);

Returns the file size. By the default, it returns
the raw byte count. A 'format' option is accepted
which support the following choices:

=over 4

=item h

Returns the size in a human readable format (like
'12K', '1G'). This is done by using L<Number::Bytes::Human>.

=item ''

Returns the raw byte size.

=back

Equivalence to a filetest expression:

  $f->size      ~~     -s $f

Examples:

  # assume $f is a file with 24475 bytes
  $f->size() # 24475
  $f->size({ format => 'h' }) # '24K'
  $f->size({ format => '' }) # 24475

=item B<exists> [ equiv: -e ]

  $yn = $f->exists;

Tells if the file exists or not.

Equivalence to a filetest expression:

  $f->exists    ~~     -e $f

=item B<mtime> [ equiv: -M ]

  $mtime = $f->mtime;
  $mtime = $f->mtime(\%options);

Returns the modification time of the file. 
By default, it returns the number of seconds
from epoch (as C<< $f->stat->mtime >> does).
It supports options 'from' and 'as'.
The option 'from' specifies the time from 
a certain reference and the possible choices
are:

=over 4

=item 'epoch'

The time is specified since the epoch.
(The epoch was at 00:00 January 1, 1970 GMT.)

=item 'start'

The time is specified since the start
time of the script (as given by C<$^T>).

=back

The default is 'epoch'.

The option 'as' determines how the time
is returned. The supported choices are:

=over 4

=item 'sec'

The time in seconds since the reference
specified by 'from'.

=item 'days'

The time in days since the reference
specifed by 'from'.

=item 'dt'

The time as a L<DateTime> object. It
should be independent of the reference
given by 'from'.

=back

The default is 'sec'.

With this method, the equivalence to a 
filetest expression is not that nice:

  $f->mtime({ from => 'start', as => 'days' })

is 

  -( -M $f )

because C<-M $f> is the script start time
minus file modification time in days. In turn,

  $f->mtime()  ~~ $f->stat->mtime

Examples:

  $f->mtime(); # file mod time since epoch (in secs)
  $f->mtime({ as => 'days' }); # idem (in days)
  $f->mtime({ as => 'dt' }); # file mod time as a DateTime

  $f->mtime({ from => 'epoch', as => 'days' }); # same as $f->mtime

  $f->mtime({ from => 'start' }); # file mod time since script start time (in secs)
  $f->mtime({ from => 'start', as => 'days' }); # same as -( -M $f )
  $f->mtime({ from => 'start', as => 'dt' }); # as a DateTime

When using C<< as => 'dt' >>, it should not make any
difference which reference time ('epoch' or 'start')
is chosen (except for computation errors). Prefer
C<< from => 'epoch' >> (which can be omitted) because
there are less computations involved.

=item B<atime> [ equiv: -A ]

  $atime = $f->atime;
  $atime = $f->atime(\%options);

Returns the access time of the file. 
Everything that was said about C<mtime> applies here.
By default, it returns the number of seconds
from epoch (as C<< $f->stat->atime >> does).
And it supports the options 'from' and 'as'
with the same choices as 'mtime' does.

=item B<ctime> [ equiv: -C ]

  $ctime = $f->ctime;
  $ctime = $f->ctime(\%options);

Returns the creation (or inode change) time of the file
(for filesystems which support it). 
Everything that was said about C<mtime> applies here.
By default, it returns the number of seconds
from epoch (as C<< $f->stat->ctime >> does).
And it supports the options 'from' and 'as'
with the same choices as 'mtime' does.

=item B<uri>

  $uri = $f->uri;

Returns a 'file://' URI pointing to the actual
file.

=back

=head1 BUGS

Please report bugs via CPAN RT L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Path-Classy>
or L<mailto://bugs-Path-Classy@rt.cpan.org>.

=head1 SEE ALSO

  Path::Class
  File::Spec

=head1 AUTHORS

Adriano R. Ferreira, E<lt>ferreira@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2008 by Adriano R. Ferreira

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

