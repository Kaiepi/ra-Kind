use Kind;
use Test;

plan 3;

subtest 'instantiation', {
    plan 3;

    dies-ok { Kind.new },
      'cannot create an instance of Kind using method new';
    dies-ok { Kind.bless },
      'cannot create an instance of Kind using method bless';
    dies-ok { Kind.CREATE },
      'cannot create an instance of Kind using submethod CREATE';
};

subtest 'naming', {
    my class MinimalHOW {
        my constant ARCHETYPES = Metamodel::Archetypes.new: :nominal;
        method archetypes(::?CLASS:_: $? --> ARCHETYPES) { }

        method new_type(::?CLASS:_:) is raw {
            my MinimalHOW:D $meta := self.new;
            Metamodel::Primitives.create_type: $meta, 'Uninstantiable';
        }
    }

    my class MinimalNamedHOW does Metamodel::Naming {
        my constant ARCHETYPES = Metamodel::Archetypes.new: :nominal;
        method archetypes(::?CLASS:_: Mu $? --> ARCHETYPES) { }

        method new_type(::?CLASS:_: Str:D :$name!) is raw {
            my MinimalNamedHOW:D $meta := self.new;
            my Mu                $type := Metamodel::Primitives.create_type: $meta, 'Uninstantiable';
            $meta.set_name: $type, $name;
            $type
        }
    }

    plan 4;

    is Kind[Metamodel::ClassHOW].^name,
      'Kind[Perl6::Metamodel::ClassHOW]',
      'can name a Kind whose parameter supports .perl';
    is Kind[Metamodel::Naming & Metamodel::Versioning].^name,
      'Kind[Junction]',
      'can name a Kind using the type name of its parameter if calling .perl on it throws';
    is Kind[MinimalNamedHOW.new_type: :name<Minimal>].^name,
      'Kind[Minimal]',
      'can name a Kind whose parameter does not support .perl, but has a type that supports being named';
    is Kind[MinimalHOW.new_type].^name,
      'Kind[?]',
      'can name a Kind whose parameter neither supports .perl nor has a HOW that supports naming';
};

