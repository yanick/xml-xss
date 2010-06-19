package XML::XSS::Role::Renderer;

#use MooseX::SemiAffordanceAccessor;
use Moose::Role;

has stylesheet => (
    isa => 'XML::XSS',
    weak_ref => 1,
    is => 'ro',
    required => 1,
    handles => [ qw/ render debug info log / ],
);

requires 'applies';

sub _render {
    my( $self, $attr, $node, $args ) = @_;

    # for now, it's only strings
    my $item = $self->$attr or return;

    return $item unless ref $item;

    die "not implemented yet";

}

1;

