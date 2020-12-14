using Accessors

export flatten

flatten(x, y...) = (flatten(x)..., flatten(y...)...)
flatten(x::Tuple) = flatten(x...)
flatten(x::NamedTuple) = flatten(values(x)...)
flatten(x) = (x,)


using GeneralizedGenerated

leaf_setter(::Type{T}) where {T} = leaf_setter(schema(T))

@gg function leaf_setter(x::NamedTuple)
    x = schema(x)
    _leaf_setter(x)
end


@gg function leaf_setter(x::Tuple)
    x = schema(x)
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
    vs = flatten(unwrap(obj))
    args = f.(vs)
    return leaf_setter(obj)(args...)
end
