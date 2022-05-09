use v6;
#|[ An uninstantiable parametric type that can be used to typecheck values based
    on their kind. Once parameterized with a kind of type, smartmatching a type
    object against this will result in a typecheck based on the type's HOW. ]
unit class Kind:ver<0.2.2>:auth<github:Kaiepi>:api<1> is repr<Uninstantiable>;

#|[ Produces a subset with which an object's HOW can be typechecked. ]
method ^parameterize(Mu $obj is raw, Mu \K) is raw { Metamodel::Primitives.parameterize_type: $obj, K }

BEGIN {
    Metamodel::Primitives.set_parameterizer: $?CLASS,
        anon only PARAMETERIZE(Mu $obj is raw, [Mu \K]) is raw {
            only ACCEPTS(Mu \topic) { K.ACCEPTS(topic.HOW).so }
            only IS-TYPE(Mu \topic) { use nqp; nqp::istype_nd(topic.HOW, K) }
            my $refinee := Mu;
            my $refinement := Metamodel::Primitives.is_type(K, Mu) ?? &ACCEPTS !! &IS-TYPE;
            my $kind := Metamodel::SubsetHOW.new_type: :$refinee, :$refinement;
            $kind.^set_name: $obj.^name ~ '[' ~ NAME(K) ~ ']';
            $kind.^set_language_revision: $?CLASS.^language-revision;
            $kind
        };

    only NAME(Mu $obj is raw --> Str:D) {
        use nqp;
        (try $obj.raku if nqp::can($obj, 'raku')) orelse
        (try $obj.^name if nqp::can($obj.HOW, 'name')) orelse
        '?'
    }
}
