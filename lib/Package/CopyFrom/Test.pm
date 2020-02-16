package Package::CopyFrom::Test;

# AUTHORITY
# DATE
# DIST
# VERSION

our $SCALAR1 = "test1";
our $SCALAR2 = "test2";
our @ARRAY1  = ("elem1", "elem2");
our @ARRAY2  = ("elem3", "elem4");
our %HASH1   = (key1=>1, key2=>[2]);
our %HASH2   = (key3=>3, key4=>4);

our @ISA = qw(Exporter);
our @EXPORT_OK = qw(func1);
our %EXPORT_TAGS = (
    T1 => [qw/func1 func2/],
    T2 => [qw/func2 func3/],
);

sub func1 { return "from test 1: $_[0]" }
sub func2 { return "from test 2: $_[0]" }
sub func3 { return "from test 3: $_[0]" }

1;

# ABTRACT: A dummy module for testing

=for Pod::Coverage ^(.+)$
