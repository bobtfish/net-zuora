use strict;
use warnings;

use FindBin qw/$Bin/;
use lib "$Bin/lib";

use Test::More;
use DateTime;
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

my $account = do {
    my $res = $z->query_objects('Account');
    isa_ok $res, 'Net::Zuora::QueryIterator';

    $res->next;
};

ok $account;
isa_ok $account, 'Net::Zuora::Account';
$account->Status('Active');
eval { $account->update };
ok !$@, 'No exception updating account'
    or warn Dumper($@);

my $now = DateTime->now;
my $week_ago = DateTime->from_epoch( epoch => time()-(60*60*24*7) );
my $use = $z->new_object(
    'Usage',
        AccountNumber => $account->AccountNumber,
        Quantity => 3,
        EndDateTime  => $now,
        StartDateTime => $week_ago,
        SubmissionDateTime => $now,
);
my $res = eval { $use->create };
ok $res;
ok !$@
    or warn(Dumper($@));

done_testing;

