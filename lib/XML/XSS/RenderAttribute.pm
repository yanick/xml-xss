package XML::XSS::RenderAttribute;

use Moose;
use MooseX::SemiAffordanceAccessor;
use MooseX::Clone;

with 'MooseX::Clone';

has 'value' => ( is => 'rw',
    clearer => 'clear_value',
    predicate => 'has_value',
    traits => [ qw/ Clone / ],
    );

after 'set_value' => sub {
    my $self = shift;

    $self->clear_value unless defined $self->value;
};

#sub clone {
#    return XML::XSS::RenderAttribute->new(
#        value => $_[0]->value
#    );
#}

sub render {
    my ( $self, $r, $node, $args ) = @_;

    return unless $self->has_value;

    my $value = $self->value;

    return ref $value ? $value->( $r, $node, $args ) : $value;
}

use overload 
    'bool' => sub { $_[0]->value },
    '""' => sub { $_[0]->value },
    '+' => sub { $_[0]->value + $_[1] },
    '0+' => sub { $_[0]->value };

1;


