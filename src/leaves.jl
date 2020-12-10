using BangBang
using Accessors

export _leaves

function leaves end

export cattuples

"""
    julia> cattuples((1,2),(3,4))
    (1, 2, 3, 4)
"""
cattuples(a::Tuple,b::Tuple...) = (a..., cattuples(b...)...)
cattuples(a::Tuple) = a

export transposetuple

"""
    julia> transposetuple(((1,2),(3,4),(5,6)))
    ((1, 3, 5), (2, 4, 6))
"""
function transposetuple(t)
    return Tuple((getindex.(t,j) for j in 1:length(t[1])))
end

function leaf_setter(T)
    template = _leaves(leaf -> gensym(), fromtype(T))
    names = Symbol[]
    _leaves(leaf -> push!(names, leaf), template)
    return quote
        $(names...) -> $template 
    end
end

# _leaves(NT::Type{NamedTuple{K,V}}) where {K,V} = _leaves(fromtype(NT))

# _leaves(T::Type{Tup}) where {Tup <: Tuple} = _leaves(fromtype(T))

# _leaves(t::Tuple) = _leaves(t, ())

# _leaves(nt::NamedTuple) = _leaves(nt, ())

function _leaves(f, x::Tuple)
    return _leaves.(f, x)
end

function _leaves(f, x::NamedTuple)
    return NamedTuple{keys(x)}(_leaves(f, values(x)))
end


# When we reach a leaf node (an array), compose the steps to get a lens
function _leaves(f, x)
    return f(x)
end

export leaf_setter

@generated function leaf_setter(x)
    x = fromtype(x)
    names = []

    function f(t::Tuple)
        Expr(:tuple, t...)
    end

    function f(t::NamedTuple)
        kvs = zip(keys(t), values(t))
        Expr(:tuple, [Expr(:(=), k, v) for (k,v) in kvs]...)
    end

    function f(x)
        s = gensym()
        push!(names, s)
        return s
    end

    body = fold(f, x)

    args = Expr(:tuple, names...)

    return quote 
        $args -> $body
    end
end
