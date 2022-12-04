use v6;
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

subtest 'inheritance', {
    plan 2;

    subtest 'input mapping', {
        my class Kind::Of::Type is Kind is repr<Uninstantiable> {
            method ^parameterize(Mu $obj is raw, Mu \K, |rest) {
                self.kind: $obj, K.HOW.WHAT, |rest
            }

            BEGIN Kind::set_parameterizer($?CLASS);
        }

        plan 2;

        my $result = False;
        lives-ok {
            $result = Mu ~~ Kind::Of::Type[class { }];
        }, 'smartmatching against a subtype of Kind does not throw...';
        ok $result,
          '...and the result is correct';
    };

    subtest 'output mapping', {
        my class Kind::Old is Kind is repr<Uninstantiable> {
            # XXX: Could be inlined into Kind::Old in theory, but is uninstantiable
            # from the parameterizer as a P6opaque. Anything but the root seems OK.
            class Descriptor {
                has $.kind is built(:bind);
                has $!type is built(:bind);

                multi method ACCEPTS(::?CLASS:D: Mu $topic is raw) is raw {
                    $!type.ACCEPTS: $topic
                }
            }

            sub parameterize(Mu $root is raw, Any $args) {
                Descriptor.bless: :kind($args.AT-POS: 0), :type(Kind::parameterize($root, $args))
            }

            BEGIN Kind::set_parameterizer($?CLASS, &parameterize);
        }

        plan 2;

        my $result = False;
        lives-ok {
            $result = Mu ~~ Kind::Old[Metamodel::ClassHOW];
        }, 'smartmatching against a subtype of Kind does not throw...';
        ok $result,
          '...and the result is correct';
    };
};

# vim: ft=raku sw=4 ts=4 sts=4 et
