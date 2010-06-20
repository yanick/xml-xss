package XML::XSSTest;

use strict;
use warnings;

no warnings qw/ uninitialized /;

use base qw/ My::Test::Class /;

use Test::More;

use XML::XSS;

sub render_many :Tests {
    my $self = shift;

    $self->{doc} = '<doc><foo><bar/><baz/><bar/></foo></doc>';

    $self->{xss}->set( foo => {
            content => sub { $_[0]->render( $_[1]->findnodes('bar') ) } 
        },
    );

    $self->render_ok( '<doc><foo><bar></bar><bar></bar></foo></doc>' );

}

sub all_types :Tests {
    local $TODO = "some types left to deal with";
    my $self = shift;

    $self->{doc} = <<'END_XML';
<doc>
    <?foo attr1="val1" ?>
    <!-- this is a comment -->
    <a>text</a>
</doc>
END_XML

    ok eval { $self->render_ok( 'unknown' ); 1 };
    
}


sub render_ok {
    my ( $self, $expected, $comment ) = @_;

    is $self->{xss}->render( $self->{doc} ), $expected, $comment;
}

sub create_xss : Test(setup) {
    my $self = shift;
    $self->{xss} = XML::XSS->new;
    $self->{doc} = '<doc><foo>bar</foo></doc>';
}

1;

