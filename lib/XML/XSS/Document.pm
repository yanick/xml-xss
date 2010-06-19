package XML::XSS::Document;

use Moose;
use MooseX::SemiAffordanceAccessor;

with 'XML::XSS::Role::Renderer';

has clear_stash => (
    default => 1,
    is => 'rw',
);

has [ qw/ pre post / ] => ( is => 'rw' );

sub set {
    my( $self, %attrs ) = @_;

    while ( my ( $k, $v ) = each %attrs ) {
        my $setter = "set_$k";
        $self->$setter( $v );
    }
}

sub applies {
    my ( $self, $node, $args ) = @_;

    $args ||= {};

    $self->stylesheet->clear_stash if $self->clear_stash;

    $self->debug( "rendering document $node" );

    my $output;

    $output =  $self->_render( 'pre', $node, $args );
    $output .= $self->render( $node->documentElement );
    $output .= $self->_render( 'post', $node, $args );
}

1;


