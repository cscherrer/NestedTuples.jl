using StatsBase

export summarize

abstract type Summary end

summarize(nt::NamedTuple) = rmap(summarize, nt)

summarize(tv::TupleVector) = summarize(unwrap(tv))


###############################################################################
# FullSummary

struct FullSummary{T} <: Summary
    data :: T
end

summarize(x) = FullSummary(x)

Base.show(io, s::FullSummary) = print(io, s.data)

###############################################################################
# RealSummary

struct RealSummary <: Summary
    μ :: Float64
    σ :: Float64
end

function Base.show(io::IO, s::RealSummary)
    io = IOContext(io, :compact => true)
    σ = round(s.σ, sigdigits=2)
    μdigits = max(2, ceil(Int, log10(2) * (exponent(s.μ) - exponent(σ))) + 2)
    μ = round(s.μ, sigdigits = μdigits)
    print(io, μ, " ± ", σ)
end

summarize(x::AbstractVector{<:Real}) = RealSummary(mean_and_std(x)...)

function summarize(x::ArrayOfSimilarArrays)
    
    [RealSummary(μ,σ) for (μ,σ) in mean_and_std.(x')]
end

export foo
function foo(x)
    s = RealSummary(mean_and_std(x)...)
    σ = round(s.σ, sigdigits=2)
    μ = round(s.μ, sigdigits=exponent(s.μ)-exponent(σ)+2, base=2)
    return(μ,σ)
end
