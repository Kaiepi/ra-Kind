use v6.d;
#|[ An uninstantiable parametric type that can be used to typecheck values based
    on their kind. Once parameterized, smartmatching a value against it will only
    succeed if the value's HOW smartmatches against its type parameter. Attempting
    to smartmatch against it before then will throw. ]
unit class Kind:ver<0.1.0>:auth<github:Kaiepi>:api<0>
        is repr<Uninstantiable>;

#|[ Fails. Once this type is parameterized, this method will return its type
    parameter. ]
method kind(Kind:U: --> Mu) { !!! }

#|[ Used to mix in a "kind" method to this type, returning the value it was
    parameterized with. ]
my role Instance[Mu \K] {
    #|[ Returns this type's type parameter. ]
    method kind(Kind:U: --> Mu) { K }
}

#|[ Handles typechecking for kinds that have an ACCEPTS method. ]
my role Accepts[Mu \K] does Instance[K] {
    #|[ Smartmatches its argument's HOW against this type's type parameter. ]
    method ACCEPTS(Kind:U: Mu $checker --> Bool:D) {
        so $checker.HOW ~~ K
    }
}

#|[ Handles typechecking for kinds that do not have an ACCEPTS method. This is
#|  the case when Rakudo's metaroles are passed as type parameters, since they
#|  do not have Mu's methods. ]
my role IsType[Mu \K] does Instance[K] {
    #|[ Calls Metamodel::Primitives.is_type with its argument's HOW and this
    #|  type's type parameter. ]
    method ACCEPTS(Kind:U: Mu $checker --> Bool:D) {
        Metamodel::Primitives.is_type: $checker.HOW, K
    }
}

#|[ Returns the role to mix in to Kind (either Accepts or IsType, parameterized
#|  with the kind passed). ]
sub role-for(Mu \K --> Mu) {
    use nqp;
    nqp::hllbool(nqp::can(K, 'ACCEPTS'))
        ?? Accepts.^parameterize(K)
        !! IsType.^parameterize(K)
}

#|[ Generates a name for a kind. ]
sub name-of(Mu $obj is raw --> Str:D) {
    use nqp;
    (do (try $obj.perl)     if nqp::hllbool(nqp::can($obj, 'perl')))
 // (do $obj.HOW.name($obj) if nqp::hllbool(nqp::istype($obj.HOW, Metamodel::Naming)))
 // '?'
}

#|[ Mixes in the Kind::Instance parametric role, which provides a "kind" method
    returning the given type parameter. ]
method ^parameterize(Kind:U $this, Mu \K --> Kind:U) {
    my Mu $mixin := self.mixin: $this, role-for K;
    $mixin.^set_name: self.name($this) ~ '[' ~ name-of(K) ~ ']';
    $mixin
}
