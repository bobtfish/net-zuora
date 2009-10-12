package Net::Zuora::Types;
use strict;
use warnings;

use MooseX::Types -declare => [qw[
    AccountStatus
    CreateOrUpdate
]];

use MooseX::Types::Moose qw/Str/;

subtype AccountStatus,
    as Str,
    where { /^(Draft|Active|Canceled)$/ };

subtype CreateOrUpdate,
    as Str,
    where { /^(create|update)$/ };

1;

