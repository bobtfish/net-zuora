package Net::Zuora;
use Moose;
use MooseX::StrictConstructor;
use File::ShareDir qw/module_dir/;
use MooseX::Types::Moose qw/Object/;
use MooseX::Types::Common::String qw/NonEmptySimpleStr/;
use MooseX::Types::Path::Class;
use SOAP::Lite; # +trace => [qw/transport debug/];
BEGIN { $SOAP::Constants::PREFIX_ENV = 'SOAP-ENV'; }
use Path::Class qw/file/;
use Data::Dumper;
use namespace::autoclean;

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
    my ($self) = @_;
    my $s = SOAP::Lite->service(
        "file://" . $self->wsdl_file->absolute
    )->proxy('https://www.zuora.com/apps/services/a/11.0');
    return $s;
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
        or die(Dumper($res->fault));
}

sub new_object {
    my ($self, $type, %p) = @_;
    my $class = "Net::Zuora::$type";
    Class::MOP::load_class($class);
    $class->new(%p, _api => $self);
}

sub _soap_headers {
    my ($self) = @_;
    SOAP::Header->name('zns:SessionHeader', \SOAP::Data->name('zns:session' => $self->session_id))->attr({
            'xmlns:zns' => 'http://api.zuora.com/',
            'SOAP-ENV:mustUnderstand' => '0',
    })
}

sub _do_create {
    my ($self, $object) = @_;
    my $ob_type = ref($object) || confess;
    $ob_type =~ s/.*:://;

    my @ob_data =
        map { SOAP::Data->name("objns:$_", $object->$_()) }
        grep { ! /^_/ }
        map { $_->name }
        $object->meta->get_all_attributes;

    my $res = $self->_soap->call(
        $self->_soap_headers,
        SOAP::Data->name('zns:create')->attr({
            'xmlns:zns' => 'http://api.zuora.com/',
        }),
        SOAP::Data->name('zns:zObjects', \SOAP::Data->value(
            @ob_data
        ))->attr({
            'xmlns:objns' => 'http://object.api.zuora.com/',
            'xsi:type' => 'objns:' . $ob_type,
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

=head1 METHODS

=head1 BUGS

Plenty, along with missing features.

Code is available on github from: L<http://github.com/bobtfish/net-zuora>.
Patches are welcome.

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
