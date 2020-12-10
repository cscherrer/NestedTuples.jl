using Accessors

export leaves


leaves(x::Tuple) = cattuples(map(leaves, x))
leaves(x::NamedTuple) = cattuples(map(leaves, values(x)))
leaves(x) = (x,)

# leaves(x, y...) = (leaves(x)..., leaves(y)...)
# leaves(x::Tuple) = leaves(x...)
# leaves(x::NamedTuple) = leaves(values(x)...)
# leaves(x) = (x,)

using GeneralizedGenerated

@gg function leaf_setter(x)
    x = fromtype(x)
    _leaf_setter(x)
end

function _leaf_setter(x)
    names = []

    function f(t::Tuple)
        Expr(:tuple, t...)
    end

    function f(t::NamedTuple)
        kvs = zip(keys(t), values(t))
        args = []
        for (k,v) in kvs
            push!(args, Expr(:(=), k, v))
        end
        Expr(:tuple, args...)
    end

    function f(x)
        s = gensym()
        push!(names, s)
        return s
    end

    body = fold(f, x)

    args = Expr(:tuple, names...)

    return :($args -> $body)
end

export Leaves

struct Leaves end

import Accessors

Accessors.OpticStyle(::Leaves) = ModifyBased()

function Accessors.modify(f, obj, ::Leaves) 
    # vs = Flatten.flatten(obj, Array)
    vs = leaves(obj)
    args = f.(vs)
    return leaf_setter(obj)(args...)
end

export ind

function ind(x, j)
    f(arr) = @inbounds arr[j]
    modify(f, x, Leaves())
end
