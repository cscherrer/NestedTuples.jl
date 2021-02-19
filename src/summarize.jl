using StatsBase

export summarize

abstract type Summary end

summarize(nt::NamedTuple) = rmap(summarize, nt)

summarize(tv::TupleVector) = summarize(unwrap(tv))

import Base


###############################################################################
# FullSummary

struct FullSummary{T} <: Summary
    data :: T
end

summarize(x) = FullSummary(x)

Base.show(io, s::FullSummary) = print(io, s.data)

###############################################################################
# RealSummary
export RealSummary
struct RealSummary <: Summary
    μ :: Float64
    σ :: Float64
end

Base.typeinfo_prefix(io::IO, ::AbstractArray{<:Summary}) = ("", false)

function Base.show(io::IO, s::RealSummary)
    io = IOContext(io, :compact => true)
    σ = round(s.σ, sigdigits=2)
    μdigits = max(2, ceil(Int, log10(2) * (exponent(s.μ) - exponent(σ))) + 2)
    μ = round(s.μ, sigdigits = μdigits)
    print(io, μ, "±", σ)
end

summarize(x::AbstractVector{<:Real}) = RealSummary(mean_and_std(x)...)

function summarize(x::ArrayOfSimilarArrays)
    [RealSummary(μ,σ) for (μ,σ) in mean_and_std.(x')]
end
