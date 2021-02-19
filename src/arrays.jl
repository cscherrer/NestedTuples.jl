export TupleVector
using ElasticArrays, ArraysOfArrays
struct TupleVector{T,X} <: AbstractVector{T}
    data :: X
end

struct EmptyTupleVector{T} end

export unwrap

unwrap(tv::TupleVector) = getfield(tv, :data)
unwrap(x) = x

function TupleVector(a::AbstractVector{T}) where {T}
    a1 = first(a)

    x = TupleVector{T}(undef, a1, length(a))
    x .= a
    return x
end

function TupleVector(::UndefInitializer, x::T, n::Int) where {T<:NamedTuple}

    function initialize(n::Int)
        f(x::T) where {T} = ElasticVector{T}(undef, n)
        f(x::DenseArray{T,N}) where {T,N} = nestedview(ElasticArray{T,N+1}(undef, size(x)..., n), N)
        return f 
    end

    data = rmap(initialize(n), x)

    return TupleVector{T, typeof(data)}(data)
end

# function TupleVector(x::Union{Tuple, NamedTuple})
#     flattened = flatten(x)
#     @assert allequal(size.(flattened)...)

#     T = typeof(modify(arr -> arr[1], x, Leaves()))
#     N = length(axes(flattened[1]))
#     X = typeof(x)
#     return TupleVector{T,X}(x)
# end

# TupleVector{T}(x...) where {T} = leaf_setter(T)(x...)

import Base

Base.propertynames(tv::TupleVector) = propertynames(unwrap(tv))

function Base.showarg(io::IO, tv::TupleVector{T}, toplevel) where T
    io = IOContext(io, :compact => true)
    print(io, "TupleVector")
    toplevel && println(io, " with schema ", schema(T))
end

# function Base.show(io::IO, ::MIME"text/plain", tv::TupleVector)
#     summary(io, tv)
#     print(io, summarize(tv))
# end

function Base.getindex(x::TupleVector, j)
        
    # TODO: Bounds checking doesn't affect performance, am I doing it right?
    function f(arr)
        # @boundscheck all(j .∈ axes(arr))
        return @inbounds arr[j]
    end

    modify(f, unwrap(x), Leaves())
end

# function Base.setindex!(a::TupleVector{T,X}, x::T, j::Int) where {T,X}
#     a1 = flatten(unwrap(a))
#     x1 = flatten(x)
#     setindex!.(a1, x1, j)
# end

function Base.length(tv::TupleVector)
    length(flatten(unwrap(tv))[1])
end

function Base.size(tv::TupleVector)
    size(flatten(unwrap(tv))[1])
end

# TODO: Make this pass @code_warntype
Base.getproperty(tv::TupleVector, k::Symbol) = maybewrap(getproperty(unwrap(tv), k))

maybewrap(t::Tuple) = TupleVector(t)
maybewrap(t::NamedTuple) = TupleVector(t)
maybewrap(t) = t

# flatten(tv::TupleVector) = TupleVector(flatten(unwrap(tv)))

# leaf_setter(tv::TupleVector) = TupleVector ∘ leaf_setter(unwrap(tv))

# function TupleVector{T}(::UndefInitializer) where {T}
#     return EmptyTupleVector{T}()
# end


# function Base.push!(::EmptyTupleVector{T}, nt::NamedTuple) where {T}
#     function f(x::t, path) where {t}
#         ea = ElasticArray{t}(undef, 0)
#         push!(ea, x)
#         return ea
#     end

#     function f(x::DenseArray{t}, path) where {t}
#         ea = ElasticArray{t}(undef, size(x)..., 0)
#         nv = nestedview(ea, 1)
#         push!(nv, x)
#         return nv
#     end

#     data = fold(f, nt)
#     X = typeof(data)
#     TupleVector{T,X}(data)
# end

export tvcore_init

# function tvcore_init(x::Vector)
#     return ElasticVector(x)
# end

# function tvcore_init(x::Vector{A}) where {T, N, A <: DenseArray{T,N}}
#     x1 = first(x)
#     nv = nestedview(ElasticArray{T,N+1}(undef, size(x1)..., length(x)), N)
#     for (xj, nvj) in zip(x,nv)
#         nvj .= xj
#     end
#     return nv
# end

function tvcore_init(exemplar::T, n::Int) where {T}
    ElasticVector{T}(undef, n)
end

function tvcore_init(examplar::DenseArray{T,N}, n::Int) where {T,N}
    nestedview(ElasticArray{T,N+1}(undef, size(examplar)..., n), N)
end
