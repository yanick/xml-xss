package XML::XSS::Document;
BEGIN {
  $XML::XSS::Document::VERSION = '0.1.3';
}
# ABSTRACT: XML::XSS document stylesheet rule


use Moose;
use MooseX::SemiAffordanceAccessor;

with 'XML::XSS::Role::Renderer';

no warnings qw/ uninitialized /;


has use_clean_stash => (
    default => 1,
    is      => 'rw',
);

has [ qw/ pre post / ] => ( traits => [ qw/ XML::XSS::Role::StyleAttribute / ] );


sub apply {
    my ( $self, $node, $args ) = @_;
    $args ||= {};

    $self->stylesheet->clear_stash if $self->use_clean_stash;

    my $output =  $self->_render( 'pre', $node, $args );
    $output .= $self->render( $node->childNodes, $args );
    $output .= $self->_render( 'post', $node, $args );

    return $output;
}

1;



=pod

=head1 NAME

XML::XSS::Document - XML::XSS document stylesheet rule

=head1 VERSION

version 0.1.3

=head1 SYNOPSIS

    use XML::XSS;

    my $xss = XML::XSS->new;

    my $doc_style = $xss->document;

    $doc_style->set_pre( "=pod\n" );
    $doc_style->set_post( "=cut\n" );

    print $xss->render( '<doc>yadah yadah</doc>' );

=head1 DESCRIPTION

A C<XML::XSS> rule that matches against the document to
be rendered.  

Note that this is the C<XML::LibXML::Document> object,
and not the document root element.

=head1 ATTRIBUTES 

=head2 use_clean_stash

If set to true, which is the default, the stash cleared before a new 
document is rendered.  

=head3 use_clean_stash()

Accessor getter.

=head3 set_use_clean_stash($bool)

Accessor setter.

=head1 RENDERING ATTRIBUTES

For a document, the displayed attributes follow the template:

    pre
    [document nodes]
    post

=head2 pre

Printed before the document's nodes.

=head2 post

Printed after the document nodes.

=head2 METHODS

=head3 set( %attrs )

A shortcut to the attribute setters.

    $doc_style->set( 
        pre  => 'foo',
        post => 'bar',
    );
    # equivalent to 
    $doc_style->set_pre( 'foo' );
    $doc_style->set_post( 'bar' );

=head3 apply( $node, $args )

Applies the rule to the C<$node>, passing along the optional C<$args>,
and returns the resulting string.

=head1 AUTHOR

  Yanick Champoux <yanick@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by Yanick Champoux.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
