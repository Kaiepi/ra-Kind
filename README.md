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

Kind is documented. You can view the documentation for it and its methods at any time using `WHY`. For more examples of how to work with Kind, refer to `t/01-kind.t`.

METAMETHODS
===========

method parameterize
-------------------

```raku
method ^parameterize(|args) is raw
```

Produces a parameterization by delegating to `^kind` with `args`.

method kind
-----------

```raku
method ^kind(Mu $obj is raw, Mu \K, Mu:U \T = Mu) is raw
```

Produces a cached subset with a refinement (`where`) built from `K` and a refinement (`of`) from `T` if present. This backs `^parameterize` so as to allow for a different parameterizer in a subtype. This is more or less a wrapper for `Metamodel::Primitives.parameterize_type`.

Some useful values with which to produce a type are:

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
# This class' metamethods constrain their metaobject to itself or its subtypes.
class Configurable {
    my constant K := Kind[$?CLASS.HOW.WHAT, $?CLASS];

    my constant %configuration := hash;

    method ^configure(K $obj, %config --> Map:D) {
        %configuration{$obj.WHAT.WHICH} := %config.Map
    }

    method ^configuration(K $obj --> Map:D) {
        %configuration{$obj.WHAT.WHICH} // Map.new
    }
}
```

SYMBOLS
=======

&set_parameterizer
------------------

```raku
our sub set_parameterizer(Mu $obj is raw, &parameterizer = &parameterize --> Nil)
```

Applies the parameterizer of `Kind` to a metaobject, providing it with a parameterization cache. A subtype needs to apply this at `BEGIN`-time in order to parameterize with the default metamethods, for instance:

```raku
class Kind::Instantiable is Kind {
    BEGIN Kind::set_parameterizer($?CLASS);
}
```

A `&parameterizer` may be provided, in which case that will be set instead. This should carry a compatible signature with `&parameterize`.

&parameterize
-------------

```raku
our sub parameterize(Mu $root is raw, Any $args) is raw
```

Given the `$root` metaobject of the parameterization and its `$args`, produces a type object minus the caching. `$args` is assumed to carry `K` at position `0` and `T`, if present, at position `1`.

AUTHOR
======

Ben Davies (Kaiepi)

COPYRIGHT AND LICENSE
=====================

Copyright 2020 Ben Davies

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

