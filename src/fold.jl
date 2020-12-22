export fold

function fold(f, t::Tuple, path=(); kwargs...)
    inner = Tuple(fold(f, steppath(path)(k,v)...) for (k,v) in enumerate(t))
    return f(inner, path; kwargs...)
end

function fold(f, t::NamedTuple, path=(); kwargs...)
    inner = Tuple((fold(f, steppath(path)(k,v)...) for (k,v) in pairs(t)))
    return f(NamedTuple{keys(t)}(inner), path; kwargs...)
end

function fold(f, x, path=(); kwargs...)
    return f(x, path; kwargs...)
end

function steppath(path)
    f(k,v) = (v, (path..., k))
end

#######################################


h(x::NamedTuple, path) = println("going up, path = ", path)
h(x::Tuple, path) = println("going up, path =", path)
h(x, path) = println("at leaf ", path)


x = (a=(b=1,c=2),d=(e=(f=1,g=2)))

fold(h, x)

#######################################

q = quote end

function f(x, path)
    k = last(path)
    push!(q.args, :($k = $x))
end

function f(x::NamedTuple, path)
    k = last(path)
    if isempty(path)
        return q
    else
        push!(q.args, :($k = $x))
    end
end


fold(f, x)
