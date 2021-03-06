package XML::XSS::Document;
# ABSTRACT: XML::XSS document stylesheet rule

=head1 SYNOPSIS

    use XML::XSS;

    my $xss = XML::XSS->new;

    my $doc_style = $xss->document;

    $doc_style->set_pre( "=pod\n" );
    $doc_style->set_post( "=cut\n" );

    print $xss->render( '<doc>yadah yadah</doc>' );

=head1 DESCRIPTION

A C<XML::XSS> rule that matches against the document to
be rendered.  

Note that this is the C<XML::LibXML::Document> object,
and not the document root element.

=cut

use Moose;
use MooseX::SemiAffordanceAccessor;
use MooseX::Clone;

with 'XML::XSS::Role::Renderer', 'MooseX::Clone';

no warnings qw/ uninitialized /;

=head1 ATTRIBUTES 

=head2 use_clean_stash

If set to true, which is the default, the stash cleared before a new 
document is rendered.  

=head3 use_clean_stash()

Accessor getter.

=head3 set_use_clean_stash($bool)

Accessor setter.

=cut

has use_clean_stash => (
    default => 1,
    is      => 'rw',
    traits => [ 'Clone' ],
);

=head1 RENDERING ATTRIBUTES

For a document, the displayed attributes follow the template:

    pre
    [document nodes]
    post

=head2 pre

Printed before the document's nodes.

=head2 post

Printed after the document nodes.

=head2 content

If defined, will be used instead of the child nodes of the document.

=cut 
has [ qw/ content pre post / ] => ( traits => [ qw/ XML::XSS::Role::StyleAttribute
Clone / ] );

=head2 METHODS

=head3 set( %attrs )

A shortcut to the attribute setters.

    $doc_style->set( 
        pre  => 'foo',
        post => 'bar',
    );
    # equivalent to 
    $doc_style->set_pre( 'foo' );
    $doc_style->set_post( 'bar' );

=head3 apply( $node, $args )

Applies the rule to the C<$node>, passing along the optional C<$args>,
and returns the resulting string.

=cut

sub apply {
    my ( $self, $node, $args ) = @_;
    $args ||= {};

    $self->stylesheet->clear_stash if $self->use_clean_stash;

    my $output =  $self->_render( 'pre', $node, $args );

    $output .= $self->has_content 
             ? $self->_render( 'content', $node, $args )
             : $self->render( $node->childNodes, $args )
             ;

    $output .= $self->_render( 'post', $node, $args );

    return $output;
}

1;

__END__
