package XML::XSS::Text;
# ABSTRACT: XML::XSS text stylesheet rule

=head1 SYNOPSIS


    use XML::XSS;

    my $xss = XML::XSS->new;

    my $txt_style = $xss->text;

    $txt_style->set_pre( "=pod\n" );
    $txt_style->set_post( "=cut\n" );

    print $xss->render( '<doc>yadah yadah</doc>' );


=head1 DESCRIPTION

A C<XML::XSS> rule that matches against the text nodes of a
document to be rendered.  

=cut


use Moose;
use MooseX::SemiAffordanceAccessor;
use MooseX::Clone;

with 'XML::XSS::Role::Renderer', 'MooseX::Clone';

no warnings qw/ uninitialized /;

=head1 RENDERING ATTRIBUTES

For a document, the displayed attributes follow the template:

    pre
    [text]
    post

=cut 

=head2 pre

Printed before the text.

=head3 getter - pre()        

=head3 setter - set_pre( $pre )

=head2 replace 

If defined, its value is used instead of the original text.

=cut

has replace => ( 
    traits => [ qw/ XML::XSS::Role::StyleAttribute Clone / ] 
);

=head2 filter

Can only accept a sub reference. If defined, the text will be passed 
to the function as C<$_> and the returned value will be printed out.  Still is applied
even if C<replace> is used.

    $xss->set( '#text', {
        filter => sub { uc },
    } );

=cut

has filter => (
    traits => [ qw/ XML::XSS::Role::StyleAttribute Clone / ] 
);


=head2 post

Printed after the text.

=head3 getter - post()        

=head3 setter - set_post( $post )

=cut

has [ qw/ pre post / ] => (
    traits => [ qw/ XML::XSS::Role::StyleAttribute Clone/ ] 
);

=head2 process

If it resolves to false, skip the element altogether.

=head3 get_process()

Attribute getter.

=head3 set_process( $process )

Attribute setter.

=cut

has process => (
    traits => [ qw/ XML::XSS::Role::StyleAttribute Clone/ ] 
);

sub clear {
    my $self = shift;

    for ( qw/ pre post replace filter process / ) {
        my $setter = "clear_$_";
        $self->$setter;
    }

}

sub apply {
    my ( $self, $node, $args ) = @_;
    $args ||= {};

    return
      if $self->has_process and !$self->_render( 'process', $node, $args );

    my $text = $node->data;

    my $output;
    $output .= $self->_render( 'pre', $node, $args );

    if ( $self->has_replace ) {
        $text = $self->_render( 'replace', $node, $args );
    }

    if ( $self->has_filter ) {
        $text = $self->filter->value()->() for $text;  # quick alias to $_
    }

    $output .= $text;
    $output .= $self->_render( 'post', $node, $args );

    return $output;
}

1;


