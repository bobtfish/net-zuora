package Net::Zuora::ZObject::Role;
use Moose::Role;
use MooseX::Types::Moose qw/Bool Str/;
use namespace::autoclean;

has _api => ( isa => 'Net::Zuora', is => 'ro', required => 1, weak_ref => 1 );
has _created => ( isa => Bool, default => 0, is => 'ro' );

has Id => ( isa => Str, is => 'ro', predicate => 'has_Id',
    traits => [qw/Net::Zuora::ZObject::AttributeRole/],
    index => -1,
);

sub create {
    my ($self) = @_;
    Carp::confess("Object $self already exists in Zuora system")
        if $self->_created;
    my $res = $self->_api->_do_create($self);
    # Force write to ro attribute via MOP.
    $self->meta->find_attribute_by_name('_created')->set_value($self, 1);
    return $res;
}

sub update {
    my ($self) = @_;
    Carp::confess("Object $self does not exist in Zuora system")
        unless $self->_created;
    $self->_api->_do_update($self);
}

1;

=head1 NAME

Net::Zuora::ZObject::Role - Moose role representing an object in the Zuora system

=head1 DESCRIPTION

This is a base L<Moose::Role|role> which all objects that are represented
in the Zuora API consume.

=head1 METHODS

=head2 create

Creates an object which does not exist already in the Zuora's API.

Throws an exception if the object could not be created for any reason.

=head2 update

Pushes any local updates to this object back to Zuora's API.

Throws an exception if the object could not be updated for any reason.

=head1 ZUORA DOCS

L<http://apidocs.developer.zuora.com/index.php/ZObject>

=head1 AUTHOR

See L<Net::Zuora> for author information

=head1 COPYRIGHT & LICENSE

See L<Net::Zuora> for copyright and license information.

=cut

