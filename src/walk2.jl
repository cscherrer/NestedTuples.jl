# This file is an attempt to walk two named tuples simultaneously. It's very
# rough, maybe not even usable in its current state. It's not yet clear whether
# this approach will have any advantages over others like `LazyMerge`.


function merge(x::Nested, y::Nested)
    _merge_ordered(x,y)
end

function _merge_ordered(x::NamedTuple{Kx,Vx}, y::NamedTuple{Ky,Vy}) where {Kx,Vx,Ky,Vy}

end

function walk2(f, xs::Tx, ys::Tx) where {Tx<:Tuple, Ty<:Tuple}
    (new_x, new_xs) = untuple(xs)
    (new_y, new_ys) = untuple(ys)
    return walk2(f, new_x, new_y, new_xs, new_ys, ()) 
end

function walk2(f, x::Nothing, y, xs::Tuple{}, ys, acc)
    new_acc = f(y, acc)
    return foldl(f, ys; init=new_acc)
end

function walk2(f, x, y::Nothing, xs, ys::Tuple{}, acc)
    new_acc = f(x, acc)
    return foldl(f, xs; init=new_acc)``
end

function walk2(f, x::Nothing, y::Nothing, xs::Tuple{}, ys::Tuple{}, acc)
    return acc
end


function walk2(f, x, y, xs, ys, acc)
    new_x = x
    new_xs = xs
    new_y = y
    new_ys = ys
    
    if x==y
        new_acc = f(x, acc)
        (new_x, new_xs) = untuple(xs)
        (new_y, new_ys) = untuple(ys)
    elseif x < y
        new_acc = f(x, acc)
        (new_x, new_xs) = untuple(xs)
    else
        new_acc = f(y, acc)
        (new_y, new_ys) = untuple(ys)
    end
    
    return walk2(f, new_x, new_y, new_xs, new_ys, new_acc)  
end

function untuple(x::Tuple{})
    return (nothing, ())
end

function untuple(x::NTuple{N,T}) where {N,T}
    f(h,t...) = (h,t)
    return f(x...)
end

using BangBang

@inline function slice_namedtuple(nt::NamedTuple{K,V}, r::UnitRange) where {K,V}
    @boundscheck begin
        n = length(K)
        if r.start < 1
            throw(BoundsError(nt, 0))
        elseif r.stop > n
            throw(BoundsError(nt, n+1))
        end
    end

    ks = @inbounds keys(nt)[r]
    vs = @inbounds values(nt)[r]
    return namedtuple(ks)(vs)
end

@generated function keymerge(x::NamedTuple{Nx}, y::NamedTuple{Ny}) where {Nx, Ny}
    Tuple(sort(union(Nx, Ny)))
end

@inline function mergent(xs, ys)
    m = length(xs)
    n = length(ys)

    xkeys = keys(xs)
    xvals = values(xs)

    ykeys = keys(ys)
    yvals = values(ys)

    i = 1
    j = 1

    ks = keymerge(xs, ys)

    vs = ()
    while true
        # We're done with xs
        if i > m 
            vs = append!!(vs, @inbounds yvals[j:n])
            break
        end

        # We're done with ys
        if j > n
            vs = append!!(vs, @inbounds xvals[i:m])
            break
        end

        xkey = @inbounds xkeys[i]
        ykey = @inbounds ykeys[j]

        

        if xkey == ykey
            xval = @inbounds xvals[i]
            yval = @inbounds yvals[j]

            vs = push!!(vs, mergent(xval, yval))

            i += 1
            j += 1
        elseif xkey < ykey
            xval = @inbounds xvals[i]
            vs = push!!(vs, xval)
            i += 1
        else
            yval = @inbounds yvals[i]
            vs = push!!(vs, yval)
            j += 1
        end
    end

    return namedtuple(ks)(vs)
end















    function getprop(nt, k)
        Expr(:., nt, QuoteNode(k))
    end

    function f(acc, i, k) 
        (ks, vs) = acc
        ksym = QuoteNode(k)

        return (push!!(ks, k), push!!(vs, :(getproperty(x, $ksym))))
    end

    function f(acc, i, j, k) 
        (ks, vs) = acc
        ksym = QuoteNode(k)
        xk = getprop(:x, k)
        yk = getprop(:y, k)
        q = :(merge_ordered($xk, getproperty(y, $ksym)))
        return (push!!(ks, ksym), push!!(vs, q))
    end

    (ks, vs) = walk2(f, keys(xs), keys(ys), init = ([], []))
    
    quote
        ks = $(Expr(:tuple, ks...))
        vs = $(Expr(:tuple, vs...))
        namedtuple(ks)(vs)
    end
end





x = (a=1, c=(d=1,))
y = (b=2, c=(e=2,))


merge_ordered(x,y)

_a = 1
_b = 2
_c = merge((d=1,), (e=2,))

return (a=_a, b=_b, c=_c)
