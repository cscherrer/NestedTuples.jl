export fold

function fold(f, t::Tuple)
    return f(fold.(f, t))
end

function fold(f, t::NamedTuple)
    inner = fold.(f, values(t))
    return f(NamedTuple{keys(t)}(inner))
end

function fold(f, x)
    return f(x)
end
