
package Path::Classy::File;

use 5.006;
use strict;
use warnings;

our $VERSION = '0.001_0';
our @ISA;

BEGIN {
  require Path::Class::File;
  @ISA = qw(Path::Class::File);
}

use Attribute::Memoize; # XXX Memoize::Attrs

sub _size_formatter :Memoize {
  require Number::Bytes::Human;
  return Number::Bytes::Human->new;
}

sub _format_size {
  my ($sz, $opt) = @_;

  my $format = $opt->{format};
  if ( $format eq 'h' ) {
    return _size_formatter->format( $sz );
  }
  elsif ( !$format ) { # raw bytes (equiv to no format)
    return $sz;
  }
  else {
    die "unknown format '$format'";
  }
}

# -s
sub size {
  my $self = shift;
  my $raw_size = -s $self;
  if ( @_ ) {
    return _format_size( $raw_size, @_ );
  }
  else {
    return $raw_size;
  }
}

# -z
sub is_empty { -z shift }

# -e
sub exists { -e shift; }

sub _format_mode {
  my ($mode, $opt) = @_;
  my $format = $opt->{format};
  if ( !$format ) {
    return $mode;
  }
  elsif ( $format eq 'oct' ) {
    return sprintf '%04o', $mode;
  } 
  # TODO: 'ls'
  else {
    die "unknown mode format '$format'";
  }
}

# $f->mode
# $f->mode({ format => '' })
# $f->mode({ format => 'ls' })
# $f->mode({ format => 'oct' })
sub mode {
  my $self = shift;
  my $raw_mode = $self->stat->mode & 07777; # perldoc -f stat
  if ( @_ ) {
    return _format_mode( $raw_mode, @_ );
  } else {
    return $raw_mode;
  }
}

sub _dt_from_epoch {
  require DateTime;
  return DateTime->from_epoch( epoch => shift );
}

use constant SECS_IN_A_DAY => 60*60*24*1.00;

sub _format_from_epoch {
  my $sec = shift;
  my $opt = shift;
  my $as  = $opt->{as} || 'sec';
  if ( $as eq 'sec' ) {
    # already in seconds
    return $sec;
  } 
  elsif ( $as eq 'days' ) {
    return $sec / SECS_IN_A_DAY;
  }
  elsif ( $as eq 'dt' ) {
    # return a DateTime
    return _dt_from_epoch( $sec );
  }
  else {
    die "unknown time type '$as'";
  }
}

sub _format_from_start {
  my $days = shift;
  my $opt = shift;
  my $as = $opt->{as} || 'sec';
  if ( $as eq 'days' ) {
    # already in days
    return $days;
  } 
  elsif ( $as eq 'sec' ) {
    return $days * SECS_IN_A_DAY;
  } 
  elsif ( $as eq 'dt' ) {
    return _dt_from_epoch( $^T + $days * SECS_IN_A_DAY );
  }
  else {
    die "unknown time type '$as'";
  }
}



# $f->mtime
# $f->mtime({ from => 'epoch' }) 
# $f->mtime({ from => 'start', as => 'days' }); # -M $f
# $f->mtime({ as => 'dt' });
sub mtime {
  my $self = shift;
  if ( @_ ) {
    my $opt = shift;
    my $from = $opt->{from} || 'epoch';
    if ( $from eq 'epoch' ) {
      return _format_from_epoch( $self->stat->mtime, $opt );
    }
    elsif ( $from eq 'start' ) {
      return _format_from_start( -( -M $self ), $opt );
    }
    else {
      die "unknown time ref '$from'";
    }
  } else {
    return $self->stat->mtime;
  }
}

# -A
sub atime {
  my $self = shift;
  if ( @_ ) {
    my $opt = shift;
    my $from = $opt->{from} || 'epoch';
    if ( $from eq 'epoch' ) {
      return _format_from_epoch( $self->stat->atime, $opt );
    }
    elsif ( $from eq 'start' ) {
      return _format_from_start( -A $self, $opt );
    }
    else {
      die "unknown time ref '$from'";
    }
  } else {
    return $self->stat->atime;
  }
}

# -C
sub ctime {
  my $self = shift;
  if ( @_ ) {
    my $opt = shift;
    my $from = $opt->{from} || 'epoch';
    if ( $from eq 'epoch' ) {
      return _format_from_epoch( $self->stat->ctime, $opt );
    }
    elsif ( $from eq 'start' ) {
      return _format_from_start( -C $self, $opt );
    }
    else {
      die "unknown time ref '$from'";
    }
  } else {
    return $self->stat->ctime;
  }

}


# (-r, -R) (-w, -W) (-x, -X) (-o, -O)

sub uri {
  my $self = shift;
  require URI::file;
  return URI::file->new( $self->absolute->stringify, ); # os?
}


1;
