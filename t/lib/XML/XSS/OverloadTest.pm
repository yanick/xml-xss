package XML::XSS::OverloadTest;

use strict;
use warnings;

no warnings qw/ uninitialized /;

use base qw/ My::Test::Class /;

use Test::More;

use XML::XSS;

sub overload_basic :Tests {
    my $self = shift;

    my $xss = $self->{xss};

    $xss.'foo'.'pre' = 'X';

    $self->render_ok( '<doc>X</doc>' );

}


sub render_ok {
    my ( $self, $expected, $comment ) = @_;

    is $self->{xss}->render( $self->{doc} ), $expected, $comment;
}

sub create_xss : Test(setup) {
    my $self = shift;
    $self->{xss} = XML::XSS->new;
    $self->{doc} = '<doc><foo/></doc>';
}

1;

