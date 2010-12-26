
use strict;
use warnings;

use Module::Build 0.3601;


my %module_build_args = (
  'build_requires' => {
    'Carp' => '0',
    'Module::Build' => '0.3601',
    'Test::Class' => '0',
    'Test::Class::Load' => '0',
    'Test::More' => '0.94'
  },
  'configure_requires' => {
    'Module::Build' => '0.3601'
  },
  'dist_abstract' => 'XML stylesheet system',
  'dist_author' => [
    'Yanick Champoux <yanick@cpan.org>'
  ],
  'dist_name' => 'XML-XSS',
  'dist_version' => '0.3.0',
  'license' => 'perl',
  'module_name' => 'XML::XSS',
  'recommends' => {},
  'recursive_test_files' => 1,
  'requires' => {
    'Getopt::Long' => '0',
    'Moose' => '0',
    'Moose::Exporter' => '0',
    'Moose::Role' => '0',
    'MooseX::AttributeHelpers' => '0',
    'MooseX::ClassAttribute' => '0',
    'MooseX::Clone' => '0',
    'MooseX::SemiAffordanceAccessor' => '0',
    'Perl::Tidy' => '0',
    'Scalar::Util' => '0',
    'XML::LibXML' => '0',
    'overload' => '0',
    'perl' => '5.10.0'
  },
  'script_files' => [
    'bin/xss'
  ]
);


my $build = Module::Build->new(%module_build_args);

$build->create_build_script;
