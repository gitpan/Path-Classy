
use 5.006;
use ExtUtils::MakeMaker;

my $EUMM_VERSION = eval $ExtUtils::MakeMaker::VERSION;

WriteMakefile(
    NAME              => 'Path::Classy',
    VERSION_FROM      => 'lib/Path/Classy.pm',
    PREREQ_PM         => {
        'strict'               => 0,
        'warnings'             => 0,
        'Exporter'             => 0,

        'Path::Class'          => 0,
        'Path::Class::File'    => 0,
        'Path::Class::Dir'     => 0,
        'Number::Bytes::Human' => 0,
        'Attribute::Memoize'   => 0,
        'DateTime'             => 0,
        'URI::file'            => 0,

        # test_requires
        'Test::More'           => 0,
    },
  ( $] >= 5.005 ? (
    ABSTRACT_FROM     => 'lib/Path/Classy.pm',
    AUTHOR            => 'Adriano R. Ferreira <ferreira@cpan.org>'
  ) : () ),
  ( $EUMM_VERSION >= 6.31 ? (
    LICENSE => 'perl',
#    EXTRA_META => "recommends:\n" .
#                  "    Test::Pod:                     1.18\n" .
#                  "    Test::Pod::Coverage:           1.04\n" ,
  ) :() ),

);
