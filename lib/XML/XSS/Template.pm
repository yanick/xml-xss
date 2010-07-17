package XML::XSS::Template;
BEGIN {
  $XML::XSS::Template::VERSION = '0.1_2';
}
# ABSTRACT: XML::XSS templates

use 5.10.0;

use Moose;
use MooseX::SemiAffordanceAccessor;

use overload 
    '&{}' => sub { $_[0]->compiled },
    'bool' => sub { length $_[0]->code };

no warnings qw/ uninitialized /;

our @sigils = qw/ = ~ @ /;

Moose::Exporter->setup_import_methods( as_is => ['xsst'], );

has template => ( isa => 'Str', is => 'rw', required => 1 );

has code => ( isa => 'Str', is => 'rw' );

has compiled => ( is => 'rw' );

has _filename => ( is => 'rw' );
has _line => ( is => 'rw' );

sub BUILD {
    my $self = shift;

    $self->_parse_template;

    my $sub = <<"END_SUB";
sub {
my ( \$r, \$node, \$args ) = \@_;
local *STDOUT;
my \$output;
open STDOUT, '>', \\\$output or die;
@{[ $self->code ]}
return \$output;
}
END_SUB

    $self->set_code( $sub );

    $self->set_compiled( eval $sub );
    die $@ if $@;

}



sub xsst($) {
    my $template = shift;

    my ( undef, $filename, $line) = caller;

    return XML::XSS::Template->new(
        _filename => $filename,
        _line => $line,
        template => $template,
    );
}

sub _parse_template {
    my $self = shift;

    my $sigil_re = '[' . join( '', @sigils ) . ']';

    my @tokens = split /(<-?%$sigil_re?|%-?>)/, $self->template;

    my @parsed;

  TOKEN:
    while (@tokens) {
        my $token = shift @tokens;

        if ( $token =~ s/<(-?)%// ) {
            if ( $1 and @parsed and $parsed[-1][0] ) {
                $parsed[-1][1] =~ s/\s+\Z//;
            }
            $self->_parse_block( $token, \@tokens, \@parsed );
        }
        else {
            # it's a verbatim block
            my ( $f, $l ) = ( $self->_filename, $self->_line );
            $self->_set_line( $l + $token =~ y/\n// );
            if ( @parsed and $parsed[-1][2] ) {
                $token =~ s/^\s+//;
            }
            push @parsed, [ 1, $token, undef, $f, $l ];
        }
    }

    my $code;
    my ($pf, $pl);
    for my $block (@parsed) {
        $code .= join( ' ', "\n#line ", $block->[4], $block->[3] ) . "\n" 
           unless $block->[4] == $pl and $block->[3] eq $pf;
        ( $pf, $pl ) = ($block->[3], $block->[4] );
        if ( $block->[0] and length $block->[1] ) {
            $block->[1] =~ s/\|/\\\|/g;
            $block->[1] = 'print(q|' . $block->[1] . '|);';
        }

        $code .= $block->[1];

    }

    return $self->set_code($code);
}

sub _parse_block {
    my $self = shift;

    my ( $token, $tokens, $parsed ) = @_;

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

        my ( $f, $l ) = ( $self->_filename, $self->_line );

        $self->_set_line( $l + $code =~ y/\n// );

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

__END__
=pod

=head1 NAME

XML::XSS::Template - XML::XSS templates

=head1 VERSION

version 0.1_2

=head1 AUTHOR

  Yanick Champoux <yanick@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by Yanick Champoux.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

