use strict;
use warnings;

use Test::More;

use Net::Zuora;

my $z = Net::Zuora->new(username => 'fred', password => 'baaa');
ok $z->wsdl_file;


done_testing();

