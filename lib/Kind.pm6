use v6.d;
#|[ An uninstantiable parametric type that can be used to typecheck values based
    on their kind. Once parameterized, smartmatching a value against it will only
    succeed if the value's HOW smartmatches against its type parameter. Attempting
    to smartmatch against it before then will throw. ]
unit class Kind:ver<0.0.1>:auth<github:Kaiepi>:api<0>
        is repr<Uninstantiable>;

#|[ Used to mix in a "kind" method to this type, returning the value it was
    parameterized with. ]
my role Instance[Mu \K] {
    #|[ Returns this type's type parameter. ]
    method kind(Kind:U: --> Mu) { K }
}

#|[ Mixes in the Kind::Instance parametric role, which provides a "kind" method
    returning the given type parameter. ]
method ^parameterize(Kind:U $this, Mu \K --> Kind:U) {
    # Gets a name for K. Try to use .perl if the method exists (this may throw,
    # like when using a junction of metaroles), then try to get K's type name
    # if .perl couldn't be used and K's type supports naming, then use "?" if
    # we still don't have a name by this point.
    sub name-of(Mu $obj is raw --> Str:D) {
        use nqp;
        (do (try $obj.perl)     if nqp::hllbool(nqp::can($obj, 'perl')))
     // (do $obj.HOW.name($obj) if nqp::hllbool(nqp::istype($obj.HOW, Metamodel::Naming)))
     // '?'
    }

    my Mu $mixin := $this.^mixin: Instance.^parameterize: K;
    $mixin.^set_name: self.name($this) ~ '[' ~ name-of(K) ~ ']';
    $mixin
}

#|[ Smartmatches its argument against this type's type parameter. ]
method ACCEPTS(Kind:U: Mu $checker --> Bool:D) {
    so $checker.HOW ~~ $.kind
}

#|[ Fails. Once this type is parameterized, this method will return its type
    parameter. ]
method kind(Kind:U: --> Mu) { ... }

=begin pod

=head1 NAME

Kind - Typechecking based on kinds

=head1 SYNOPSIS

=begin code :lang<perl6>
use Kind;

my constant Class = Kind[Metamodel::ClassHOW];

proto sub is-class(Mu --> Bool:D)             {*}
multi sub is-class(Mu $ where Class --> True) { }
multi sub is-class(Mu --> False)              { }

say is-class Str;  # OUTPUT: True
say is-class Blob; # OUTPUT: False
=end code

=head1 DESCRIPTION

Kind is an uninstantiable parametric type that can be used to typecheck values
based off their kind. If parameterized, it may be used in a C<where> clause or
on the right-hand side of a smartmatch to typecheck a value's HOW against its
type parameter.

Kind is documented. You can view the documentation for it and its methods at
any time using C<WHY>.

For examples of how to use Kind with any of Rakudo's kinds, see C<t/01-kind.t>.

=head1 METAMETHODS

=head2 method parameterize

    method ^parameterize(Kind:U $this, Mu \K --> Kind:U) { }

Mixes in a C<kind> method to C<$this> that returns C<K>.

Some useful values with which to parameterize Kind are:

=item a metaclass or metarole

=begin code :lang<perl6>
# Smartmatches any class.
Kind[Metamodel::ClassHOW]
=end code

=item a junction of metaclasses or metaroles

=begin code :lang<perl6>
# Smartmatches any type that supports naming, versioning, and documenting.
Kind[Metamodel::Naming & Metamodel::Versioning & Metamodel::Documenting]
=end code

=item a block

=begin code :lang<perl6>
# Smartmatches any parameterized type.
Kind[{ use nqp; nqp::typeparameterized($_) !=:= nqp::null() }]
=end code

=item a metaobject

=begin code :lang<perl6>
# This class' metamethods ensure only instances of it can be passed to them.
# Without Kind, any type that can typecheck as it would be possible to pass
# (see t/01-kind.t for an example of this).
class Configurable {
    my Map:D %CONFIGURATIONS{ObjAt:D};

    method ^configure(Configurable:_ $this where Kind[self], %configuration --> Map:D) {
        %CONFIGURATIONS{$this.WHAT.WHICH} := %configuration.Map
    }
    method ^configuration(Configurable:_ $this where Kind[self] --> Map:D) {
        %CONFIGURATIONS{$this.WHAT.WHICH} // Map.new
    }
}
=end code

=head1 METHODS

=head2 method ACCEPTS

    method ACCEPTS(Kind:U: Mu $checker --> Bool:D) { }

Returns C<True> if the HOW of C<$checker> smartmatches against C<Kind>'s type
parameter, otherwise returns C<False>.

=head2 method kind

    method kind(Kind:U: --> Mu) { }

If C<Kind> has been parameterized, returns its type parameter, otherwise
fails.

=head1 AUTHOR

Ben Davies (Kaiepi)

=head1 COPYRIGHT AND LICENSE

Copyright 2019 Ben Davies

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
