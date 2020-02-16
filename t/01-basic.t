#!perl

use strict;
use warnings;
use Test::More 0.98;

package Package::CopyFrom::Test::Copy;
use Package::CopyFrom;
our $SCALAR1 = "notcopied";
our @ARRAY1  = ("notcopied");
our %HASH1   = (notcopied=>1);
sub func1 { return "notcopied $_[0]" }
copy_from {overwrite=>1}, 'Package::CopyFrom::Test';

package Package::CopyFrom::Test::Copy_Modify;
use Package::CopyFrom;
BEGIN { copy_from 'Package::CopyFrom::Test' }
our $SCALAR1 = "notcopied";
our @ARRAY1  = ("notcopied");
our %HASH1   = (notcopied=>1);
sub func1 { return "notcopied $_[0]" }

package Package::CopyFrom::Test::Copy_NotLoad;
use Package::CopyFrom;
copy_from {load=>0}, 'Package::CopyFrom::Test::Copy';

package Package::CopyFrom::Test::Copy_Clone;
use Package::CopyFrom;
copy_from {dclone=>1}, 'Package::CopyFrom::Test';

package Package::CopyFrom::Test::Copy_SkipScalar;
use Package::CopyFrom;
copy_from {skip_scalar=>1}, 'Package::CopyFrom::Test';

package Package::CopyFrom::Test::Copy_SkipArray;
use Package::CopyFrom;
copy_from {skip_array=>1}, 'Package::CopyFrom::Test';

package Package::CopyFrom::Test::Copy_SkipHash;
use Package::CopyFrom;
copy_from {skip_hash=>1}, 'Package::CopyFrom::Test';

package Package::CopyFrom::Test::Copy_SkipSub;
use Package::CopyFrom;
copy_from {skip_sub=>1}, 'Package::CopyFrom::Test';

package Package::CopyFrom::Test::Copy_Exclude;
use Package::CopyFrom;
copy_from {exclude=>['@aARRAY1', 'func3']}, 'Package::CopyFrom::Test';

package main;
no warnings 'once';

subtest "basics" => sub {
    is_deeply( $Package::CopyFrom::Test::Copy::SCALAR1 , "test1");
    is_deeply( $Package::CopyFrom::Test::Copy::SCALAR2 , "test2");
    is_deeply(\@Package::CopyFrom::Test::Copy::ARRAY1  , ["elem1","elem2"]);
    is_deeply(\@Package::CopyFrom::Test::Copy::ARRAY2  , ["elem3","elem4"]);
    is_deeply(\%Package::CopyFrom::Test::Copy::HASH1   , {key1=>1,key2=>[2]});
    is_deeply(\%Package::CopyFrom::Test::Copy::HASH2   , {key3=>3,key4=>4});
    is_deeply(  Package::CopyFrom::Test::Copy::func1(1), "from test 1: 1");
    is_deeply(  Package::CopyFrom::Test::Copy::func2(1), "from test 2: 1");

    is_deeply( $Package::CopyFrom::Test::Copy_Modify::SCALAR1 , "notcopied");
    is_deeply( $Package::CopyFrom::Test::Copy_Modify::SCALAR2 , "test2");
    is_deeply(\@Package::CopyFrom::Test::Copy_Modify::ARRAY1  , ["notcopied"]);
    is_deeply(\@Package::CopyFrom::Test::Copy_Modify::ARRAY2  , ["elem3","elem4"]);
    is_deeply(\%Package::CopyFrom::Test::Copy_Modify::HASH1   , {notcopied=>1});
    is_deeply(\%Package::CopyFrom::Test::Copy_Modify::HASH2   , {key3=>3,key4=>4});
    is_deeply(  Package::CopyFrom::Test::Copy_Modify::func1(1), "notcopied 1");
    is_deeply(  Package::CopyFrom::Test::Copy_Modify::func2(1), "from test 2: 1");
};

subtest "opt:load=0" => sub {
    # by the Package::CopyFrom::Test::Copy_NotLoad code above not dying, we know
    # that load=0 option works.
    ok 1;
};

