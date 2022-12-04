use v6;
#|[ An uninstantiable parametric type that can be used to typecheck values based
    on their kind. Once parameterized with a kind of type, smartmatching a type
    object against this will result in a typecheck based on the type's HOW. ]
unit class Kind:ver<0.2.2>:auth<github:Kaiepi>:api<1> is repr<Uninstantiable>;

# Produces a refinement on CALL-ME.
my class Refine does Callable is repr<Uninstantiable> { ... }

#|[ Delegates to ^kind. ]
method ^parameterize(|args) is raw {
    self.kind: |args
}

#|[ Produces a subset with which an object's HOW can be typechecked. ]
method ^kind(Mu $obj is raw, Mu \K) is raw {
    Metamodel::Primitives.parameterize_type: $obj, (K,)
}

#|[ Applies a parameterizer to a metaobject so as to support ^kind. ]
our sub set_parameterizer(Mu $obj is raw, &parameterizer = &parameterize --> Nil) {
    Metamodel::Primitives.set_parameterizer: $obj, &parameterizer
}
#=[ The metaobject doesn't need to be a true Kind, but the parameterizer should
    generally incorporate &parameterize in some way, otherwise you're better off
    writing a new type. ]

#|[ The routine that produces the actual subset cached by ^kind. ]
our sub parameterize(Mu $root is raw, Any $args) is raw {
    my $refinement := Refine(my \K := $args.AT-POS(0));
    my $name := $root.^name ~ '[' ~ (name K) ~ ']';
    my $obj := Metamodel::SubsetHOW.new_type: :$name, :refinee(Mu), :$refinement;
    $obj.^set_language_revision: $root.^language-revision;
    $obj
}

sub name(Mu $obj is raw --> Str:D) {
    use nqp;
    (try $obj.raku if nqp::can($obj, 'raku'))
        orelse ($obj.^name if nqp::can($obj.HOW, 'name'))
        orelse '?'
}

my class Refine is Mu {
    proto method CALL-ME(Mu) {*}
    multi method CALL-ME(Mu $topic is raw) {
        self.ACCEPTS: $topic<>
    }
    multi method CALL-ME(Junction:D $junction is copy) {
        # We need to wrap uninvokable refinements to appease Rakudo.
        # Mu.ACCEPTS makes for a method of invoking Junction.THREAD.
        $junction := self.ACCEPTS: $junction;
        anon sub accepts(Mu $topic) is pure { $junction.ACCEPTS: $topic }
    }

    # A Mu parameter is actually untyped. An nqp-ish metaobject (e.g. Rakudo's
    # metaroles) are not actually Mu, and thus demand a special smartmatch.
    multi method ACCEPTS(Mu \K) {
        Metamodel::Primitives.is_type(K, Mu) ?? (match K) !! (check K)
    }

    # Smartmatch handler. We need to match HOWs generally, but Junction.ACCEPTS
    # can't cope with when its components aren't Mu, so abuse Junction.THREAD.
    proto sub match(Mu) {*}
    multi sub match(Mu \K) {
        anon sub accepts-higher(Mu $topic) is pure { ?K.ACCEPTS: $topic.HOW }
    }
    multi sub match(Junction:D $junction) {
        $?CLASS.ACCEPTS: $junction
    }

    # Typecheck handler. We can assume an object that isn't Mu isn't HLL
    # either, so spare any delegation to Metamodel::Primitives.is_type.
    sub check(Mu \K) {
        use nqp;
        anon sub is-type(Mu $topic) is pure { nqp::hllbool(nqp::istype_nd($topic.HOW,K)) }
    }
}

BEGIN set_parameterizer $?CLASS;
