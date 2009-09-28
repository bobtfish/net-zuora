use strict;
use warnings;

use Test::More;

use Net::Zuora;

my $z = Net::Zuora->new;
ok $z->wsdl_file;


done_testing();

