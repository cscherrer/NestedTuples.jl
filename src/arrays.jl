export TupleArray

struct TupleArray{T,N,X} <: AbstractArray{T,N}
    data :: X
end


export unwrap

unwrap(ta::TupleArray) = getfield(ta, :data)
unwrap(x) = x

function TupleArray(x)
    flattened = flatten(x)
    @assert allequal(size.(flattened)...)

    T = typeof(modify(arr -> arr[1], x, Leaves()))
    N = length(axes(flattened[1]))
    X = typeof(x)
    return TupleArray{T,N,X}(x)
end

TupleArray{T}(x...) where {T} = leaf_setter(T)(x...)

import Base

Base.propertynames(ta::TupleArray) = propertynames(getfield(ta, :data))

function Base.showarg(io::IO, ta::TupleArray{T}, toplevel) where T
    io = IOContext(io, :compact => true)
    print(io, "TupleArray")
    toplevel && print(io, " with schema ", schema(T))
end

function Base.getindex(x::TupleArray, j)
        
    # TODO: Bounds checking doesn't affect performance, am I doing it right?
    function f(arr)
        # @boundscheck all(j .∈ axes(arr))
        return @inbounds arr[j]
    end

    modify(f, unwrap(x), Leaves())
end

function Base.setindex!(a::TupleArray{T,N,X}, x::T, j::Int) where {T,N,X}
    a1 = flatten(unwrap(a))
    x1 = flatten(x)
    setindex!.(a1, x1, j)
end

function Base.length(ta::TupleArray)
    length(flatten(unwrap(ta))[1])
end

function Base.reshape(ta::TupleArray, newshape)
    x = unwrap(ta)
    TupleArray(modify(arr -> reshape(arr, newshape), x, Leaves()))
end

function Base.size(ta::TupleArray)
    size(flatten(unwrap(ta))[1])
end

# TODO: Make this pass @code_warntype
Base.getproperty(ta::TupleArray, k::Symbol) = maybewrap(getproperty(unwrap(ta), k))

maybewrap(t::Tuple) = TupleArray(t)
maybewrap(t::NamedTuple) = TupleArray(t)
maybewrap(t) = t

flatten(ta::TupleArray) = TupleArray(flatten(unwrap(ta)))

leaf_setter(ta::TupleArray) = TupleArray ∘ leaf_setter(unwrap(ta))

function TupleArray{T, N}(::UndefInitializer, dims...) where {T,N}
    @assert length(dims) == N

    sT = schema(T)

    f(t::Type, path) = Array{t, N}(undef, dims...)
    f(x, path) = x
    data = fold(f, sT)
    X = typeof(data)
    TupleArray{T,N,X}(data)
end
