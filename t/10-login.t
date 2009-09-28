use strict;
use warnings;

use FindBin qw/$Bin/;
use lib "$Bin/lib";

use Test::More;

unless ($TestConfig::LIVE) {
    plan skip_all => 'Not running live tests';
    exit 0;
}

use Net::Zuora;
use TestConfig;

my $z = Net::Zuora->new(
    username => $TestConfig::API_USERNAME,
    password => $TestConfig::API_PASSWORD
);
ok $z->session_id;
ok length $z->session_id;

done_testing();

