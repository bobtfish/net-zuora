package Net::Zuora::Account;
use Moose;
use MooseX::StrictConstructor;
use MooseX::Types::Moose qw/Str Num Int/;
use Net::Zuora::Types qw/AccountStatus/;
use namespace::autoclean;

with qw/
    Net::Zuora::ZObject
/;

has Name => ( isa => Str, is => 'ro', predicate => 'has_Name' );

has AccountNumber => ( isa => Str, is => 'ro', predicate => 'has_AccountNumber' );

has Balance => ( isa => Num, is => 'ro', predicate => 'has_Balance' );

has Status => ( isa => AccountStatus, is => 'rw', default => 'Draft' );

has Currency => ( isa => Str, is => 'ro', default => 'gbp' );

has BillCycleDay => ( isa => Int, is => 'ro', default => 1 );

1;

=head1 NAME

Net::Zuora::Account - Class representing an Account in the Zuora system

=head1 AUTHOR

See L<Net::Zuora> for author information

=head1 COPYRIGHT & LICENSE

See L<Net::Zuora> for copyright and license information.

=cut

