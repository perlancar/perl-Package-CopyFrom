## no critic: Modules::ProhibitAutomaticExportation
package Package::CopyFrom;

# AUTHORITY
# DATE
# DIST
# VERSION

use strict 'subs', 'vars';
use warnings;
use Log::ger;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(copy_from);

sub _list_pkg_contents {
    my $pkg = shift;

    my %contents;
    my $symtbl = \%{"$pkg\::"};
    for my $key (keys %$symtbl) {
        my $val = $symtbl->{$key};
        #print "key=$key, val=$val, ref val=", ref($val), "\n";
        next if $key =~ /::\z/; # skip subpackages
        $contents{$key} = 1 if ref $val eq 'CODE' || # perl >= 5.22
            defined *$val{CODE};
        $contents{"\$$key"} = 1 if defined *$val{SCALAR};
        $contents{"\@$key"} = 1 if defined *$val{ARRAY};
        $contents{"\%$key"} = 1 if defined *$val{HASH};
    }
    %contents;
}

sub copy_from {
    my $opts = ref $_[0] eq 'HASH' ? shift : {};
    my $src_pkg = shift;

    $opts->{load} = 1 unless defined $opts->{load};
    if ($opts->{dclone}) {
        require Storable;
    }

    (my $src_pkg_pm = "$src_pkg.pm") =~ s!::!/!g;
    if ($opts->{load}) {
        require $src_pkg_pm unless $INC{$src_pkg_pm};
    }
    my %src_contents = _list_pkg_contents($src_pkg);

    my $target_pkg = caller;
    my %target_contents = _list_pkg_contents($target_pkg);

    for my $name (sort keys %src_contents) {
        if ($name =~ /\A\$/ && $opts->{skip_scalar}) {
            log_trace "Not copying $name from $src_pkg to $target_pkg (skip_scalar=1)";
            next;
        }
        if ($name =~ /\A\@/ && $opts->{skip_array}) {
            log_trace "Not copying $name from $src_pkg to $target_pkg (skip_array=1)";
            next;
        }
        if ($name =~ /\A\%/ && $opts->{skip_hash}) {
            log_trace "Not copying $name from $src_pkg to $target_pkg (skip_hash=1)";
            next;
        }
        if ($name !~ /\A[\$\@\%]/ && $opts->{skip_sub}) {
            log_trace "Not copying $name from $src_pkg to $target_pkg (skip_sub=1)";
            next;
        }
        if ($opts->{exclude} && grep { $name eq $_ } @{ $opts->{exclude} }) {
            log_trace "Not copying $name from $src_pkg to $target_pkg (listed in exclude)";
            next;
        }

        if (exists $target_contents{$name}) {
            log_trace "Warning: overwriting $name from $src_pkg to $target_pkg";
        }

        log_trace "Copying $name from $src_pkg to $target_pkg ...";
        if ($name =~ /\A\$(.+)/) {
            no warnings 'once', 'redefine';
            ${"$target_pkg\::$1"} = ${"$src_pkg\::$1"};
        } elsif ($name =~ /\A\@(.+)/) {
            no warnings 'once', 'redefine';
            @{"$target_pkg\::$1"} = $opts->{dclone} ? @{ Storable::dclone(\@{"$src_pkg\::$1"}) } : @{"$src_pkg\::$1"};
        } elsif ($name =~ /\A\%(.+)/) {
            no warnings 'once', 'redefine';
            %{"$target_pkg\::$1"} = $opts->{dclone} ? %{ Storable::dclone(\%{"$src_pkg\::$1"}) } : %{"$src_pkg\::$1"};
        } else {
            no warnings 'once', 'redefine';
            *{"$target_pkg\::$name"} = \&{"$src_pkg\::$name"};
        }
    }
}

1;
# ABSTRACT: Copy (some) contents from another package

=head1 SYNOPSIS

 package My::Package;
 use Package::CopyFrom; # exports copy_from()

 BEGIN { copy_from 'Your::Package' }

 # provide your own variables/subroutines
 our $scalar = 'foo';
 sub func1 { ... }
 ...

 1;


=head1 DESCRIPTION

This module provides L</copy_from> to fill the contents of the caller's (target)
package from the specified (source) package, with some options. C<copy_from> can
be used as an alternative to OO inheritance: you copy routines from another
"base" package then add/modify some other.


=head1 FUNCTIONS

=head2 copy_from

Usage:

 copy_from [ \%opts, ] $source_package

Load module C<$source_package> if not already loaded (unless the C<load> option
is set to false, in which case no module loading is done), then copy the
contents of the package into the caller's package. Currently only coderefs,
scalars, arrays, and hashes are copied.

Options:

=over

=item * load

Boolean, default true. If set to false, no attempt to load module named
C<$source_package> is made.

=item * dclone

Boolean, default false. By default, only shallow copying of arrays and hashes
are done. If this option is true, L<Storable>'s C<dclone> is used.

=item * skip_sub

Boolean, default false. Whether to exclude all subs.

=item * skip_scalar

Boolean. Whether to exclude all scalar variables.

=item * skip_array

Boolean, default false. Whether to exclude all array variables.

=item * skip_hash

Boolean, default false. Whether to exclude all hash variables.

=item * exclude

Arrayref. List of names to exclude.

Examples:

 exclude => ['@EXPORT', '@EXPORT_OK', '%EXPORT_TAGS', '$VERSION'];

=back


=head1 GOTCHAS

If your copying module is loaded by user during runtime instead of compile-time,
then subroutine name from your module will be overwritten by the runtime
C<copy_from> invocation. Illustration:

 # in Source.pm
 package Source;
 sub func1 { ... }
 sub func2 { print "Source's version" }
 1;

 # in YourModule.pm
 package YourModule;
 use Package::CopyFrom;
 copy_from 'Source';
 # modify func2
 sub func2 { "YourModule's version" }
 1;

 # in script1.pl
 use YourModule;
 YourModule::func2(); # prints "YourModule's version", ok.

 # in script2.pl
 require YourModule;
 YourModule::func2(); # prints "Source's version"!

To ensure that your subroutines do not get copied (overwritten) by the source
package's that have the same name, perform the copying at compile-time:

 # in YourModule.pm
 package YourModule;
 BEGIN { use Package::CopyFrom; copy_from 'Source' }
 # modify func2
 sub func2 { "YourModule's version" }
 1;


=head1 SEE ALSO

L<Package::Rename> can also copy packages.

=cut
