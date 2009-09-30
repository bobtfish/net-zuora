package Net::Zuora::QueryIterator;
use Moose;
use MooseX::Types::Moose qw/ArrayRef Str/;
use namespace::autoclean;

has _api => ( is => 'ro', isa => 'Net::Zuora', required => 1 );
has _records => ( isa => ArrayRef, is => 'ro', required => 1, init_arg => 'records', traits => ['Array'], handles => { next => 'shift', all => 'elements' } );
has type => ( isa => Str, is => 'ro', required => 1 );

override BUILDARGS => sub {
    my $args = super();
    my $class_to_inflate = $args->{_api}->_load_object_class($args->{type});
    $args->{records} = [
        map { $class_to_inflate->new(%$_, _api => $args->{_api}) }
        @{ $args->{records} }
    ];
    return $args;
};

1;

