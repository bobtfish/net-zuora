package Net::Zuora::Object;
use Moose::Role;
use MooseX::Types::Moose qw/Bool Str/;
use namespace::autoclean;

has _api => ( isa => 'Net::Zuora', is => 'ro', required => 1, weak_ref => 1 );
has _created => ( isa => Bool, default => 0, is => 'ro' );

has Id => ( isa => Str, is => 'ro', predicate => 'has_Id' );

sub create {
    my ($self) = @_;
    Carp::confess("Object $self already exists in Zuora system")
        if $self->_created;
    my $res = $self->_api->_do_create($self);
    $self->meta->get_attribute('_created')->set_value($self, 1);
    return $res;
}

1;

=head1 NAME

Net::Zuora::Object - Moose role representing an object in the Zuora system

=head1 AUTHOR

See L<Net::Zuora> for author information

=head1 COPYRIGHT & LICENSE

See L<Net::Zuora> for copyright and license information.

=cut

