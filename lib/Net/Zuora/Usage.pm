package Net::Zuora::Usage;
use Moose;
use MooseX::StrictConstructor;
use MooseX::Types::Moose qw/Str Int/;
use MooseX::Types::ISO8601 qw/ISO8601DateTimeStr/;
use Moose::Util::TypeConstraints;
use namespace::autoclean;

with qw/
    Net::Zuora::ZObject
/;

subtype 'RbeStatus', as Str, where { /^Pending|Processed$/ };

has Quantity => ( isa => Int, is => 'ro', required => 1 );

has AccountNumber => ( isa => Str, is => 'ro', required => 1 );

has SourceName => ( isa => Str, is => 'ro' );

has ChargeNumber => ( isa => Str, is => 'ro', predicate => 'has_ChargeNumber' );

has RbeStatus => ( isa => 'RbeStatus', is => 'ro', default => 'Pending' );

has UOM => ( isa => Str, is => 'ro' );

foreach my $field_name (qw/ StartDateTime SubmissionDateTime EndDateTime /) {
    has $field_name => (
        isa => ISO8601DateTimeStr, is => 'ro', required => 1,
        coerce => 1,
    );
}

1;

=head1 NAME

Net::Zuora::Usage - Class representing a set of Usage data in the Zuora system

=head1 AUTHOR

See L<Net::Zuora> for author information

=head1 COPYRIGHT & LICENSE

See L<Net::Zuora> for copyright and license information.

=cut

