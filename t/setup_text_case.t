#!perl

use 5.010;
use strict;
use warnings;

use FindBin '$Bin';
use lib $Bin, "$Bin/t";

use Test::More 0.96;
require "testlib.pl";

setup();

my $text_o      = "lower UPPER Title OtHer";
my $text_l      = "lower upper title other";
my $text_u      = "LOWER UPPER TITLE OTHER";
my $text_t      = "Lower Upper Title Other";
my $text;

test_setup_text_case(
    name          => "upper (already correct)",
    prepare       => sub { $text = $text_u },
    args          => {text_ref=>\$text, case=>'upper'},
    check_unsetup => {text => $text_u},
    check_setup   => {text => $text_u},
);
test_setup_text_case(
    name          => "upper",
    prepare       => sub { $text = $text_o },
    args          => {text_ref=>\$text, case=>'upper'},
    check_unsetup => {text => $text_o},
    check_setup   => {text => $text_u},
);
test_setup_text_case(
    name          => "lower",
    prepare       => sub { $text = $text_o },
    args          => {text_ref=>\$text, case=>'lower'},
    check_unsetup => {text => $text_o},
    check_setup   => {text => $text_l},
);
test_setup_text_case(
    name          => "title",
    prepare       => sub { $text = $text_o },
    args          => {text_ref=>\$text, case=>'title'},
    check_unsetup => {text => $text_o},
    check_setup   => {text => $text_t},
);
goto DONE_TESTING;

DONE_TESTING:
teardown();
