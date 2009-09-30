use strict;
use warnings;

use FindBin qw/$Bin/;
use lib "$Bin/lib";

use Test::More;
use Data::Dumper;

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
my $acc = $z->new_object(
    'Account' =>
        Name => 'foo',
        Currency => 'usd',
        BillCycleDay => 1,
        Status => 'Draft',
);

ok ! $acc->_created;
ok $acc->create;
ok $acc->_created;
is $acc->Name, 'foo';
is $acc->Currency, 'usd';
is $acc->BillCycleDay, 1;
is $acc->Status, 'Draft';

done_testing();

