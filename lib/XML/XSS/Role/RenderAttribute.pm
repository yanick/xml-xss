package XML::XSS::Role::RenderAttribute;

use Moose::Role;

before '_process_options' => sub {
    my ( $class, $name, $options ) = @_;

    $options->{is}        ||= 'rw';
    $options->{reader}    ||= $name;
    $options->{writer}    ||= "set_$name";
    $options->{clearer}   ||= "clear_$name";
    $options->{predicate} ||= "has_$name";
    $options->{trigger}   ||= sub {
        my ( $self, $value ) = @_;
        my $method = "clear_$name";
        $self->$method unless defined $value;
    };
};

1;

