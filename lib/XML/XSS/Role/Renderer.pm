package XML::XSS::Role::Renderer;

#use MooseX::SemiAffordanceAccessor;
use Moose::Role;

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

    my $item = $self->$attr or return;

    return $item unless ref $item;

    return $item->( $self, $node, $args );

    die "not implemented yet";

}

1;

