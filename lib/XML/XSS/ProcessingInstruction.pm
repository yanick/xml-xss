package XML::XSS::ProcessingInstruction;
BEGIN {
  $XML::XSS::ProcessingInstruction::VERSION = '0.1_0';
}

use 5.10.0;

use Moose;
use MooseX::SemiAffordanceAccessor;

with 'XML::XSS::Role::Renderer';

has [ qw/ pre post process / ] =>(
    traits => [ qw/ XML::XSS::Role::StyleAttribute / ] 
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


