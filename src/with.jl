export @with

using GeneralizedGenerated

struct TypelevelExpr{T}
    expr::Expr
    TypelevelExpr(expr::Expr) = new{to_type(expr)}(expr)
end

@gg function with(nt::NamedTuple{N,T}, ::TypelevelExpr{E}) where {N,T,E}
    ex = from_type(E)
    q = quote end
    for x in N
        xname = QuoteNode(x)
        push!(q.args, :($x = Base.getproperty(nt, $xname)))
    end
    push!(q.args, ex)
    q
end

"""
    @with(ctx, body)

Compute `body` using the context `ctx`. `ctx` is typically a named tuple, but the only requirement is that it supports `Base.getproperty`.

This macro works by creating a type-level representation of `body` and passing this to a "generalized generated" function that dispatches on the types. So, for example, `@with((x=1, y=2), x+y)` will create a local `nt = (x=1, y=2)` and generate

```
x = getproperty(nt, :x)
y = getproperty(nt, :y)
x + y
```
"""
macro with(nt, ex)
    tle = TypelevelExpr(ex)
    quote
        with($(esc(nt)), $tle)
    end 
end