subtest 'typechecking', {
    plan 10;

    subtest 'classes', {
        my constant Class = Kind[Metamodel::ClassHOW];

        proto sub is-class(Mu --> Bool:D)  { *}
        multi sub is-class(Class --> True) { }
        multi sub is-class(Mu --> False)   { }

        plan 2;

        ok is-class(Str),
          "can typecheck a class";
        nok is-class(Blob),
          "cannot typecheck anything else";
    };

    subtest 'roles', {
        my constant Role = Kind[Metamodel::ParametricRoleGroupHOW
                              | Metamodel::ParametricRoleHOW
                              | Metamodel::CurriedRoleHOW
                              | Metamodel::ConcreteRoleHOW];

        proto sub is-role(Mu --> Bool:D) {*}
        multi sub is-role(Role --> True) { }
        multi sub is-role(Mu --> False)  { }

        plan 5;

        ok is-role(Blob),
          "can typecheck a role group";
        ok is-role(Blob.^candidates[0]),
          "can typecheck a role";
        ok is-role(Blob[uint8]),
          "can typecheck a curried role";
        ok is-role(Blob[uint8].new.^roles[0]),
          "can typecheck a concrete role";
        nok is-role(Str),
          "cannot typecheck anything else";
    };

    subtest 'grammars', {
        # While you can typecheck grammars using the Grammar class, you can
        # configure grammars to use a different class as their base type, and you
        # can make types that claim they are any type. See the last subtest for an
        # example of the latter.
        my constant Grammar = Kind[Metamodel::GrammarHOW];

        proto sub is-grammar(Mu --> Bool:D)    {*}
        multi sub is-grammar(Grammar --> True) { }
        multi sub is-grammar(Mu --> False)     { }

        my grammar Foo { token TOP { <?> } }

        plan 2;

        ok is-grammar(Foo),
          'can typecheck a grammar';
        nok is-grammar(Mu),
          'cannot typecheck anything else';
    };

    subtest 'enums', {
        # Enumeration can be used to typecheck enums similarly to how you can
        # typecheck grammars with Grammar.
        my constant Enum = Kind[Metamodel::EnumHOW];

        proto sub is-enum(Mu --> Bool:D) {*}
        multi sub is-enum(Enum --> True) { }
        multi sub is-enum(Mu --> False)  { }

        my enum Foo <Bar Baz Qux>;

        plan 2;

        ok is-enum(Foo),
          'can typecheck an enum';
        nok is-enum(Mu),
          'cannot typecheck anything else';
    };

    subtest 'subsets', {
        my constant Subset = Kind[Metamodel::SubsetHOW];

        proto sub is-subset(Mu --> Bool:D)   {*}
        multi sub is-subset(Subset --> True) { }
        multi sub is-subset(Mu --> False)    { }

        my subset Foo;

        plan 2;

        ok is-subset(Foo),
          'can typecheck a subset';
        nok is-subset(Mu),
          'cannot typecheck anything else';
    };

    subtest 'modules', {
        my constant Module = Kind[Metamodel::ModuleHOW];

        proto sub is-module(Mu --> Bool:D)   {*}
        multi sub is-module(Module --> True) { }
        multi sub is-module(Mu --> False)    { }

        my module Foo { }

        plan 2;

        ok is-module(Foo),
          'can typecheck a module';
        nok is-module(Mu),
          'cannot typecheck anything else';
    };

    subtest 'packages', {
        my constant Package = Kind[Metamodel::PackageHOW];

        proto sub is-package(Mu --> Bool:D)    {*}
        multi sub is-package(Package --> True) { }
        multi sub is-package(Mu --> False)     { }

        my package Foo { }

        plan 2;

        ok is-package(Foo),
          'can typecheck a package';
        nok is-package(Mu),
          'cannot typecheck anything else';
    };

    subtest 'blocks', {
        my constant Parametric = Kind[{ use nqp; nqp::hllbool(nqp::can($_, 'parameterize')) }];

        plan 2;

        proto sub is-parametric(Mu --> Bool:D)       {*}
        multi sub is-parametric(Parametric --> True) { }
        multi sub is-parametric(Mu --> False)        { }

        ok is-parametric(Blob),
          'can typecheck a parametric type';
        nok is-parametric(Str),
          'cannot typecheck anything else';
    };

    subtest 'metaobjects', {
        my class Configurable {
            my Map:D %CONFIGURATIONS{ObjAt:D};

            method ^configure(Configurable:_ $this where Kind[self], %configuration --> Map:D) {
                %CONFIGURATIONS{$this.WHAT.WHICH} := %configuration.Map
            }
            method ^configuration(Configurable:_ $this where Kind[self] --> Map:D) {
                %CONFIGURATIONS{$this.WHAT.WHICH} // Map.new
            }
        }

        my class WithConfiguration is Configurable { }

        my constant Unknown = do {
            my class UnknownHOW does Metamodel::Naming {
                my constant ARCHETYPES = Metamodel::Archetypes.new: :nominal;
                method archetypes(::?CLASS:_: Mu $? --> ARCHETYPES) { }

                method new_type(::?CLASS:_: --> Mu) {
                    my UnknownHOW:D $meta := self.new;
                    my Mu           $type := Metamodel::Primitives.create_type: $meta, 'Uninstantiable';
                    Metamodel::Primitives.configure_type_checking: $type, (), :!authoritative, :call_accepts;
                    $meta.set_name: $type, 'Unknown';
                    $type
                }

                method accepts_type(UnknownHOW:D: Mu, Mu --> 1) { }
            }

            UnknownHOW.new_type
        };

        plan 3;

        lives-ok { Configurable.HOW.configure: Configurable, %() },
          "can typecheck the type a metamethod belongs to...";
        dies-ok { Configurable.HOW.configure: Unknown, %() },
          "...and cannot typecheck any other type, even if that type typechecks against anything...";
        lives-ok { WithConfiguration.HOW.configure: WithConfiguration, %() },
          "...but can still call that metamethod on types inheriting from that type";
    };

    subtest 'Rakudo metaroles', {
        plan 6;

        my Bool:D $result = False;
        lives-ok {
            $result = Mu ~~ Kind[Metamodel::AttributeContainer];
        }, 'typechecking a metaobject against Kind does not throw on a metarole...';
        ok $result,
          '...and the result is correct';
        lives-ok {
            $result = Mu ~~ Kind[Metamodel::AttributeContainer & Metamodel::REPRComposeProtocol];
        }, 'typechecking a metaobject against Kind does not throw on a junction of metaroles...';
        ok $result,
          '...and the result is correct';
        lives-ok {
            $result = Mu & Mu ~~ Kind[Metamodel::AttributeContainer & Metamodel::REPRComposeProtocol];
        }, 'typechecking a junction of metaobjects against Kind does not throw on a junction of metaroles...';
        ok $result,
          '...and the result is correct';
    };
};

# vim: ft=raku ts=4 sts=4 sw=4 et
