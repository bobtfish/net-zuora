package Net::Zuora;
use Moose;
use File::ShareDir qw/module_dir/;
use MooseX::Types::Path::Class;
use namespace::autoclean;

has wsdl_file => (
    is => 'ro',
    isa => 'Path::Class::File',
    coerce => 1,
    default => sub { module_dir(ref(shift), 'zuora.11.0.wsdl') },
);


=head1 NAME

Net::Zuora - 

=cut

1;
