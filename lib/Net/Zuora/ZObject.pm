package Net::Zuora::ZObject;
use strict;
use warnings;
use Moose ();
use Moose::Exporter;

Moose::Exporter->setup_import_methods(
    also => 'Moose',
);

sub init_meta {
    shift;
    my %options = @_;
    Moose->init_meta( %options );
    Moose::Util::MetaRole::apply_metaclass_roles(
        for_class => $options{for_class},
        attribute_metaclass_roles => [
            'Net::Zuora::ZObject::AttributeRole',
        ],
        metaclass_roles => [qw/
            Net::Zuora::ZObject::MetaClassRole
        /],
        constructor_class_roles => [qw/
            MooseX::StrictConstructor::Role::Meta::Method::Constructor
        /],
    );
    Moose::Util::MetaRole::apply_base_class_roles(
        for_class => $options{for_class},
        roles     => [qw/
            MooseX::StrictConstructor::Role::Object
            Net::Zuora::ZObject::Role
        /],
    );
    return $options{for_class}->meta;
}

1;

=head1 NAME

Net::Zuora::ZObject - Moose role representing an object in the Zuora system

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

