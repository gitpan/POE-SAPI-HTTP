use 5.010001;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'POE::SAPI::HTTP',
    VERSION_FROM      => 'lib/POE/SAPI/HTTP.pm', # finds $VERSION
    PREREQ_PM         => {}, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/POE/SAPI/HTTP.pm', # retrieve abstract from module
       AUTHOR         => 'Paul G Webster <paul@daemonrage.net>') : ()),
);
