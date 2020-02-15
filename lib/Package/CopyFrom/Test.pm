package Package::CopyFrom::Test;

# AUTHORITY
# DATE
# DIST
# VERSION

our $FOO = "foo";
our $BAR = "bar";
our @FOO = ("foo", "FOO");
our @BAR = ("bar", "BAR");
our %FOO = (foo=>1, FOO=>2);
our %BAR = (bar=>1, BAR=>2);

our @ISA = qw(Exporter);
our @EXPORT_OK = qw(f1);
our %EXPORT_TAGS = (T1 => [qw/f1 f2/], T2 => [qw/f2 f3/]);

sub f1 { return $_[0]**2 }
sub f2 { return $_[0]**3 }
sub f3 {}

1;

# ABTRACT: A dummy module for testing

=for Pod::Coverage ^(.+)$
