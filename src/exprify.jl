function exprify(x::NamedTuple; rename=true)
    names = []
    
    function f(t::Tuple, path)
        Expr(:tuple, t...)
    end
    
    function f(t::NamedTuple, path)
        kvs = zip(keys(t), values(t))
        args = []
        for (k,v) in kvs
            push!(args, Expr(:(=), k, v))
        end
        Expr(:tuple, args...)
    end
    

    function f(x, path)
        if rename
            name = gensym()
        else
            name = x
        end
        push!(names, name)
        return name
    end

   
    body = fold(f, x)

    return (names, body)
end
