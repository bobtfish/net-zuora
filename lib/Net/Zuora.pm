package Net::Zuora;
use Moose;
use MooseX::StrictConstructor;
use File::ShareDir qw/module_dir/;
use MooseX::Types::Moose qw/Object/;
use Net::Zuora::Types qw/CreateOrUpdate/;
use MooseX::Lexical::Types qw/Object CreateOrUpdate/;
use MooseX::Types::Common::String qw/NonEmptySimpleStr/;
use MooseX::Types::Path::Class;
use SOAP::Lite; # +trace => [qw/transport debug/];
BEGIN { $SOAP::Constants::PREFIX_ENV = 'SOAP-ENV'; }
use Path::Class qw/file/;
use Data::Dumper;
use Net::Zuora::QueryIterator;
use namespace::autoclean;

our $VERSION = '0.000000_01';
$VERSION = eval $VERSION;

BEGIN { # If we are in a persistent environment (e.g. mod_perl)
        # then detect this (if prefork is installed) and preload
        # everything.
    if (
        eval { require prefork }
        && $prefork::FORKING
        && eval { require Module::Pluggable::Object }
    ) {
        Class::MOP::load_class($_)
            for Module::Pluggable::Object->new(
                search_path => ['Net::Zuora'],
            )->plugins;
    }
}

has wsdl_file => (
    is => 'ro',
    isa => 'Path::Class::File',
    coerce => 1,
    default => sub { file( module_dir(ref shift), 'zuora.11.0.wsdl' ) },
);

has _soap => (
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

sub _build__soap {
    SOAP::Lite->service(
        "file://" . shift->wsdl_file->absolute
    )->proxy('https://www.zuora.com/apps/services/a/11.0');
}

sub BUILD {
    my ($self) = @_;
    $self->session_id; # Login on construction so that we throw an
                       # exception straight away if credentials are wrong.
}

has session_id => (
    is => 'ro',
    isa => NonEmptySimpleStr,
    lazy => 1,
    builder => '_do_login',
);

sub _do_login {
    my ($self) = @_;
    my $res = $self->_soap->call(
        SOAP::Data->name('login')->attr({
            'xmlns:zns' => 'http://api.zuora.com/'}),
            SOAP::Data->name('zns:username', $self->username),
            SOAP::Data->name('zns:password', $self->password),
    );
    return $res->result->{Session}
        if $res->result;
    die("Could not login, fault detail: " . Dumper($res->fault));
}

sub _load_object_class {
    my ($self, $type) = @_;
    my $class = "Net::Zuora::$type";
    Class::MOP::load_class($class);
    return $class;
}

sub new_object {
    my ($self, $type, %p) = @_;
    my $class = $self->_load_object_class($type);
    $class->new(%p, _api => $self);
}

sub query_objects {
    my ($self, $type, %p) = @_;
    my $class = $self->_load_object_class($type);
    my $query_string = "select " . join(', ', $self->_get_public_attribute_names($class)) . " from $type";
    if (scalar(keys %p)) {
        $query_string .= " WHERE "
            . join(" AND ", map { $_ . "= '" . $p{$_} . "'" } keys %p);
    }

    my $res = $self->_soap->call(
        $self->_soap_headers,
        SOAP::Data->name('zns:query')->attr({
            'xmlns:zns' => 'http://api.zuora.com/',
        }),
        SOAP::Data->name('zns:queryString', $query_string)
    );
    Carp::confess(Dumper($res->fault)) if $res->fault;
    die(Dumper($res->result)) unless $res->result->{done} eq 'true';
    return Net::Zuora::QueryIterator->new(_api => $self, records => $res->result->{records}, type => $type);
}

sub _soap_headers {
    SOAP::Header->name(
        'zns:SessionHeader'
        => \SOAP::Data->name('zns:session' => shift->session_id)
    )->attr({
            'xmlns:zns' => 'http://api.zuora.com/',
            'SOAP-ENV:mustUnderstand' => '0',
    })
}

# FIXME - support attr trait or something..
sub _get_public_attribute_names {
    my ($self, $class) = @_;
    grep { ! /^_/ }
    map { $_->name }
    $class->meta->get_all_attributes;
}

sub _get_updateable_attribute_names {
    my ($self, $class) = @_;
    grep {
        $_ eq 'Id' or
        $class->meta->find_attribute_by_name($_)->has_write_method
    }
    $self->_get_public_attribute_names($class);
}

foreach my $type (qw/ create update /) {
    __PACKAGE__->meta->add_method( "_do_$type" => sub {
            my $self = shift;
            $self->_do_create_or_update($type, @_);
    });
}

sub _do_create_or_update {
    my $self = shift;
    my CreateOrUpdate $type = shift;
    my Object $object = shift;

    my $ob_type = ref($object);
    $ob_type =~ s/.*:://;

    my $get_attr_names_method
        = ($type eq 'create' ? '_get_public_attribute_names'
                             : '_get_updateable_attribute_names' );
    my @ob_data =
        map { SOAP::Data->name("objns:$_", $object->$_()) }
        $self->$get_attr_names_method($object);

    my $res = $self->_soap->call(
        $self->_soap_headers,
        SOAP::Data->name("zns:$type")->attr({
            'xmlns:zns' => 'http://api.zuora.com/',
        }),
        SOAP::Data->name('zns:zObjects', \SOAP::Data->value(
            @ob_data
        ))->attr({
            'xmlns:objns' => 'http://object.api.zuora.com/',
            'xsi:type' => "objns:$ob_type",
        })
    );
    Carp::confess(Dumper($res->fault)) if $res->fault;
    die($res->result) unless $res->result->{Success} eq 'true';
    return 1;
}

=head1 NAME

Net::Zuora - SOAP::Lite wrapper around the Zuora Z-Billing API

=head1 SYNOPSIS

    use Net::Zuora;
    my $z = Net::Zuora->new(
        usename => 'MyAPIUserName',
        password => 'MyAPIPassword',
    );

=head1 DESCRIPTION

Perl wrapper around L<SOAP::Lite> to interface with the Zuora Z-Billing API
(L<http://www.zuora.com>)

=head1 NOTE

B<THIS CODE IS INCOMPLETE> - it does not currently support all the features
of the Zuora API, and is not currently being developed.

It is here as a guide/starting point for someone looking to implement a
wrapper to Zuora's API in perl.

=head1 METHODS

=head1 BUGS

Plenty, along with missing features. This module was implemented whilst
we were evaluating the Zuora solution, however it is in no way feature complete,
but I thought I should share it to give the next person coming to this
problem a useful base to start from.

Code is available on github from: L<http://github.com/bobtfish/net-zuora>.

Patches (and taking over this project entirely) welcome.

=head1 AUTHOR

Tomas Doran (t0m) C<< <t0m@state51.co.uk> >>

=head1 COPYRIGHT & LICENSE

All perl code is Copyright (c) 2009 state51 and is licensed under the same
terms as perl itself.

The .wsdl file distributed with this distribution is Copyright (c) Zuora
and is free to distribute unmodified as long as this copyright notice
is maintained.

=cut

1;
