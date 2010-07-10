xml-xss=~/work/perl-modules/xml-xss CD=. {
lib Files=lib {
    XML/XSS.pm
    XML/XSS/Element.pm
    XML/XSS/Text.pm
    XML/XSS/Comment.pm
    XML/XSS/Document.pm
    XML/XSS/ProcessingInstruction.pm
    XML/XSS/Role/Renderer.pm
    XML/XSS/Role/RenderAttribute.pm
    XML/XSS/Role/Template.pm
}
test Files=t {
    basic.t
    text.t
    lib/XML/XSSTest.pm
    lib/XML/XSS/CommentTest.pm
    lib/XML/XSS/TemplateTest.pm
    lib/XML/XSS/OverloadTest.pm
}
}
