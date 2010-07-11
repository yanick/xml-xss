package XML::XSS::Role::StyleAttribute;

use Moose::Role;
use XML::XSS::StyleAttribute;

before '_process_options' => sub {
    my ( $class, $name, $options ) = @_;

    $options->{is}        ||= 'ro';
    $options->{isa}       ||= 'XML::XSS::StyleAttribute';
    $options->{default}   ||= sub {
        return XML::XSS::StyleAttribute->new;
    };

    $options->{handles} ||= {
        "set_$name" => 'set_value',
        "clear_$name" => 'clear_value',
        "has_$name" => 'has_value',
    };
};

1;

