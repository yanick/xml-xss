package XML::XSS::TemplateTest;

use strict;
use warnings;

no warnings qw/ uninitialized /;

use base qw/ My::Test::Class /;

use Test::More;

use XML::XSS;

sub xsst_basic :Tests {
    my $code = xsst q{Foo!};
    is ref $code => 'CODE', 'produces a sub ref';

    is $code->() => 'Foo!', 'and returns the right stuff';

}


sub simple_string :Tests {
    my $self = shift;

    $self->{foo}->set( 'content' => xsst q{Hello world} ); 

    $self->render_ok( 'Hello world' );
}


sub simple_evaluation :Tests {
    my $self = shift;

    $self->{foo}->set( 'content' => xsst q{X<% 1 + 2 %>X} ); 

    $self->render_ok( 'XX' );
}



sub render_ok {
    my ( $self, $expected, $comment ) = @_;

    is $self->{xss}->render( $self->{doc} ), $expected, $comment;
}

sub create_xss : Test(setup) {
    my $self = shift;
    $self->{xss} = XML::XSS->new;
    $self->{foo} = $self->{xss}->element('foo');
    $self->{xss}->set( 'doc' => { showtag => 0 } );
    $self->{doc} = '<doc><foo>bar</foo></doc>';
}

1;

