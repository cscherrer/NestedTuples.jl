using BangBang
using Accessors

export lenses

"""
    lenses(t::Tuple)
    lenses(nt::NamedTuple)
    lenses(NT::Type{NamedTuple{K,V}})

Build a Tuple of lenses for a given value or type

Example:
    julia> nt = (a=(b=[1,2],c=(d=[3,4],e=[5,6])),f=[7,8]);

    julia> lenses(nt)
    ((@lens _.a.b), (@lens _.a.c.d), (@lens _.a.c.e), (@lens _.f))

    julia> lenses(typeof(nt))
    ((@lens _.a.b), (@lens _.a.c.d), (@lens _.a.c.e), (@lens _.f))
"""
function lenses end


@generated function lenses(x)
    ℓ = _lenses(x)
    return ℓ
end

_lenses(NT::Type{NamedTuple{K,V}}) where {K,V} = _lenses(fromtype(NT))

_lenses(T::Type{Tup}) where {Tup <: Tuple} = _lenses(fromtype(T))

_lenses(t::Tuple) = _lenses(t, ())

_lenses(nt::NamedTuple) = _lenses(nt, ())

function _lenses(t::Tuple, acc)
    result = ()
    for (k,v) in enumerate(t)
        acc_k = push!!(acc, Accessors.IndexLens((k,)))
        ℓ = _lenses(v, acc_k)
        result = append!!(result, ℓ)
    end
    return result
end

function _lenses(nt::NamedTuple, acc)
    result = ()
    for k in keys(nt)
        nt_k = getproperty(nt, k)
        # Add "breadcrumb" steps to the accumulator as we descend into the tree
        acc_k = push!!(acc, Accessors.PropertyLens{k}())
        ℓ = _lenses(nt_k, acc_k)
        result = append!!(result, ℓ)
    end
    return result
end

# When we reach a leaf node (an array), compose the steps to get a lens
function _lenses(x, acc)
    return (Accessors.compose(acc...),)
end
