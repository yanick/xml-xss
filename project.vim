xml-xss=~/work/perl-modules/XML-XSS CD=. {
lib Files=lib {
    XML/XSS.pm
    XML/XSS/Element.pm
    XML/XSS/Text.pm
    XML/XSS/Comment.pm
    XML/XSS/Document.pm
    XML/XSS/Role/Renderer.pm
    XML/XSS/Role/RenderAttribute.pm
}
test Files=t {
    basic.t
    text.t
    lib/XML/XSS/CommentTest.pm
}
}
