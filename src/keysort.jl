using Accessors

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


export randnt

function randnt(width, depth)
    k = unique(Symbol.(rand('a':'z', width)))
    if depth ≤ 1
        return namedtuple(k)(k)
    else
        nts = Tuple((randnt(width, depth-1) for _ in 1:length(k)))
        return namedtuple(k)(nts)
    end
end 
