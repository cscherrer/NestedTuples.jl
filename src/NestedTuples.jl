module NestedTuples

struct Nested{T}
    value::T
end

function show(io::IO, x::Nested)
    print(io, "Nested(", x, ")")
end


include("typelevel.jl")
include("lenses.jl")

end
