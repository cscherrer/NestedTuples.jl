using Accessors

"""
    keysort(nt::NamedTuple)

Recursively sort the keys of a NamedTuple.

EXAMPLE:
```
julia> x = randnt(3,2)
(p = (z = :z, e = :e, s = :s), w = (g = :g, o = :o), g = (c = :c, f = :f, k = :k))

julia> keysort(x)
(g = (c = :c, f = :f, k = :k), p = (e = :e, s = :s, z = :z), w = (g = :g, o = :o))
```
"""
function keysort end


_keysort(nt::NamedTuple{(), Tuple{}}) = nt

function _keysort(nt::NamedTuple{K,V}) where {K,V}
    π = sortperm(collect(K))
    k = K[π]
    v = @inbounds (_keysort.(values(nt)))[π]
    return namedtuple(k)(v)
end

_keysort(t::Tuple) = _keysort.(t)
_keysort(x) = x


export keysort

struct Lenses{T}
    ls::T
end

export call
call(f,args...; kwargs...) = f(args...; kwargs...)

(ℓ::Lenses)(nt::NamedTuple) = Base.Fix2(call, nt).(ℓ.ls)

@generated function keysort(nt::NamedTuple{K,V}) where {K,V}
    s = _keysort(schema(nt))
    ℓ = Lenses(lenses(s))
    return :(leaf_setter($s)($ℓ(nt)...))
end

keysort(t::T) where {T<:Tuple} = keysort.(t)
keysort(x) = x

function keysort(lm::LazyMerge)
    x = getfield(lm, :x)
    y = getfield(lm, :y)
    return lazymerge(keysort(x), keysort(y))
end
