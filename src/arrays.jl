export TupleArray

struct TupleArray{T,N,X} 
    data :: X
end

export unwrap

unwrap(ta::TupleArray) = getfield(ta, :data)
unwrap(x) = x

function TupleArray(x)
    T = typeof(modify(arr -> arr[1], x, Leaves()))
    N = length(axes(flatten(x)[1]))
    X = typeof(x)
    return TupleArray{T,N,X}(x)
end

import Base

function Base.size(n::TupleArray)
    return size(flatten(n.data)[1])
end

# function Base.show(io, n::TupleArray)
#     print(io, "TupleArray("

#     print(io, ")"


function Base.getindex(x::TupleArray, j)
        
    # TODO: Bounds checking doesn't affect performance, am I doing it right?
    Base.@propagate_inbounds function f(arr)
        @boundscheck all(j .∈ axes(arr))
        return @inbounds arr[j]
    end

    modify(f, x, Leaves())
end



Base.getproperty(ta::TupleArray, k::Symbol) = maybewrap(getproperty(unwrap(ta), k))

maybewrap(t::Tuple) = TupleArray(t)
maybewrap(t::NamedTuple) = TupleArray(t)
maybewrap(t) = t


export getX
getX(ta::TupleArray{T,N,X}) = X

flatten(ta::TupleArray) = TupleArray(flatten(unwrap(ta)))
