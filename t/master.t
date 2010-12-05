use strict;
use warnings;

use Test::More tests => 1;                      # last test to print

use lib 't/lib';

use XML::XSS;

my $xss = XML::XSS->new;

my $master = $xss->master;

ok $master, 'master()';

$master->set( 'foo' => { pre => 'X' } );

my $r = XML::XSS->new->render( '<doc><foo>hi</foo></doc>' );

is $r => '<doc>Xhi</doc>', 'stylesheet inherit from master';

use A;
use B;

my $xml = "<doc><a/><b/><c/></doc>";

$DB::single = 1;

is( A->new->render( $xml ), '<doc>A<b></b><c></c></doc>' );
is( B->new->render( $xml ), '<doc>AB<c></c></doc>' );

my $full_xml = <<'END';
<doc>
    <a>aaa</a>
    <!-- comment -->
    <?foo attr="bar" ?>
    some text
</doc>
END

is( B->new->render( $full_xml ), '' );

