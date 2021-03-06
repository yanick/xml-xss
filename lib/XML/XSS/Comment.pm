package XML::XSS::Comment;
# ABSTRACT: XML::XSS comment stylesheet rule

=head1 SYNOPSIS

    use XML::XSS;

    my $xss = XML::XSS->new;

    my $cmt_style = $xss->comment;

    $cmt_style->set_filter( sub { s/^/#/gm; $_ } );

    print $xss->render( '<doc><!-- foo -->yadah yadah</doc>' );


=head1 DESCRIPTION

A C<XML::XSS> rule that matches against the comment nodes of a
document to be rendered.  

=cut

use 5.10.0;

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

=head2 process, pre, showtag, rename, post 

Same attribute behaviors as in C<XML::XSS::Element>.

=head2 replace, filter

Same attribute behaviors as in C<XML::XSS::Text>.

=cut 

has [ qw/ showtag pre post rename replace process filter / ] => ( 
traits => [ qw/ XML::XSS::Role::StyleAttribute Clone / ] );

sub apply {
    my ( $self, $node, $args ) = @_;
    $args ||= {};

    $DB::single = 1;

    return if $self->has_process and !$self->_render( 'process', $node, $args
        );

    my $text = $node->data;

    my $output;
    $output .= $self->_render( 'pre', $node, $args );

    my $name;
    my $showtag =  $self->_render( 'showtag', $node, $args ) 
                // ( $self->has_pre ? 0 : 1 );

    if ( $showtag ) {
        $name = $self->has_rename && $self->_render( 'rename', $node,
            $args );
        $output .= $name ? "<$name>" : '<!--';
    }

    $text = $self->_render( 'replace', $node, $args ) if
        $self->has_replace;

    if ( $self->has_filter ) {
        $text = $self->filter->() for $text;  # quick alias to $_
    }

    $output .= $text;

    $output .= $name ? "</$name>" : '-->' if $showtag;

    $output .= $self->_render( 'post', $node, $args );

    return $output;
}

1;


