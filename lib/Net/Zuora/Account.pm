package Net::Zuora::Account;
use Net::Zuora::ZObject;
use MooseX::Types::Moose qw/Str Num Int/;
use Net::Zuora::Types qw/AccountStatus/;
use namespace::autoclean;

has Name => ( isa => Str, is => 'ro', predicate => 'has_Name', index => 17 );

has AccountNumber => ( isa => Str, is => 'ro', predicate => 'has_AccountNumber', index => 1 );

has Balance => ( isa => Num, is => 'ro', predicate => 'has_Balance', index => 5);

has Status => ( isa => AccountStatus, is => 'rw', default => 'Draft', index => 23 );

has Currency => ( isa => Str, is => 'ro', default => 'gbp', index => 11, );

has BillCycleDay => ( isa => Int, is => 'ro', default => 1, index => 7 );

1;

=head1 NAME

Net::Zuora::Account - Class representing an Account in the Zuora system

=head1 AUTHOR

See L<Net::Zuora> for author information

=head1 COPYRIGHT & LICENSE

See L<Net::Zuora> for copyright and license information.

=cut

