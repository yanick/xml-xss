package XML::XSS::Role::RenderAttribute;

use Moose::Role;
use XML::XSS::RenderAttribute;

before '_process_options' => sub {
    my ( $class, $name, $options ) = @_;

    $options->{is}        ||= 'ro';
    $options->{isa}       ||= 'XML::XSS::RenderAttribute';
    $options->{default}   ||= sub {
        return XML::XSS::RenderAttribute->new;
    };

    $options->{handles} ||= {
        "set_$name" => 'set_value',
        "clear_$name" => 'clear_value',
        "has_$name" => 'has_value',
    };
};

1;

