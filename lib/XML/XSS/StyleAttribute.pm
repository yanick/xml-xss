package XML::XSS::StyleAttribute;
BEGIN {
  $XML::XSS::StyleAttribute::VERSION = '0.1_1';
}

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


__END__
=pod

=head1 NAME

XML::XSS::StyleAttribute - style attribute for XML::XSS stylesheet rule

=head1 VERSION

version 0.1_1

=head1 AUTHOR

  Yanick Champoux <yanick@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by Yanick Champoux.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

