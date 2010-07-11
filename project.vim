xml-xss=~/work/perl-modules/XML-XSS CD=. {
lib Files=lib {
    XML/XSS.pm
    XML/XSS/Element.pm
    XML/XSS/Text.pm
    XML/XSS/Comment.pm
    XML/XSS/Document.pm
    XML/XSS/ProcessingInstruction.pm
    XML/XSS/StyleAttribute.pm
    XML/XSS/Role/Renderer.pm
    XML/XSS/Role/StyleAttribute.pm
    XML/XSS/Template.pm
}
test Files=t {
    basic.t
    text.t
    lib/XML/XSSTest.pm
    lib/XML/XSS/CommentTest.pm
    lib/XML/XSS/TemplateTest.pm
    lib/XML/XSS/ElementTest.pm
    lib/XML/XSS/OverloadTest.pm
}
}
