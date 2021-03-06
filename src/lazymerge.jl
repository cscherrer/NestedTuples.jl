using NestedTuples

export lazymerge

"""
    lazymerge(x::NamedTuple, y::NamedTuple)

Create a `LazyMerge` struct that behaves like a recursively merged NamedTuple,
but is much faster to construct.

In addition to the usual `getproperty`, this structure supports `get`ting by
`Val` type:
```
(lm::LazyMerge).a == get(lm, Val(:a))
```

In some situatiuons, the latter can be much faster.

The original use case for this is to support using named tuples as namespaces,
especially in the context of probabilistic programming. There, it's common to
have one (possibly nested) named tuple for observed data, and another for a
proposal in an MCMC algorithm. The merge is therefore in the body of a loop
that's executed many times.
"""
function lazymerge(x, y)
    return LazyMerge(x,y)
end

struct LazyMerge{Nx,Ny,Tx,Ty}
    x::NamedTuple{Nx,Tx}
    y::NamedTuple{Ny,Ty}
end

_getx(m::LazyMerge) = getfield(m, :x)
_gety(m::LazyMerge) = getfield(m, :y)

import Base

function Base.show(io::IO, m::LazyMerge)
    io = IOContext(io, :compact => true)
    print(io, "LazyMerge(")
    print(io, _getx(m))
    print(io, ", ")
    print(io, _gety(m))
    print(io, ")")
end

function Base.getproperty(m::LazyMerge, k::Symbol) 
    return get(m, Val(k))
end

function Base.get(m::LazyMerge, Val_k::Val{k}) where {k}
    return _get(m, Val_k)
end

Base.propertynames(m::LazyMerge) = union(propertynames(_getx(m)), propertynames(_gety(m)))

_get_code(tx::Missing, ty::Missing, k) = :(error("type LazyMerge has no field ", k))

_get_code(tx, ty::Missing, k) = :(getproperty(_getx(m), k)) 
_get_code(tx::Missing, ty, k) = :(getproperty(_gety(m), k))

function _get_code(tx::NamedTuple, ty::NamedTuple, k)
    quote 
        xk = getproperty(_getx(m), k)
        yk = getproperty(_gety(m), k)
        LazyMerge(xk, yk)
    end
end

# Other than for NamedTuples, `y` gets priority if both match
# Note that this may need to be updated, e.g. for merging arrays with missing values
_get_code(tx, ty, k) = :(getproperty(_gety(m), k))

@generated function _get(m::LazyMerge{Nx,Ny,Tx,Ty}, ::Val{k}) where {Nx,Ny,Tx,Ty,k}
    x = schema(NamedTuple{Nx,Tx})
    y = schema(NamedTuple{Ny,Ty})

    tx = if (k ∈ propertynames(x)) getproperty(x, k) else missing end
    ty = if (k ∈ propertynames(y)) getproperty(y, k) else missing end

    _get_code(tx, ty, k)
end

# x = (a = (b = 1, c = 2), f = (g = 3, h = 4), g = 2) 
# y = (a = (d = 5,), e = (g = 6, j = 7), g = 3)
# m = LazyMerge(x,y)

# m.a
# m.e
# m.g
# m.f
# m.d
