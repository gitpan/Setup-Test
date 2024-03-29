
use strict;
use warnings;

use Module::Build 0.3601;


my %module_build_args = (
  "build_requires" => {
    "Module::Build" => "0.3601",
    "Test::More" => "0.96",
    "Test::Setup" => "1.01"
  },
  "configure_requires" => {
    "Module::Build" => "0.3601"
  },
  "dist_abstract" => "Various simple setup routines for testing",
  "dist_author" => [
    "Steven Haryanto <stevenharyanto\@gmail.com>"
  ],
  "dist_name" => "Setup-Test",
  "dist_version" => "0.10",
  "license" => "perl",
  "module_name" => "Setup::Test",
  "recommends" => {},
  "recursive_test_files" => 1,
  "requires" => {
    "Log::Any" => 0,
    "Perinci::Sub::Gen::Undoable" => "0.09",
    "Rinci" => "1.1.0",
    "Setup" => "1.0.0",
    "perl" => "5.010000"
  },
  "script_files" => []
);


my $build = Module::Build->new(%module_build_args);

$build->create_build_script;
