use inc::Module::Install 0.91;
use strict;
use warnings;

if ($Module::Install::AUTHOR) {
    require Module::Install::AuthorTests;
    require Module::Install::AuthorRequires;
}

use FindBin qw/$Bin/;

my $TEST_CONFIG_FN = "$Bin/t/lib/TestConfig.pm";

eval { require $TEST_CONFIG_FN; };

my $livetests  = prompt("Run live tests (needs username/password): ",
    $TestConfig::LIVE || 'n');

no warnings 'once';
my ($username, $password) = ('', '');
if ($livetests && $livetests =~ /y/i) {
    $livetests = 1;
    $username = prompt("API username: ",
        $TestConfig::API_USERNAME || '' );
    $password = prompt("API password: :",
        $TestConfig::API_PASSWORD || '' );
}
else {
    $livetests = 0;
}

my $out_fh;
open($out_fh, '>', $TEST_CONFIG_FN)
    or die("Could not open output file $TEST_CONFIG_FN");

print $out_fh qq{
package TestConfig;
use strict;
use warnings;

our \$LIVE = $livetests;
our \$API_USERNAME = '$username';
our \$API_PASSWORD = '$password';

1;
};
close($out_fh);

name 'Net-Zuora';
all_from 'lib/Net/Zuora.pm';

requires 'Moose';
requires 'Moose::Autobox';
requires 'MooseX::Types';
requires 'MooseX::Types::Common';
requires 'MooseX::Types::Path::Class';
requires 'namespace::autoclean';
requires 'File::ShareDir';
requires 'XML::Compile' => '1.07';
requires 'XML::Compile::SOAP' => '2.08';

test_requires 'Test::More' => '0.88';

author_requires 'Test::Pod::Coverage' => '1.04';
author_requires 'Test::Pod' => '1.14';
author_tests 't/author';

if ($Module::Install::AUTHOR) {
    system("pod2text lib/Net/Zuora.pm > README")
        and die("Could not generate README");
}

WriteAll();
