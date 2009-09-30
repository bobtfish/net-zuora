package Net::Zuora::Types;
use strict;
use warnings;

use MooseX::Types -declare => [qw[
    AccountStatus
]];

use MooseX::Types::Moose qw/Str/;

subtype AccountStatus,
    as Str,
    where { /^(Draft|Active|Canceled)$/ };

1;

