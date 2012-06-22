package Setup::Test;

use 5.010;
use strict;
use warnings;
use Log::Any '$log';

use Perinci::Sub::Gen::Undoable 0.06 qw(gen_undoable_func);

require Exporter;
our @ISA       = qw(Exporter);
our @EXPORT_OK = qw(setup_text_case);

our $VERSION = '0.08'; # VERSION

our %SPEC;

# return undef if text in $tr is already in correct case, or return the text in
# correct case.
my $_test = sub {
    my ($tr, $case) = @_;
    my $correct;
    if ($case eq 'upper') {
        $correct = uc($$tr);
    } elsif ($case eq 'lower') {
        $correct = lc($$tr);
    } elsif ($case eq 'title') {
        ($correct = $$tr) =~ s/\b(\w)(\w*)\b/uc($1).lc($2)/eg;
    }
    return if $$tr eq $correct;
    $correct;
};

my $res = gen_undoable_func(
    name     => __PACKAGE__ . '::setup_text_case',
    summary  => "Change text case",
    description => <<'_',

On do, will change text case to UPPER/lower/Title Case. Will save the original
text for undo.

On undo, will restore the original text.

This function does not support transaction because it uses scalar references
which is not serializable to JSON (format used by transaction manager).

_
    tx   => {use=>0},
    args => {
        text_ref => {
            schema  => 'str*', # XXX actually ref to str, not str
            summary => 'Reference to text',
        },
        case => {
            schema  => ['str*' => {in=>[qw/upper lower title/]}],
            summary => 'Case style',
        },
    },

    hook_check_args => sub {
        my $args = shift;
        defined($args->{text_ref}) or return [400, "Please specify text_ref"];
        ref($args->{text_ref}) eq 'SCALAR'
            or return [400, "Invalid text_ref: must be ref to a scalar"];
        $args->{case} or return [400, "Please specify case"];
        $args->{case} =~ /\A(upper|lower|title)\z/
            or return [400, "Invalid case: must be upper/lower/title"];
        [200, "OK"];
    },

    build_steps => sub {
        my $args = shift;

        my $tr    = $args->{text_ref};
        my $case  = $args->{case};

        my @steps;

        my $res = $_test->($tr, $case);
        push @steps, [case => $case] if defined($res);

        [200, "OK", \@steps];
    },

    steps => {
        case => {
            summary => 'Change text case',
            gen_undo => sub {
                my ($args, $step) = @_;

                my $tr  = $args->{text_ref};
                my $res = $_test->($tr, $step->[1]);
                return ["set", $$tr] if defined($res);
                return;
            },
            run => sub {
                my ($args, $step, $undo) = @_;

                my $tr  = $args->{text_ref};
                my $res = $_test->($tr, $step->[1]);
                $$tr = $res if defined($res);
                [200, "OK"];
            },
        },

        set => {
            summary => 'Set (restore) text value',
            gen_undo => sub {
                my ($args, $step) = @_;
                ["case", $args->{case}];
            },
            run => sub {
                my ($args, $step, $undo) = @_;

                my $tr = $args->{text_ref};
                $$tr = $step->[1];
                [200, "OK"];
            },
        },
    }
);

die "Can't generate function: $res->[0] - $res->[1]" unless $res->[0] == 200;
$SPEC{setup_text_case} = $res->[2]{meta};

1;
# ABSTRACT: Various simple setup routines for testing


__END__
=pod

=head1 NAME

Setup::Test - Various simple setup routines for testing

=head1 VERSION

version 0.08

=head1 SYNOPSIS

 use Setup::Unix::Group 'setup_text_case';

 # simple usage (doesn't save undo data)
 my $text = 'foo bar baz';
 my $res = setup_text_case text_ref => \$text, case => 'upper';
 die unless $res->[0] == 200 || $res->[0] == 304;

 # perform setup and save undo data (undo data should be serializable)
 $res = setup_text_case ..., -undo_action => 'do';
 die unless $res->[0] == 200 || $res->[0] == 304;
 my $undo_data = $res->[3]{undo_data};

 # perform undo
 $res = setup_text_case ..., -undo_action => "undo", -undo_data=>$undo_data;
 die unless $res->[0] == 200 || $res->[0] == 304;

=head1 DESCRIPTION

This module provides simple setup functions, useful for testing purposes.

This module uses L<Log::Any> logging framework.

This module has L<Rinci> metadata.

=head1 SEE ALSO

L<Setup>

=head1 AUTHOR

Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

