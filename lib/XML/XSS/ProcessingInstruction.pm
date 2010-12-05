package XML::XSS::ProcessingInstruction;
# ABSTRACT: XML::XSS processing instruction stylesheet rule

use 5.10.0;

use Moose;
use MooseX::SemiAffordanceAccessor;
use MooseX::Clone;

with 'XML::XSS::Role::Renderer', 'MooseX::Clone';

has [ qw/ pre post process / ] =>(
    traits => [ qw/ XML::XSS::Role::StyleAttribute Clone / ] 
);

no warnings qw/ uninitialized /;

sub apply {
    my ( $self, $node, $args ) = @_;
    $args ||= {};

    return if $self->has_process and !$self->_render( 'process', $node,
        $args);

    my $output;
    $output .= $self->_render( 'pre', $node, $args );
    $output .= $node->toString;
    $output .= $self->_render( 'post', $node, $args );

    return $output;
}

1;


