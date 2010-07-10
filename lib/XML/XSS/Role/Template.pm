package XML::XSS::Role::Template;

use 5.10.0;

use Moose::Role;

no warnings qw/ uninitialized /;

our @sigils = qw/ = ~ @ /;

Moose::Exporter->setup_import_methods( as_is => ['xsst'], );

sub xsst($) {
    my $template = shift;

    my ( $package, $filename, $line) = caller;

    my $code = _parse($template, $filename, $line);

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
    my ( $template, $filename, $line ) = @_;

    my $sigil_re = '[' . join( '', @sigils ) . ']';

    my @tokens = split /(<-?%$sigil_re?|%-?>)/, $template;

    my @parsed;
  TOKEN:
    while (@tokens) {
        my $token = shift @tokens;

        if ( $token =~ s/<(-?)%// ) {
            if ( $1 and @parsed and $parsed[-1][0] ) {
                $parsed[-1][1] =~ s/\s+\Z//;
            }
            _parse_block( $token, \@tokens, \@parsed, \$filename, \$line );
        }
        else {
            # it's a verbatim block
            my ( $f, $l ) = ( $filename, $line );
            $line += $token =~ y/\n//;
            if ( @parsed and $parsed[-1][2] ) {
                $token =~ s/^\s+//;
            }
            push @parsed, [ 1, $token, undef, $f, $l ];
        }
    }

    my $code;
    my ($pf, $pl);
    for my $block (@parsed) {
        $code .= join( ' ', "#line ", $block->[4], $block->[3] ) . "\n" 
            unless $block->[4] == $pl and $block->[3] eq $pf;
        ( $pf, $pl ) = ($block->[3], $block->[4] );
        if ( $block->[0] and length $block->[1] ) {
            $block->[1] =~ s/\|/\\\|/g;
            $block->[1] = 'print(q|' . $block->[1] . '|);';
        }

        $code .= $block->[1];

    }

    return $code;
}

sub _parse_block {
    my ( $token, $tokens, $parsed, $filename_ref, $line_ref ) = @_;

        my $code;
        my $closing_tag;
        my $level = 1;
        while( @$tokens ) {
            my $t = shift @$tokens;
            $level++ if $t =~ /\A<-?%/;
            $level-- if $t =~ /\A%-?>/;
            if ( $level == 0 ) {
                $closing_tag = $t;
                last;
            }
            $code .= $t;
        }

        my ( $f, $l ) = ( $$filename_ref, $$line_ref );

        $$line_ref += $code =~ y/\n//;

        die "stylesheet <% %>s are unbalanced: <%$token $code\n"
            unless $closing_tag;

       given ( $token ) {
           when ( '=' ) {
               $code = 'print(' . $code .');';
           }
           when ( '~' ) {
               $code =~ s/\A\s+|\s+Z//g;  # trim
               $code =~ s/'/\\'/g;
               $code = qq{eval { print \$r->render(\$node->findnodes('$code'), \$args) } or warn $@;};

           }
           when( '@' ) {
               $code =~ s/\A\s+|\s+Z//g;  # trim
               $code =~ s/'/\\'/g;
               $code = qq{eval { print \$node->findvalue('$code') } or warn $@;};
           }
           default {
                # add a semi-colon if there is none
                $code .= ';' unless $code =~ /;\s*\Z/;
           }
       }



       push @$parsed, [ 0, $code, !!($closing_tag =~ /-/), $f, $l ];
}


1;
