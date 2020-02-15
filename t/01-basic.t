#!perl

use strict;
use warnings;
use Test::More 0.98;

package Package::CopyFrom::Test::Copy;
use Package::CopyFrom;
BEGIN {
    our $FOO = "blah";
    our @FOO = ("blah");
    our %FOO = (blah=>1);
}
sub f1 { return $_[0] }
copy_from 'Package::CopyFrom::Test';

package Package::CopyFrom::Test::Copy_overwrite;
use Package::CopyFrom;
BEGIN {
    our $FOO = "blah";
    our @FOO = ("blah");
    our %FOO = (blah=>1);
}
sub f1 { return $_[0] }
copy_from {overwrite=>1}, 'Package::CopyFrom::Test';

package main;

subtest "opt:overwrite=0 (the default)" => sub {
    is_deeply($Package::CopyFrom::Test::Copy::FOO, "blah");
    eval 'is_deeply($Package::CopyFrom::Test::Copy::BAR, "bar");'; # to avoid compile-time parsing
    is_deeply(\@Package::CopyFrom::Test::Copy::FOO, ["blah"]);
    eval 'is_deeply(\@Package::CopyFrom::Test::Copy::BAR, ["bar","BAR"]);'; # to avoid compile-time parsing
    is_deeply(\%Package::CopyFrom::Test::Copy::FOO, {blah=>1});
    eval 'is_deeply(\%Package::CopyFrom::Test::Copy::BAR, {bar=>1,BAR=>2});'; # to avoid compile-time parsing
    is_deeply(Package::CopyFrom::Test::Copy::f1(3), 3);
    is_deeply(Package::CopyFrom::Test::Copy::f2(3), 27);
};

subtest "opt:overwrite=1" => sub {
    is_deeply($Package::CopyFrom::Test::Copy_overwrite::FOO, "foo");
    eval 'is_deeply($Package::CopyFrom::Test::Copy_overwrite::BAR, "bar");'; # to avoid compile-time parsing
    is_deeply(\@Package::CopyFrom::Test::Copy_overwrite::FOO, ["foo","FOO"]);
    eval 'is_deeply(\@Package::CopyFrom::Test::Copy_overwrite::BAR, ["bar","BAR"]);'; # to avoid compile-time parsing
    is_deeply(\%Package::CopyFrom::Test::Copy_overwrite::FOO, {foo=>1,FOO=>2});
    eval 'is_deeply(\%Package::CopyFrom::Test::Copy_overwrite::BAR, {bar=>1,BAR=>2});'; # to avoid compile-time parsing
    is_deeply(Package::CopyFrom::Test::Copy_overwrite::f1(3), 9);
    is_deeply(Package::CopyFrom::Test::Copy_overwrite::f2(3), 27);
};

DONE_TESTING:
done_testing;
