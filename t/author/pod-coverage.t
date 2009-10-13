#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;

plan 'skip_all' => 'Unfinished';
exit 0;

use Test::Pod::Coverage 1.04;
all_pod_coverage_ok( { also_private => [ qr/^BUILD(ALL)?$/ ] } );

