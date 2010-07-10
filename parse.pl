#!/usr/bin/perl 

use strict;
use warnings;


<% $x = 3; %>
<%= $i %>
<%~ foo/bar %>
<%@ @text %>
<%# blah blah %>
<%! foo 
yadah yadah
%>

sub extract {
    my ($self,$stylesheet,@includestack) = @_;

    my $filename = $self->{stylesheet_dependencies}[0] || "stylesheet";

    my $contents = $self->read_stylesheet( $stylesheet );

    my @tokens = split /(<%[-=~#@]*|-?%>)/, $contents;

    no warnings qw/ uninitialized /;

    my $script;
    my $line = 1;
    TOKEN:
    while ( @tokens ) {
        my $token = shift @tokens;

        if ( -1 == index $token, '<%' ) {
            $line += $token =~ tr/\n//;
            $token =~ s/\s+$// if  -1 < index $tokens[0], '<%'
                               and -1 < index $tokens[0], '-';
            $token =~ s/\|/\\\|/g;
            # check for include
            $token =~ s{<!--#include.+file=(['"])(.*?)\1.*?-->}
                       { '|);'
                         . $self->include_file( $2, @includestack)
                         . 'print(q|'}seg;
            $script .= 'print(q|'.$token.'|);' if length $token;

            next TOKEN;
        }

        $script .= "\n#line $line $filename\n";

        my $opening_tag = $token;
        my $code;
        my $closing_tag;
        my $level = 1;
        while( @tokens ) {
            my $t = shift @tokens;
            $level++ if -1 < index $t, '<%';
            $level-- if -1 < index $t, '%>';
            if ( $level == 0 ) {
                $closing_tag = $t;
                last;
            }
            $code .= $t;
        }

        die "stylesheet <% %>s are unbalanced: $opening_tag$code\n"
            unless $closing_tag;

        $line += $code =~ tr/\n//;

        if ( -1 < index $opening_tag, '=' ) {
            $script .= 'print( '.$code.' );';
        }
        elsif ( -1 < index $opening_tag, '~' ) {
            $code =~ s/^\s+//; 
            $code =~ s/\s+$//; 
            $script .= 'print $processor->apply_templates( qq<'. $code .'> );';
        }
        elsif( -1 < index $opening_tag, '#' ) {
            # do nothing
        }
        elsif( -1 < index $opening_tag, '@' ) {
            $code =~ s/^\s+(\S+).*?\n//;    # strip first line
            my $tag = $1 
                or die "tag name missing in <%\@ %> at line $line\n";

            my $here_delimiter = 'END_TAG';
            while ( $code =~ /$here_delimiter/ ) {
                $here_delimiter .= 'x';
            }
            $script .= <<END_SNIPPET;
\$template->set( $tag => { content => <<'$here_delimiter' } );
$code
$here_delimiter
END_SNIPPET
        }
        else {
                    # always add a ';', just in case
            $script .= $code . ';';
        }

        if ( -1 < index $closing_tag, '-' ) {
            $tokens[0] =~ s/^\s*//;
            my $temp = $&;
            $line += $temp =~ tr/\n//;
        }
    }

    return $script;

