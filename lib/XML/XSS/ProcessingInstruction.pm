package XML::XSS::ProcessingInstruction;

use 5.10.0;

use Moose;
use MooseX::SemiAffordanceAccessor;

with 'XML::XSS::Role::Renderer';

no warnings qw/ uninitialized /;

sub apply {
    my ( $self, $node, $args ) = @_;
    $args ||= {};

    return $node->toString;
}

1;


