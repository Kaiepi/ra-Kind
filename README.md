[![Build Status](https://travis-ci.com/Kaiepi/p6-Kind.svg?branch=master)](https://travis-ci.com/Kaiepi/p6-Kind)

NAME
====

Kind - Typechecking based on kinds

SYNOPSIS
========

```raku
use Kind;

my constant Class = Kind[Metamodel::ClassHOW];

proto sub is-class(Mu --> Bool:D)             {*}
multi sub is-class(Mu $ where Class --> True) { }
multi sub is-class(Mu --> False)              { }

say Str.&is-class;  # OUTPUT: True
say Blob.&is-class; # OUTPUT: False
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

```raku
method ^parameterize(Kind:U $this is raw, Mu \K --> Kind:U) { }
```

Mixes in `kind` and `ACCEPTS` methods. See below.

Some useful values with which to parameterize Kind are:

  * a metaclass or metarole

```raku
# Smartmatches any class.
Kind[Metamodel::ClassHOW]
```

  * a junction of metaclasses or metaroles

```raku
# Smartmatches any type that supports naming, versioning, and documenting.
Kind[Metamodel::Naming & Metamodel::Versioning & Metamodel::Documenting]
```

  * a block

```raku
# Smartmatches any parametric type.
Kind[{ use nqp; nqp::hllbool(nqp::can($_, 'parameterize')) }]
```

  * a metaobject

```raku
# This class' metamethods ensure they can only be called with itself or its
# subclasses.
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

```raku
method ACCEPTS(Kind:U: Mu $checker is raw) { }
```

Returns `True` if the HOW of `$checker` typechecks against `Kind`'s type parameter, otherwise returns `False`.

If `Kind`'s type parameter has an `ACCEPTS` method, this will smartmatch the HOW of `$checker` against it; otherwise, `Metamodel::Primitives.is_type` will be called with `$checker`'s HOW and it. Most of the time, the former will be the case; the latter behaviour exists because it's not guaranteed `K` will actually have `Mu`'s methods (this is case with Rakudo's metaroles).

method kind
-----------

```raku
method kind(Kind:U: --> Mu) { }
```

Returns `Kind`'s type parameter.

AUTHOR
======

Ben Davies (Kaiepi)

COPYRIGHT AND LICENSE
=====================

Copyright 2020 Ben Davies

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

