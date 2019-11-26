[![Build Status](https://travis-ci.com/Kaiepi/p6-Kind.svg?branch=master)](https://travis-ci.com/Kaiepi/p6-Kind)

NAME
====

Kind - Typechecking based on kinds

SYNOPSIS
========

```perl6
use Kind;

my constant Class = Kind[Metamodel::ClassHOW];

proto sub is-class(Mu --> Bool:D)             {*}
multi sub is-class(Mu $ where Class --> True) { }
multi sub is-class(Mu --> False)              { }

say is-class Str;  # OUTPUT: True
say is-class Blob; # OUTPUT: False
```

DESCRIPTION
===========

Kind is an uninstantiable parametric type that can be used to typecheck values based off their kind. If parameterized, it may be used in a `where` clause or on the right-hand side of a smartmatch to typecheck a value's HOW against its type parameter.

Kind is documented. You can view the documentation for it and its methods at any time using `WHY`.

For examples of how to use Kind with any of Rakudo's kinds, see `t/01-kind.t`.

METAMETHODS
===========

method parameterize
-------------------

    method ^parameterize(Kind:U $this, Mu \K --> Kind:U) { }

Mixes in a `kind` method to `$this` that returns `K`.

Some useful values with which to parameterize Kind are:

  * a metaclass or metarole

```perl6
# Smartmatches any class.
Kind[Metamodel::ClassHOW]
```

  * a junction of metaclasses or metaroles

```perl6
# Smartmatches any type that supports naming, versioning, and documenting.
Kind[Metamodel::Naming & Metamodel::Versioning & Metamodel::Documenting]
```

  * a block

```perl6
# Smartmatches any parameterized type.
Kind[{ use nqp; nqp::typeparameterized($_) !=:= nqp::null() }]
```

  * a metaobject

```perl6
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
```

METHODS
=======

method ACCEPTS
--------------

    method ACCEPTS(Kind:U: Mu $checker --> Bool:D) { }

Returns `True` if the HOW of `$checker` smartmatches against `Kind`'s type parameter, otherwise returns `False`.

method kind
-----------

    method kind(Kind:U: --> Mu) { }

If `Kind` has been parameterized, returns its type parameter, otherwise fails.

AUTHOR
======

Ben Davies (Kaiepi)

COPYRIGHT AND LICENSE
=====================

Copyright 2019 Ben Davies

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

