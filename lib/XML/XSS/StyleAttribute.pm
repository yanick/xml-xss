package XML::XSS::StyleAttribute;

# ABSTRACT: style attribute for XML::XSS stylesheet rule

use Moose;
use MooseX::SemiAffordanceAccessor;
use MooseX::Clone;

with 'MooseX::Clone';

use Scalar::Util qw/ refaddr /;

no warnings qw/ uninitialized /;

has 'value' => (
    is        => 'rw',
    clearer   => 'clear_value',
    predicate => 'has_value',
    traits    => [qw/ Clone /],
);

after 'set_value' => sub {
    my $self = shift;

    $self->clear_value unless defined $self->value;
};

#sub clone {
#    return XML::XSS::StyleAttribute->new(
#        value => $_[0]->value
#    );
#}

sub render {
    my ( $self, $r, $node, $args ) = @_;

    return unless $self->has_value;

    my $value = $self->value;

    return ref $value ? $value->( $r, $node, $args ) : $value;
}

use overload
  'bool' => sub { $_[0]->value },
  '""'   => sub { $_[0]->value },
  '+'    => sub { $_[0]->value + $_[1] },
  '0+'   => sub { $_[0]->value },
  '*='   => sub { $_[0]->set_value( $_[1] ) },
  'x='   => sub { $_[0]->set_value( XML::XSS::xsst( $_[1] ) ) },
  '='    => sub { shift },
  'eq'   => sub {
    my ( $a, $b ) = @_;
    return ref($a) eq ref($b)
      and refaddr($a) == refaddr($b);
  };

1;

