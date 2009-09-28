package Net::Zuora;
use Moose;
use File::ShareDir qw/module_dir/;
use MooseX::Types::Moose qw/Object/;
use MooseX::Types::Common::String qw/NonEmptySimpleStr/;
use MooseX::Types::Path::Class;
use SOAP::Lite +trace => [qw/transport debug/];
BEGIN { $SOAP::Constants::PREFIX_ENV = 'SOAP-ENV'; }
use Path::Class qw/file/;
use Data::Dumper;
use namespace::autoclean;

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
    my $s = SOAP::Lite->service( "file://" . $self->wsdl_file->absolute )->proxy('https://www.zuora.com/apps/services/a/11.0');
    return $s;
}

sub BUILD {
    my ($self) = @_;
    $self->_soap;
}

has session_id => (
    is => 'ro',
    isa => NonEmptySimpleStr,
    lazy => 1,
    builder => '_do_login',
);

sub _do_login {
    my ($self) = @_;
    print $self->_soap;
    my $un = SOAP::Data->name('zns:username', $self->username);
    my $pw = SOAP::Data->name('zns:password', $self->password);
    my $res = $self->_soap->call(SOAP::Data->name('login')->attr({'xmlns:zns' => 'http://api.zuora.com/'}), $un, $pw);
    return $res->result->{Session}
        or die(Dumper($res->fault));
}

sub test_do_insert {
    my ($self) = @_;
    my $session_id = $self->session_id;
    use Data::Dumper;
    local $Data::Dumper::Maxdepth = 10;
#    warn Dumper($self->_xmlC->{index});
    my $res = $self->_soap->call(
        SOAP::Header->name('zns:SessionHeader', \SOAP::Data->name('zns:session' => $self->session_id))->attr({
            'xmlns:zns' => 'http://api.zuora.com/',
            'SOAP-ENV:mustUnderstand' => '0',
        }),
        SOAP::Data->name('zns:create')->attr({
            'xmlns:zns' => 'http://api.zuora.com/',
        }),
        SOAP::Data->name('zns:zObjects', \SOAP::Data->value(
                    SOAP::Data->name('objns:Name', 'foo'),
                    SOAP::Data->name('objns:Currency', 'usd'),
                    SOAP::Data->name('objns:BillCycleDay', '1'),
                    SOAP::Data->name('objns:Status', 'Draft'),
        ))->attr({
            'xmlns:objns' => 'http://object.api.zuora.com/',
            'xsi:type' => 'objns:Account',
        })
    );
    warn "MOO";
}

=head1 NAME

Net::Zuora - 

=cut

1;
