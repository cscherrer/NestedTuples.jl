module NestedTuples

using Kaleido

export Nested

struct Nested{T}
    value::T
end

import Base

function Base.show(io::IO, x::Nested)
    print(io, "Nested(", x.value, ")")
end

include("placeholder.jl")
include("typelevel.jl")
include("lenses.jl")

import NamedTupleTools

function Base.empty(x::Nested)
    ℓ = lenses(x)
end

end
