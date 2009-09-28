package Net::Zuora;
use Moose;
use File::ShareDir qw/module_dir/;
use MooseX::Types::Moose qw/Object/;
use MooseX::Types::Common::String qw/NonEmptySimpleStr/;
use MooseX::Types::Path::Class;
use XML::Compile::WSDL11;
use XML::Compile::SOAP11;
use XML::Compile::Transport::SOAPHTTP;
use Path::Class qw/file/;
use Data::Dumper;
use namespace::autoclean;

has wsdl_file => (
    is => 'ro',
    isa => 'Path::Class::File',
    coerce => 1,
    default => sub { file( module_dir(ref shift), 'zuora.11.0.wsdl' ) },
);

has _xmlC => (
    is => 'ro',
    isa => Object,
    lazy_build => 1,
);

has username => (
    is => 'ro',
    isa => NonEmptySimpleStr,
    required => 1,
);

has password => (
    is => 'ro',
    isa => NonEmptySimpleStr,
    required => 1,
);

sub _build__xmlC {
    my ($self) = @_;
    XML::Compile::WSDL11->new( $self->wsdl_file );
}

sub BUILD {
    my ($self) = @_;
    $self->_xmlC;
}

has session_id => (
    is => 'ro',
    isa => NonEmptySimpleStr,
    lazy => 1,
    builder => '_do_login',
);

sub _do_login {
    my ($self) = @_;
    my $login_method = $self->_xmlC->compileClient('login');
    my ($res, $fault) = $login_method->(
        username => $self->username,
        password => $self->password
    );
    return $res->{parameters}{result}{Session}
        or die(Dumper($fault));
}

=head1 NAME

Net::Zuora - 

=cut

1;
