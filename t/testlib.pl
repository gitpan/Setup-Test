use 5.010;
use strict;
use warnings;

#use File::chdir;
#use File::Slurp;
#use File::Temp qw(tempdir);
use Setup::Test qw(setup_text_case);
use Test::More 0.96;
use Test::Setup qw(test_setup);

sub setup {
    #$::tmp_dir = tempdir(CLEANUP => 1);
    #$CWD = $::tmp_dir;

    #diag "tmp dir = $::tmp_dir";
}

sub teardown {
    done_testing();
    if (Test::More->builder->is_passing) {
        #diag "all tests successful, deleting temp files";
        #$CWD = "/";
    } else {
        #diag "there are failing tests, not deleting temp files";
    }
}

sub test_setup_text_case {
    my %tstargs = @_;

    my %tsargs = ();

    for (qw/name arg_error set_state1 set_state2 prepare cleanup/) {
        $tsargs{$_} = $tstargs{$_};
    }
    $tsargs{function} = \&setup_text_case;


    my %fargs = (%{$tstargs{args} // {}},
             );
    $tsargs{args} = \%fargs;

    my $check = sub {
        my %cargs = @_;

        if (defined $cargs{text}) {
            is(${$fargs{text_ref}}, $cargs{text}, "text")
                or diag explain(${$fargs{text_ref}});
        }
    };

    $tsargs{check_setup}   = sub { $check->(%{$tstargs{check_setup}}) };
    $tsargs{check_unsetup} = sub { $check->(%{$tstargs{check_unsetup}}) };
    if ($tstargs{check_state1}) {
        $tsargs{check_state1} = sub { $check->(%{$tstargs{check_state1}}) };
    }
    if ($tstargs{check_state2}) {
        $tsargs{check_state2} = sub { $check->(%{$tstargs{check_state2}}) };
    }

    test_setup(%tsargs);
}

1;