subtest "opt:skip_scalar=1" => sub {
    is_deeply( $Package::CopyFrom::Test::Copy_SkipScalar::SCALAR1 , undef);
    is_deeply( $Package::CopyFrom::Test::Copy_SkipScalar::SCALAR2 , undef);
    is_deeply(\@Package::CopyFrom::Test::Copy_SkipScalar::ARRAY1  , ["elem1","elem2"]);
    is_deeply(\@Package::CopyFrom::Test::Copy_SkipScalar::ARRAY2  , ["elem3","elem4"]);
    is_deeply(\%Package::CopyFrom::Test::Copy_SkipScalar::HASH1   , {key1=>1,key2=>[2]});
    is_deeply(\%Package::CopyFrom::Test::Copy_SkipScalar::HASH2   , {key3=>3,key4=>4});
    is_deeply(  Package::CopyFrom::Test::Copy_SkipScalar::func1(1), "from test 1: 1");
    is_deeply(  Package::CopyFrom::Test::Copy_SkipScalar::func2(1), "from test 2: 1");
};

subtest "opt:skip_array=1" => sub {
    is_deeply( $Package::CopyFrom::Test::Copy_SkipArray::SCALAR1 , "test1");
    is_deeply( $Package::CopyFrom::Test::Copy_SkipArray::SCALAR2 , "test2");
    is_deeply(\@Package::CopyFrom::Test::Copy_SkipArray::ARRAY1  , []);
    is_deeply(\@Package::CopyFrom::Test::Copy_SkipArray::ARRAY2  , []);
    is_deeply(\%Package::CopyFrom::Test::Copy_SkipArray::HASH1   , {key1=>1,key2=>[2]});
    is_deeply(\%Package::CopyFrom::Test::Copy_SkipArray::HASH2   , {key3=>3,key4=>4});
    is_deeply(  Package::CopyFrom::Test::Copy_SkipArray::func1(1), "from test 1: 1");
    is_deeply(  Package::CopyFrom::Test::Copy_SkipArray::func2(1), "from test 2: 1");
};

subtest "opt:skip_hash=1" => sub {
    is_deeply( $Package::CopyFrom::Test::Copy_SkipHash::SCALAR1 , "test1");
    is_deeply( $Package::CopyFrom::Test::Copy_SkipHash::SCALAR2 , "test2");
    is_deeply(\@Package::CopyFrom::Test::Copy_SkipHash::ARRAY1  , ["elem1","elem2"]);
    is_deeply(\@Package::CopyFrom::Test::Copy_SkipHash::ARRAY2  , ["elem3","elem4"]);
    is_deeply(\%Package::CopyFrom::Test::Copy_SkipHash::HASH1   , {});
    is_deeply(\%Package::CopyFrom::Test::Copy_SkipHash::HASH2   , {});
    is_deeply(  Package::CopyFrom::Test::Copy_SkipHash::func1(1), "from test 1: 1");
    is_deeply(  Package::CopyFrom::Test::Copy_SkipHash::func2(1), "from test 2: 1");
};

subtest "opt:skip_sub=1" => sub {
    is_deeply( $Package::CopyFrom::Test::Copy_SkipSub::SCALAR1 , "test1");
    is_deeply( $Package::CopyFrom::Test::Copy_SkipSub::SCALAR2 , "test2");
    is_deeply(\@Package::CopyFrom::Test::Copy_SkipSub::ARRAY1  , ["elem1","elem2"]);
    is_deeply(\@Package::CopyFrom::Test::Copy_SkipSub::ARRAY2  , ["elem3","elem4"]);
    is_deeply(\%Package::CopyFrom::Test::Copy_SkipSub::HASH1   , {key1=>1,key2=>[2]});
    is_deeply(\%Package::CopyFrom::Test::Copy_SkipSub::HASH2   , {key3=>3,key4=>4});
    ok(!defined &{"Package::CopyFrom::Test::Copy_SkipSub::func1"});
    ok(!defined &{"Package::CopyFrom::Test::Copy_SkipSub::func2"});
    ok(!defined &{"Package::CopyFrom::Test::Copy_SkipSub::func3"});
};

subtest "opt:dclone" => sub {
    push @{ $Package::CopyFrom::Test::HASH1{key2} }, 5;
    is_deeply(\%Package::CopyFrom::Test::Copy::HASH1      , {key1=>1, key2=>[2,5]});
    is_deeply(\%Package::CopyFrom::Test::Copy_Clone::HASH1, {key1=>1, key2=>[2]});
};

DONE_TESTING:
done_testing;
