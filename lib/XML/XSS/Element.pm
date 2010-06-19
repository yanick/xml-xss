package XML::XSS::Element;

use Moose;
use MooseX::SemiAffordanceAccessor;

with 'XML::XSS::Role::Renderer';

sub applies {
    my ( $self, $node ) = @_;

    return $node->toString;
}

1;

