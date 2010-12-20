package XML::XSS::Stylesheet::HTML2TD;

use Moose;
use XML::XSS;
use Perl::Tidy;

extends 'XML::XSS';

style '*' => (
    pre  => \&pre_element,
    post => '};',
);

style '#text' => (
    process => sub { $_[1]->data =~ /\S/ },
    pre     => "outs '",
    post    => "';",
    filter  => sub { s/'/\\'/g; s/^\s+|\s+$//gm; $_ },
);

style '#document' => (
    content => sub {
        my ( $self, $node, $args ) = @_;
        my $raw = $self->stylesheet->render( $node->childNodes );

        my $output;
        my $err;
        eval { 
            Perl::Tidy::perltidy( 
                source      => \$raw,
                destination => \$output,
                errorfile     => \$err,
             )
        };

        # send the raw output if Tidy failed
        return $err ? $raw : $output;
    },
);

sub pre_element {
    my ( $self, $node, $args ) = @_;

    my $name = $node->nodeName;

    return "$name {" . pre_attrs( $node );
}

sub pre_attrs {
    my $node = shift;

    my @attr = $node->attributes or return '';

    my $output = 'attr { ';

    for ( @attr ) {
        my $value = $_->value;
        $value =~ s/'/&apos;/g;
        $output .= $_->nodeName . ' => ' . "'$value'" . ', ';
    }

    $output .= '};';

    return $output;
}

1;
