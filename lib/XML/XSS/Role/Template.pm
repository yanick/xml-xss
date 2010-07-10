package XML::XSS::Role::Template;

use Moose::Role;

Moose::Exporter->setup_import_methods(
    as_is => ['xsst'],
);

sub xsst($) {
    my $template = shift;

    my $code = _parse($template);

    my $sub = eval <<"END_SUB";
sub {
my ( \$r, \$node, \$args ) = \@_;
local *STDOUT;
my \$output;
open STDOUT, '>', \\\$output or die;
$code;
return \$output;
}
END_SUB

    die $@ if $@;

    return $sub;
}

sub _parse {
    my $template = shift;

    my @tokens = split /(<-?%\S*|%-?>)/, $template;

    my @pieces;

    while( @tokens ) {
        if ( $tokens[0] =~ /^<-?%/ ) {
        }
        else {
            push @pieces, [ 1, shift @tokens ];
        }
    }

    $template =~ s/\|/\\\|/g;

    return "print q|$template|;"
}

1;
