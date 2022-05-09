[![Build Status](https://travis-ci.com/Kaiepi/p6-Kind.svg?branch=master)](https://travis-ci.com/Kaiepi/p6-Kind)

NAME
====

Kind - Typechecking based on kinds

SYNOPSIS
========

```raku
use Kind;

my constant Class = Kind[Metamodel::ClassHOW];

proto sub is-class(Mu --> Bool:D)  {*}
multi sub is-class(Class --> True) { }
multi sub is-class(Mu --> False)   { }

say Str.&is-class;  # OUTPUT: True
say Blob.&is-class; # OUTPUT: False
```

DESCRIPTION
===========

Kind is an uninstantiable parametric type that can be used to typecheck values based off their kind. A parameterization produces a type object that can process the HOW of a type in a typecheck context with `ACCEPTS` when available, otherwise falling back to the bare typecheck.

Kind is documented. You can view the documentation for it and its methods at any time using `WHY`.

For examples of how to use Kind with any of Rakudo's kinds, see `t/01-kind.t`.

METAMETHODS
===========

method parameterize
-------------------

```raku
method ^parameterize(Mu $obj is raw, Mu \K) is raw
```

Produces a cached subset with a refinement (`where`) built from `K`.

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

AUTHOR
======

Ben Davies (Kaiepi)

COPYRIGHT AND LICENSE
=====================

Copyright 2020 Ben Davies

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

