mapnt(f, x) = f(x)

function mapnt(f, t::Tuple)
    map(x -> mapnt(f,x), t)
end

function mapnt(f, nt::NamedTuple{N,T}) where {N,T}
    NamedTuple{N}(map(x -> mapnt(f,x), values(nt)))
end
