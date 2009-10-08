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
use List::MoreUtils qw/all/;

my $z = Net::Zuora->new(
    username => $TestConfig::API_USERNAME,
    password => $TestConfig::API_PASSWORD
);
my $res = $z->query_objects('Account');
isa_ok $res, 'Net::Zuora::QueryIterator';

my $account = $res->next;
ok $account;
isa_ok $account, 'Net::Zuora::Account';

my $use = $z->new_object(
    'Usage',
        AccountId => $account->Id,
        Quantity => 3,
);
$use->create;

done_testing;


done_testing();

