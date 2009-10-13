package Net::Zuora::ZObject::MetaClassRole;
use Moose::Role;
use namespace::autoclean;

use Data::Dumper;
around get_all_attributes => sub {
    my ($orig, $self, @rest) = @_;
    sort {
        my ($a_idx, $b_idx) = ($a->can('index') ? $a->index||0 : 0,
                                $b->can('index') ? $b->index||0 : 0 );
        $a_idx <=> $b_idx;
    } $self->$orig(@rest);
};

1;

