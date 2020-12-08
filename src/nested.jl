export Nested

struct Nested{T}
    value::T
end

Nested(;kwargs...) = Nested((;kwargs...))

import Base

function Base.show(io::IO, x::Nested)
    print(io, "Nested(", x.value, ")")
end


import NamedTupleTools

function Base.empty(x::Nested)
    ℓ = lenses(x)
    n = length(ℓ)
    set(x, batch(ℓ...), ntuple(i -> □, n))
end

Base.get(x::Nested, ℓ::Lens) = Nested(get(x.value, ℓ))

Setfield.set(x::Nested, ℓ::Lens, v) = Nested(set(x.value, ℓ, v))

Setfield.set(x::Nested, ℓ::Setfield.ComposedLens, v) = Nested(set(x.value, ℓ, v))
