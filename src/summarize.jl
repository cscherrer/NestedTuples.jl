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

summarize(x::AbstractArray{<:Real}) = RealSummary(mean_and_std(x)...)


function Base.show(io::IO, s::RealSummary)
    io = IOContext(io, :compact => true)
    print(io, s.μ, " ± ", s.σ)
end