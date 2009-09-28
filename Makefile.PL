use inc::Module::Install 0.91;
use strict;
use warnings;

if ($Module::Install::AUTHOR) {
    require Module::Install::AuthorTests;
    require Module::Install::AuthorRequires;
}

name 'Net-Zuora';
all_from 'lib/Net/Zuora.pm';

requires 'Moose';
requires 'Moose::Autobox';
requires 'MooseX::Types';
requires 'MooseX::Types::Common';
requires 'namespace::autoclean';
requires 'XML::Compile' => '1.07';
requires 'XML::Compile::SOAP' => '2.08';

test_requires 'Test::More';

if ($Module::Install::AUTHOR) {
    system("pod2text lib/Net/Zuora.pm > README")
        and die("Could not generate README");
}

WriteAll();
