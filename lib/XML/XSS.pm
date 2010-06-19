package XML::XSS;

use 5.10.0;

use MooseX::SemiAffordanceAccessor;
use Moose;
use MooseX::AttributeHelpers;
use MooseX::ClassAttribute;


use XML::LibXML;

use XML::XSS::Element;
use XML::XSS::Document;
#use XML::XPathScript2::Stylesheet::Text;
#use XML::XPathScript2::Stylesheet::Element;
#use XML::XPathScript2::Stylesheet::Comment;
#use XML::XPathScript2::Stylesheet::ProcessingInstruction;
#use XML::XPathScript2::Stylesheet::Document;

with qw/ MooseX::LogDispatch::Levels /;

 has log_dispatch_conf => (
   is => 'ro',
   isa => 'HashRef',
   lazy => 1,
   required => 1,
   default => sub {
     my $self = shift;
        {
          class     => 'Log::Dispatch::Screen',
          min_level => $self->log_level,
          stderr    => 1,
          format    => '[%p] %m at %F line %L%n',
        }
    },
 );

has log_level => ( is => 'rw', default => 'info' );

#has 'text' => (
#    is => 'ro',
#    default =>
#      sub { XML::XSS::Text->new( stylesheet => $_[0] ) },
#    handles => {
#        set_text => 'set',
#    },
#);
#
#has 'comment' => (
#    is => 'ro',
#    default =>
#      sub { XML::XSS::Comment->new( stylesheet => $_[0] ) },
#    handles => {
#        set_comment => 'set',
#    },
#);
#
#has 'processing_instruction' => (
#    is => 'ro',
#    default =>
#      sub { XML::XSS::ProcessingInstruction->new( stylesheet => $_[0] ) },
#    handles => {
#        set_processing_instruction => 'set',
#    },
#);
#
#
#has '_elements' => (
#    isa => 'HashRef[XML::XPathScript2::Stylesheet::Element]',
#    metaclass => 'Collection::Hash',
#    default => sub { {} },
#    provides => {
#        set => '_set_element',
#        get => '_element',
#        'keys'  => 'element_keys',
#    },
#);
#
has 'catchall_element' => (
    is      => 'rw',
    isa => 'XML::XSS::Element',
    default => sub {
        XML::XSS::Element->new( stylesheet => $_[0] );
    },
    lazy => 1,
);

has document =>  (
    is => 'rw',
    default => sub {
        XML::XSS::Document->new( stylesheet => $_[0] );
    },
);

has stash => (
    is      => 'ro',
    writer  => '_set_stash',
    isa     => 'HashRef',
    default => sub { {} },
);


### methods ###############################################

sub clear_stash { $_[0]->_set_stash( {} ) }

#sub element {
#    my ( $self, $name ) = @_;
#    my $elt = $self->_element( $name );
#    unless ( $elt ) {
#        $elt = XML::XPathScript2::Stylesheet::Element->new( 
#            stylesheet => $self );
#        $self->_set_element( $name => $elt );
#    }
#    return $elt;
#}



sub set {
    my ( $self, $name, $attrs ) = @_;

    given ( $name ) {
        when ( '#document' ) {
            $self->document->set(%$attrs);
        }
    }
}

#sub set_element {
#    my $self = shift;
#    my ( $name, $args ) = @_;
#
#    if ( ref $args eq 'HASH' ) {
#        $self->element( $name )->set( %$args );
#    }
#    else {
#        $self->_set_element( $name => $args );
#    }
#}
#
sub render {
    my ( $self, $node ) = @_;

    unless ( ref $node ) {
        $node = XML::LibXML->load_xml( string => $node );
    }

    my $renderer = $self->resolve($node);

    return $renderer->applies($node);
}

##--------------------------------------------------------

sub resolve {
    my ( $self, $node ) = @_;

    if ( ref $node eq 'XML::LibXML::Document' ) {
        return $self->document;
    };

    return $self->catchall_element;

#    if ( $node->type eq 'element' ) {
#        return $self->_element( $node->name )
#            || $self->catchall_element
#             ;
#    }
#
#    my $type = $node->type;
#
#    return $self->$type;
}
#
#sub detach {
#    my ( $self, $node ) = @_;
#
#    # iterate through the nodes and replace the node by a copy
#
#    my $copy = $node->clone;
#    $node->set_is_instance(1);
#
#    if ( $node->type eq 'text' ) {
#        $self->set_text( $copy );
#        return;
#    }
#    elsif ( $node->type eq 'element' ) {
#        for ( $self->element_keys ) {
#            if ( $self->element($_) eq $node ) { # FIXME
#                # FIXME set_element in Stylesheet
#                $self->set_element( $_ => $copy );
#            }
#        }
#    }
#    else {
#        die;
#    }
#
#
#
#}

1;
