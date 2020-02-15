## no critic: Modules::ProhibitAutomaticExportation
package Package::CopyFrom;

# AUTHORITY
# DATE
# DIST
# VERSION

use strict 'subs', 'vars';
use warnings;
use Log::ger;

use Package::Stash;

use Exporter qw(import);
our @EXPORT = qw(copy_from);

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
    my %src_contents;
    {
        my $stash = Package::Stash->new($src_pkg);
        for ($stash->list_all_symbols('CODE'))   { $src_contents{$_}     = 1 }
        for ($stash->list_all_symbols('SCALAR')) { $src_contents{"\$$_"} = 1 }
        for ($stash->list_all_symbols('ARRAY'))  { $src_contents{"\@$_"} = 1 }
        for ($stash->list_all_symbols('HASH'))   { $src_contents{"\%$_"} = 1 }
    }

    my $target_pkg = caller;
    my %target_contents;
    {
        my $stash = Package::Stash->new($target_pkg);
        for ($stash->list_all_symbols('CODE'))   { $target_contents{$_}     = 1 }
        for ($stash->list_all_symbols('SCALAR')) { $target_contents{"\$$_"} = 1 }
        for ($stash->list_all_symbols('ARRAY'))  { $target_contents{"\@$_"} = 1 }
        for ($stash->list_all_symbols('HASH'))   { $target_contents{"\%$_"} = 1 }
    }

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
        if ($opts->{exclude} && grep { $name eq $_ } @{ $opts->{exclude} }) {
            log_trace "Not copying $name from $src_pkg to $target_pkg (listed in exclude)";
            next;
        }

        if (exists $target_contents{$name}) {
            if ($opts->{overwrite}) {
                log_trace "Will overwrite $name from $src_pkg to $target_pkg";
            } else {
                log_trace "Not copying $name from $src_pkg to $target_pkg (already exists)";
                next;
            }
        }

        log_trace "Copying $name from $src_pkg to $target_pkg ...";
        if ($name =~ /\A\$(.+)/) {
            ${"$target_pkg\::$1"} = ${"$src_pkg\::$1"};
        } elsif ($name =~ /\A\@(.+)/) {
            @{"$target_pkg\::$1"} = $opts->{dclone} ? @{ Storable::dclone(\@{"$src_pkg\::$1"}) } : @{"$src_pkg\::$1"};
        } elsif ($name =~ /\A\%(.+)/) {
            %{"$target_pkg\::$1"} = $opts->{dclone} ? %{ Storable::dclone(\@{"$src_pkg\::$1"}) } : %{"$src_pkg\::$1"};
        } else {
            *{"$target_pkg\::$name"} = \&{"$src_pkg\::$name"};
        }
    }
}

1;
# ABSTRACT: Copy (some) contents from another package

=head1 SYNOPSIS

 package My::Package;
 use Package::CopyFrom; # exports copy_from()

 copy_from 'Your::Package';


=head1 DESCRIPTION

This module provides L</copy_from> to fill the contents of the specifed (source)
package into the caller's (target) package, with some options. C<copy_from> can
be used for reuse purpose, as a "poor man"'s "non-inheritance" OO: you copy
routines (as well as package variables) from another "base" package then
add/modify some.


=head1 FUNCTIONS

=head2 copy_from

Usage:

 copy_from [ \%opts, ] $source_package

Load module C<$source_package> if not already loaded (unless the C<load> option
is set to false), then copy the contents of package into the caller's package.
Currently only subroutines, scalars, arrays, and hashes are copied.

Options:

=over

=item * overwrite

Boolean, default false. By default, if a symbol (variable/subroutine) already
exists in the target package, it will not be overwritten. Setting this option to
true will overwrite.

=item * load

Boolean, default true. If set to false, no attempt to load module named
C<$source_package> is made.

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

=item * dclone

Boolean, default false. By default, only shallow copying of arrays and hashes
are done. If this option is true, L<Storable>'s C<dclone> is used.

=back


=head1 SEE ALSO

L<Package::Rename>

=cut
