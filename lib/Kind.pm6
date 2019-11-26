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

