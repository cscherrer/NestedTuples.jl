# NestedTuples

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://cscherrer.github.io/NestedTuples.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://cscherrer.github.io/NestedTuples.jl/dev)
[![Build Status](https://github.com/cscherrer/NestedTuples.jl/workflows/CI/badge.svg)](https://github.com/cscherrer/NestedTuples.jl/actions)
[![Coverage](https://codecov.io/gh/cscherrer/NestedTuples.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/cscherrer/NestedTuples.jl)
[![ColPrac: Contributor's Guide on Collaborative Practices for Community Packages](https://img.shields.io/badge/ColPrac-Contributor's%20Guide-blueviolet)](https://github.com/SciML/ColPrac)

`NestedTuples` has some tools for making it easier to work with nested tuples and nested named tuples.

# Random nested tuples

`randnt` is useful for testing. Here's a random nested tuple with width 2 and depth 3:
```julia
julia> nt = randnt(2,3)
(w = (d = (p = :p, l = :l), e = (m = :m, v = :v)), q = (y = (r = :r, o = :o), g = (y = :y, h = :h)))
```

# Schema

Does what it says on the tin:
```julia
julia> schema(nt)
(w = (d = (p = Symbol, l = Symbol), e = (m = Symbol, v = Symbol)), q = (y = (r = Symbol, o = Symbol), g = (y = Symbol, h = Symbol)))
```

`schema` is especially great for building generated functions on named tuples, because it works on types too:

```julia
julia> schema(typeof(nt))
(w = (d = (p = Symbol, l = Symbol), e = (m = Symbol, v = Symbol)), q = (y = (r = Symbol, o = Symbol), g = (y = Symbol, h = Symbol)))
```

# Flatten

```julia
julia> flatten(nt)
(:p, :l, :m, :v, :r, :o, :y, :h)
```

# Recursive `map`

```julia
julia> rmap(String, nt)
(w = (d = (p = "p", l = "l"), e = (m = "m", v = "v")), q = (y = (r = "r", o = "o"), g = (y = "y", h = "h")))
```

# Recursively sort keys

Use `keysort` for this.

```julia
julia> @btime keysort($nt)
  0.020 ns (0 allocations: 0 bytes)
(q = (g = (h = :h, y = :y), y = (o = :o, r = :r)), w = (d = (l = :l, p = :p), e = (m = :m, v = :v)))
```

# Leaf setter

`leaf_setter` takes a nested named tuple and builds a function that sets the values on the leaves.

```julia
julia> f = leaf_setter(nt)
function = (##777, ##778, ##779, ##780, ##781, ##782, ##783, ##784;) -> begin
    begin
        (w = (d = (p = var"##777", l = var"##778"), e = (m = var"##779", v = var"##780")), q = (y = (r = var"##781", o = var"##782"), g = (y = var"##783", h = var"##784")))
    end
end

julia> @btime $f(1:8...)
  0.020 ns (0 allocations: 0 bytes)
(w = (d = (p = 1, l = 2), e = (m = 3, v = 4)), q = (y = (r = 5, o = 6), g = (y = 7, h = 8)))
```

# Fold

`fold` is a "structural fold". You give it a function `f`, and the result will apply `f` at the leaves, and then combine leaves recursively also using `f`. It also allows an optional third argument as a `pre` function to be applied on the way down to the leaves. This is probably clearer from an example:

```julia
function example_fold(x) 
    pathsize = 10
    function pre(x, path)
        print("↓ path = ")
        print(rpad(path, pathsize))
        println("value = ", x)
        return x
    end 

    function f(x::Union{Tuple, NamedTuple}, path)
        print("↑ path = ")
        print(rpad(path, pathsize))
        println("value = ", x)
        return x
    end 

    function f(x, path)
        print("↑ path = ")
        print(rpad(path, pathsize))
        print("value = ", x)
        println(" ←-- LEAF")
        return x
    end 

    fold(f, x, pre)
end

julia> example_fold(nt)
↓ path = ()        value = (w = (d = (p = :p, l = :l), e = (m = :m, v = :v)), q = (y = (r = :r, o = :o), g = (y = :y, h = :h)))
↓ path = (:w,)     value = (d = (p = :p, l = :l), e = (m = :m, v = :v))
↓ path = (:w, :d)  value = (p = :p, l = :l)
↓ path = (:w, :d, :p)value = p
↑ path = (:w, :d, :p)value = p ←-- LEAF
↓ path = (:w, :d, :l)value = l
↑ path = (:w, :d, :l)value = l ←-- LEAF
↑ path = (:w, :d)  value = (p = :p, l = :l)
↓ path = (:w, :e)  value = (m = :m, v = :v)
↓ path = (:w, :e, :m)value = m
↑ path = (:w, :e, :m)value = m ←-- LEAF
↓ path = (:w, :e, :v)value = v
↑ path = (:w, :e, :v)value = v ←-- LEAF
↑ path = (:w, :e)  value = (m = :m, v = :v)
↑ path = (:w,)     value = (d = (p = :p, l = :l), e = (m = :m, v = :v))
↓ path = (:q,)     value = (y = (r = :r, o = :o), g = (y = :y, h = :h))
↓ path = (:q, :y)  value = (r = :r, o = :o)
↓ path = (:q, :y, :r)value = r
↑ path = (:q, :y, :r)value = r ←-- LEAF
↓ path = (:q, :y, :o)value = o
↑ path = (:q, :y, :o)value = o ←-- LEAF
↑ path = (:q, :y)  value = (r = :r, o = :o)
↓ path = (:q, :g)  value = (y = :y, h = :h)
↓ path = (:q, :g, :y)value = y
↑ path = (:q, :g, :y)value = y ←-- LEAF
↓ path = (:q, :g, :h)value = h
↑ path = (:q, :g, :h)value = h ←-- LEAF
↑ path = (:q, :g)  value = (y = :y, h = :h)
↑ path = (:q,)     value = (y = (r = :r, o = :o), g = (y = :y, h = :h))
↑ path = ()        value = (w = (d = (p = :p, l = :l), e = (m = :m, v = :v)), q = (y = (r = :r, o = :o), g = (y = :y, h = :h)))
(w = (d = (p = :p, l = :l), e = (m = :m, v = :v)), q = (y = (r = :r, o = :o), g = (y = :y, h = :h)))
```

