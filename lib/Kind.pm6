use v6;
#|[ An uninstantiable parametric type that can be used to typecheck values based
    on their kind. Once parameterized with a kind of type, smartmatching a type
    object against this will result in a typecheck based on the type's HOW. ]
unit class Kind:ver<0.2.2>:auth<github:Kaiepi>:api<1> is repr<Uninstantiable>;

#|[ Defines the API of a parameterized Kind. ]
my role Of[Mu \K] is repr<Uninstantiable> {
    #|[ Returns the kind of type with which this type object smartmatches. ]
    method kind is raw { K }

    method of is raw { K }
}

my role Of::Type is repr<Uninstantiable> { ... }

#|[ A mixin that smartmatches using a kind of Raku type. ]
my role Of::Type[Mu \K where Metamodel::Primitives.is_type: $_, Mu] does Of[K] {
    #|[ Whether or not a kind of type can smartmatch against our own. ]
    method ACCEPTS(Mu $topic is raw) { K.ACCEPTS: $topic.HOW }
}

#|[ A mixin that smartmatches using an unknown kind of type. ]
my role Of::Type[Mu \K] does Of[K] {
    #|[ Whether or not a kind of type can typecheck against our own. ]
    method ACCEPTS(Mu $topic is raw) { Metamodel::Primitives.is_type: $topic.HOW, K }
}

#|[ Mixes in a Kind::Of::Type with which types of its kind can be smartmatched. ]
method ^parameterize(Mu $obj is raw, Mu \K) is raw { Metamodel::Primitives.parameterize_type: $obj, K }

BEGIN {
    Metamodel::Primitives.set_parameterizer: $?CLASS,
        anon only PARAMETERIZE(Mu $obj is raw, [Mu \K]) is raw {
            my $mixin := $obj.^mixin: Of::Type[K];
            $mixin.^set_name: $obj.^name ~ '[' ~ NAME(K) ~ ']';
            $mixin
        };

    only NAME(Mu $obj is raw --> Str:D) {
        use nqp;
        (try $obj.raku if nqp::can($obj, 'raku')) orelse
        (try $obj.^name if nqp::can($obj.HOW, 'name')) orelse
        '?'
    }
}
