# NestedTuples

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://cscherrer.github.io/NestedTuples.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://cscherrer.github.io/NestedTuples.jl/dev)
[![Build Status](https://github.com/cscherrer/NestedTuples.jl/workflows/CI/badge.svg)](https://github.com/cscherrer/NestedTuples.jl/actions)
[![Coverage](https://codecov.io/gh/cscherrer/NestedTuples.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/cscherrer/NestedTuples.jl)
[![ColPrac: Contributor's Guide on Collaborative Practices for Community Packages](https://img.shields.io/badge/ColPrac-Contributor's%20Guide-blueviolet)](https://github.com/SciML/ColPrac)

`NestedTuples` has some tools for making it easier to work with nested tuples and nested named tuples.

To avoid type piracy, we introduce a new constructor `Nested`:
```julia
julia> x = Nested(a=1, b=(c=[2,3],d=(4,5)))
Nested((a = 1, b = (c = [2, 3], d = (4, 5))))
```

# Type-level manipulations

One nice property of (named) tuples is that there's so much information available in the types. This is especially important for generated functions (which we also use here to make things fast). But the types tend to be awkward to work with. For example,
```julia
julia> typeof(x)
Nested{NamedTuple{(:a, :b),Tuple{Int64,NamedTuple{(:c, :d),Tuple{Array{Int64,1},Tuple{Int64,Int64}}}}}}
```

This package introduces `fromtype` to rebuild the structure from its type:
```julia
julia> typeof(x) |> fromtype
Nested((a = Int64, b = (c = Array{Int64,1}, d = (Int64, Int64))))
```

# Lenses

It's often useful to replace the data in the leaves of the tree formed by a nested structure. For this we make it easy to compute the lenses to get to the leaves, using [`Setfield.jl`](https://github.com/jw3126/Setfield.jl):
```julia
julia> x
Nested((a = 1, b = (c = [2, 3], d = (4, 5))))

julia> ℓ = lenses(x)
((@lens _.a), (@lens _.b.c), (@lens _.b.d[1]), (@lens _.b.d[2]))

julia> set(x, ℓ[2], randn(3))
Nested((a = 1, b = (c = [2.6670790234937862, 1.2514402388838717, -0.9436148268973016], d = (4, 5))))
```

We can also use [`Kaleido.jl`](https://github.com/tkf/Kaleido.jl) to set all of the leaves at once:
```julia
julia> b = batch(lenses(x)...)
IndexBatchLens(:a, :b) ∘ 〈◻[1] ∘ Kaleido.SingletonLens(), ◻[2] ∘ IndexBatchLens(:c, :d) ∘ 〈◻[1] ∘ Kaleido.SingletonLens(), ◻[2] ∘ 〈◻[1], ◻[2]〉〉 ∘ FlatLens(1, 2)〉 ∘ FlatLens(1, 3)

julia> set(x, b, (1,2,3,4))
Nested((a = 1, b = (c = 2, d = (3, 4))))
```

# PlaceHolders

In some cases the values can be distracting, and it's useful to have the structure "by itself". For that we have `PlaceHolder`s, which render as □. Using this, we can get
```julia
julia> empty(x)
Nested((a = □, b = (c = □, d = (□, □))))
```

