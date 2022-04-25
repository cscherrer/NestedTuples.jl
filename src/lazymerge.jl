using NestedTuples

export lazymerge
import Base
using Static 

struct LazyMerge{X,Y}
    x::X
    y::Y

    function LazyMerge(x::X, y::Y) where {X,Y}
        new{X,Y}(x,y)
    end
end

"""
    lazymerge(x::NamedTuple, y::NamedTuple)

Create a `LazyMerge` struct that behaves like a recursively merged NamedTuple,
but is much faster to construct.

In addition to the usual `getproperty`, this structure supports `get`ting by
static keys:
```
(lm::LazyMerge).a == get(lm, static(:a))
```

In some situatiuons, the latter can be much faster.

The original use case for this is to support using named tuples as namespaces,
especially in the context of probabilistic programming. There, it's common to
have one (possibly nested) named tuple for observed data, and another for a
proposal in an MCMC algorithm. The merge is therefore in the body of a loop
that's executed many times.
"""
function lazymerge end


NTLike = Union{L,N} where {L<:LazyMerge, N<:NamedTuple}


lazymerge(a, ::Missing) = a
lazymerge(a, b) = b

lazymerge(::NamedTuple{()}, ::NamedTuple{()}) = NamedTuple()
lazymerge(nt::NTLike, ::NamedTuple{()}) = nt
lazymerge(::NamedTuple{()}, nt::NTLike) = nt
lazymerge(a::NTLike, b::NTLike) = LazyMerge(a,b)

lazymerge() = NamedTuple()
lazymerge(a) = a
lazymerge(a,b,c) = lazymerge(lazymerge(a,b), c)
lazymerge(a, b, c, d, es...) = lazymerge(lazymerge(a,b), lazymerge(c,d), lazymerge(es...))

function lazymerge(a::A, b::B) where {A<:AbstractArray, B<:AbstractArray}
    missing isa eltype(A) || return b
    return LazyMerge(a,b)
end

export _getx, _gety

_getx(m::LazyMerge) = getfield(m, :x)
_gety(m::LazyMerge) = getfield(m, :y)

schema(lm::LazyMerge{X,Y}) where {X,Y} = lazymerge(schema(X), schema(Y))
schema(::Type{LazyMerge{X,Y}}) where {X,Y} = lazymerge(schema(X), schema(Y))

import Base

function Base.show(io::IO, m::LazyMerge)
    io = IOContext(io, :compact => true)
    print(io, "LazyMerge(")
    print(io, _getx(m))
    print(io, ", ")
    print(io, _gety(m))
    print(io, ")")
end

@inline function Base.getproperty(m::LazyMerge{X,Y}, k::Symbol) where {X<:NTLike,Y<:NTLike}
    getproperty(m, static(k))
end



@inline function Base.getproperty(m::LazyMerge{X,Y}, ::StaticSymbol{k}) where {X<:NTLike,Y<:NTLike, k}
    result = _get(m, static(k))
    result === NoResult() && throw(KeyError(k))
    return result
    # x = _getx(m)
    # y = _gety(m)

    # tx = get(x, k, NamedTuple())
    # ty = get(y, k, NamedTuple())
    
    # return lazymerge(tx, ty)
end

@inline function Base.get(m::LazyMerge, k::Symbol, default)
    f() = default
    return _get(m, static(k), f)
end

Base.propertynames(m::LazyMerge) = union(propertynames(_getx(m)), propertynames(_gety(m)))

_get(nt::NamedTuple, ::StaticSymbol{k}) where {k} = getproperty(nt, k)

struct NoResult end

@generated function _get(m::LazyMerge{X,Y}, ::StaticSymbol{k}) where {X,Y,k}
    schema_x = schema(X)
    schema_y = schema(Y)

    in_x = k ∈ propertynames(schema_x)
    in_y = k ∈ propertynames(schema_y)

    q = quote
        $(Expr(:meta, :inline))
    end

    if in_x
        if in_y
            # k ∈ x, k ∈ y
            getproperty(schema_x, k) isa NTLike || push!(q.args, :(getproperty(_gety(m), k)))
            getproperty(schema_y, k) isa NTLike || push!(q.args, :(getproperty(_gety(m), k)))
            push!(q.args, :(lazymerge(getproperty(_getx(m), k), getproperty(_gety(m), k))))
        else
            # k ∈ x, k ∉ y
            push!(q.args, :(getproperty(_getx(m), k)))
        end
    else
        if in_y
            # k ∉ x, x ∈ y
            push!(q.args, :(getproperty(_gety(m), k)))
        else
            # k ∉ x, k ∉ y
            return push!(q.args, :(return NoResult()))
        end
    end
    return q
end


import Base.iterate

Base.iterate(lm::LazyMerge) = iterate((k => getproperty(lm, k) for k in propertynames(lm)))
Base.iterate(lm::LazyMerge, s) = iterate((k => getproperty(lm, k) for k in propertynames(lm)), s)

function Base.convert(::Type{NamedTuple}, lm::LazyMerge)
    NamedTuple(k => getproperty(lm, k) for k in propertynames(lm))
end

export mytest
function mytest(n)
    nts = []
    for j in 1:n
        push!(nts, randnt(2,2))
    end
    m = lazymerge(nts...)

    times = []

    for k in propertynames(m)
        push!(times, @elapsed getproperty(m, k))
    end

    times
end

function Base.getindex(lm::LazyMerge{X,Y}, args...) where {X<:AbstractArray, Y<:AbstractArray}
    _getindex(_gety(lm)[args...], lm, args...)
end

_getindex(::Missing, lm, args...) = _getx(lm)[args...]

_getindex(y::AbstractArray, lm, args...) = lazymerge(_getx(lm), y)

_getindex(y, lm, args...) = y

Base.length(lm::LazyMerge) = length(_gety(lm))