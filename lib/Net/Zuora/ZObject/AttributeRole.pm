package Net::Zuora::ZObject::AttributeRole;
use Moose::Role;
use MooseX::Types::Moose qw/Int/;
use namespace::autoclean;

has index => (
    is      => 'ro' ,
    isa     => Int,
    predicate   => 'has_index',
);

1;

