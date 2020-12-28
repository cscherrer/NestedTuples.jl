export Nested

struct Nested{T}
    value::T
end

# function Nested(nt)
#     x = keysort(nt)
#     T = typeof(x)
#     Nested{T}(x)
# end

Nested(;kwargs...) = Nested((;kwargs...))

import Base

function Base.show(io::IO, x::Nested)
    print(io, "Nested(", x.value, ")")
end


lenses(x::Nested) = lenses(x.value)

function schema(N::Type{Nested{X}}) where {X}
    return Nested(schema(X))
end

@generated function Base.empty(x::Nested)
    e = _empty(schema(x))
    return e
end

function _empty(x::Nested)
    ℓ = lenses(x)
    n = length(ℓ)
    set(x, batch(ℓ...), ntuple(i -> □, n))
end
