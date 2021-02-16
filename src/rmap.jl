export rmap

rmap(f, x) = f(x)

function rmap(f, t::Tuple)
    map(x -> rmap(f,x), t)
end

function rmap(f, nt::NamedTuple{N,T}) where {N,T}
    NamedTuple{N}(map(x -> rmap(f,x), values(nt)))
end
