use v6;
#|[ An uninstantiable parametric type that can be used to typecheck values based
    on their kind. Once parameterized with a kind of type, smartmatching a type
    object against this will result in a typecheck based on the type's HOW. ]
unit class Kind:ver<0.2.1>:auth<github:Kaiepi>:api<1> is repr<Uninstantiable>;

#|[ Defines the API of a parameterized Kind. ]
my role Of[Mu:_ \K] {
    #|[ Returns the kind of type with which this type object smartmatches. ]
    method kind(::?CLASS:U: --> Mu:_) { K }
    #|[ Stub (fails). When implemented, this should accept a type based on
        its HOW. ]
    method ACCEPTS(::?CLASS:U: Mu:_ $checker is raw) { ... }
}

#|[ A mixin that smartmatches using a kind of Raku type. ]
my role Of::Type[Mu:_ \K where Metamodel::Primitives.is_type: $_, Mu] does Of[K] {
    #|[ Whether or not a kind of type can smartmatch against our own. ]
    method ACCEPTS(::?CLASS:U: Mu:_ $checker is raw) {
        K.ACCEPTS: $checker.HOW
    }
}
#|[ A mixin that smartmatches using an unknown kind of type. ]
my role Of::Type[Mu:_ \K] does Of[K] {
    #|[ Whether or not a kind of type can typecheck against our own. ]
    method ACCEPTS(::?CLASS:U: Mu:_ $checker is raw) {
        Metamodel::Primitives.is_type: $checker.HOW, K
    }
}

#|[ Mixes in a Kind::Of::Type with which types of its kind can be smartmatched. ]
method ^parameterize(::?CLASS:U $this is raw, Mu:_ \K --> ::?CLASS:U) {
    my ::?CLASS:U $mixin := self.mixin: $this, Of::Type.^parameterize: K;
    $mixin.^set_name: self.name($this) ~ '[' ~ NAME(K) ~ ']';
    $mixin
}

sub NAME(Mu:_ $obj is raw --> Str:D) {
    use nqp;
    (try $obj.raku  if nqp::can($obj, 'raku'))     orelse
    (try $obj.^name if nqp::can($obj.HOW, 'name')) orelse
    '?'
}
