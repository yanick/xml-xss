package XML::XSS::Role::Renderer;
BEGIN {
  $XML::XSS::Role::Renderer::VERSION = '0.1_1';
}

#use MooseX::SemiAffordanceAccessor;
use Moose::Role;

use Scalar::Util qw/ refaddr /;

has stylesheet => (
    isa      => 'XML::XSS',
    weak_ref => 1,
    is       => 'ro',
    required => 1,
    handles  => [qw/ render debug info log stash /],
);

has _within_apply => ( is => 'rw', );

has is_detached => (
    is      => 'rw',
    default => 0,
);

requires 'apply';

sub detach_from_stylesheet {
    my $self = shift;

    $self->stylesheet->detach($self) unless $self->is_detached;
}

before apply => sub {
    $_[0]->_set_within_apply(1);
};

after apply => sub {
    $_[0]->_set_within_apply(0);
};

sub set {
    my ( $self, %attrs ) = @_;

    while ( my ( $k, $v ) = each %attrs ) {
        my $setter = "set_$k";
        $self->$setter($v);
    }
}

sub _render {
    my ( $self, $attr, $node, $args ) = @_;

    return $self->$attr->render( $self, $node, $args );
}

# http://use.perl.org/~tokuhirom/journal/36582
__PACKAGE__->meta->add_package_symbol( '&()' => sub { } );    # dummy
__PACKAGE__->meta->add_package_symbol( '&(""' => sub { shift->stringify } );
__PACKAGE__->meta->add_package_symbol( '&(%=' => sub { shift->_assign_attrs(shift) } );
__PACKAGE__->meta->add_package_symbol( '&(.' => sub { shift->_concat_overload(shift) } );
__PACKAGE__->meta->add_package_symbol( '&(bool' => sub { 1 } );
__PACKAGE__->meta->add_package_symbol( '&(eq' => sub { shift->_equal_overload(shift) } );
__PACKAGE__->meta->add_package_symbol( '&(==' => sub { shift->_equal_overload(shift) } );
__PACKAGE__->meta->add_package_symbol( '&(<<=' => sub { shift->_assign_content(shift) } );
__PACKAGE__->meta->add_package_symbol( '&(=' => sub { shift } );


sub stringify {
    my $self = shift;
    return 'XML::XSS::Element::' . refaddr $self;
}

sub _assign_content {
    $_[0]->set_content( $_[1] );
    $_[0];
}

sub _assign_content_xsst {
    $_[0]->set_content( XML::XSS::xsst( $_[1] ) );
    $_[0];
}

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
1;

