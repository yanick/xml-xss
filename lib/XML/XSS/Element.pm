package XML::XSS::Element;

=head1 NAME 

XML::XSS::Element - XML::XSS element stylesheet rule

=head1 SYNOPSIS

    use XML::XSS;

    my $xss = XML::XSS->new;

    my $elt_style = $xss->element( 'foo' );

    $elt_style->set_pre( ">>>" );
    $elt_style->set_post( "<<<" );

    print $xss->render( '<doc><foo>yadah yadah</foo></doc>' );

=head1 DESCRIPTION

A C<XML::XSS> rule that matches against the element nodes
of the xml document to be rendered.

=cut

use Moose;
use MooseX::SemiAffordanceAccessor;
use MooseX::Clone;

use Scalar::Util qw/ refaddr /;

with 'XML::XSS::Role::Renderer', 'MooseX::Clone';

no warnings qw/ uninitialized /;

=head1 RENDERING ATTRIBUTES

For a given element 'foo', the displayed attributes follows the template:

    pre
    <foo>
    intro
    content
    prechildren
    prechild
    [child node]
    postchild
    postchildren
    extro
    </foo>
    post

=head2 process

If it resolves to false, skip the element (and its children) altogether.

    # don't show the tag if it doesn't have any child nodes
    $xss->set( foo => {
        process => sub {
            my ( $self, $node, $args ) = @_;
            return $node->childNodes->size > 0;
        }
    } );

As it's always the first attribute to be evaluated,  it 
can also be used to set up the other rendering attributes.

    $xss->set( '*' => {
        process => sub {
            my ( $self, $node, $args ) = @_;
            my $time = time();

            $self->set( showtag => 1 );
            $self->set( 'pre' => "\n>>> ". localtime . "\n" );
            $self->set( 'post' => sub { "\n>>> took " . (time-$time) . "seconds\n"; } );

            return 1;
        }
    } );

=head3 get_process()

Attribute getter.

=head3 set_process( $process )

Attribute setter.

=head2 pre

Printed before the element opening tag position.  

=head2 showtag

If set to a true value, the open and closing tags of the xml element are printed out,
if not, they are omited.  

C<showtag> defaults to true 
unless either the attribute C<pre> or C<content> is defined. 
This exception is to accomodate the
common use of C<pre> to replace the tags with something else, or
when C<content> is used to provide a templated replacement for the
element.

    $css->set( 'subsection' => { 
        pre  => '<section level="2">',
        post => '</section>, 
    } );

=head3 showtag

Accessor.

=head3 set_showtag( $boolean )

=head2 rename

If defined, and if C<showtag> is true, the element name will be
replaced by this value in the opening and closing tags. If the 
opening tag has any attributes, they will be left untouched.

=head2 intro

Printed after the element opening tag position.

=head2 content

If defined, it is used instead of the child nodes of the element, which
are not processed (along with the
C<prechildren> and C<postchildren> attributes). 

=head2 prechildren

Printed before the node's children, if there are any.

=head2 prechild

Printed before every child node.

=head2 postchild

Printed after every child node.

=head2 postchildren

Printed after the node's children, if there are any.

=head2 extro

Printed before the element closing tag position.

=head2 post

Printed after the element closing tag position.

=cut

sub render_attributes {
    return qw/ process content showtag rename pre intro 
    prechildren prechild postchild postchildren extro post /;
}

has [ render_attributes() ] => ( traits => [qw/ XML::XSS::Role::RenderAttribute Clone /] );

before "set_$_" => sub {
    my $self = shift;
    $self->detach_from_stylesheet if $self->_within_apply;
  }
  for render_attributes();

=head1 METHODS

=head2 stylesheet()

Returns the parent C<XML::XSS> stylesheet of this rule.

=head2 render( .. )

Shortcut for 

    $self->stylesheet->render( ... );

=cut

sub apply {
    my ( $self, $node, $args ) = @_;
    $args ||= {};

    $self->debug("rendering element $node");

    return
      if $self->has_process and !$self->_render( 'process', $node, $args );

    my $output = $self->_render( 'pre', $node, $args );

    my $showtag =
      $self->has_showtag ? $self->showtag 
        : $self->has_pre || $self->has_content ? 0 : 1;

    my $name;
    if ($showtag) {
        $name =
            $self->has_rename
          ? $self->_render( 'rename', $node, $args )
          : $node->nodeName;

        $output .= join ' ', 
            "<$name",
            map { join '=', $_->nodeName, "'$_->serializeContent'" }
                $node->attributes;
        $output .= '>';
    }

    $output .= $self->_render( 'intro', $node, $args );

    if ( $self->has_content ) {
        $output .= $self->_render( 'content', $node, $args );
    }
    else {
        if ( my @children = $node->childNodes ) {
            $output .= $self->_render( 'prechildren', $node, $args );
            for ( $node->childNodes ) {
                $output .= $self->_render( 'prechild', $node, $args );
                $output .= $self->render( $_, $args );
                $output .= $self->_render( 'postchild', $node, $args );
            }
            $output .= $self->_render( 'postchildren', $node, $args );
        }
    }

    $output .= $self->_render( 'extro', $node, $args );

    $output .= "</$name>" if $showtag;

    $output .= $self->_render( 'post', $node, $args );

    return $output;
}

use overload
    '%=' => '_assign_attrs',
    '.' => '_concat_overload',
    'bool' => sub { 1 },
    'eq' => '_equal_overload',
    '==' => '_equal_overload',
    '<<=' => '_assign_content',
    '""' => sub {
        my $self = shift;
        return 'XML::XSS::Element::'.refaddr $self;
    },
    '=' => sub { shift };

sub _assign_content { 
    $_[0]->set_content( $_[1] ); $_[0];
}
sub _assign_content_xsst { $_[0]->set_content( XML::XSS::xsst( $_[1] ) );
        $_[0]; }

sub _assign_attrs { 
    my ( $self, $attrs ) = @_;
    for ( keys %$attrs ) {
        my $m = "set_$_";
        $self->$m( $attrs->{$_} );
    }
    $self;
}


sub _equal_overload {
    my ( $a, $b ) = @_;

    return refaddr($a) == refaddr($b);
}

sub _concat_overload {
    my ( $self, $attr ) = @_;

    return $self if $attr eq 'style';

    return $self->$attr;
}

package XML::XSS::Role::RenderAttribute::Sugar;

use XML::XSS;

use overload 
    'x=' => '_set_verbatim',
    '*='  => '_set_xsst',
    '=' => sub { shift },
    'bool' => sub { 1 };

sub _set_verbatim {
    my ( $self, $value ) = @_;

    my $method = $self->{'method'};
    my $object = $self->{object};
    $object->$method( $value );

    return $self;
}

sub _set_xsst {
    my ( $self, $value ) = @_;

    $self->_set_verbatim( XML::XSS::xsst( $value ) );
}

1;

