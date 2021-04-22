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
    @with(ctx..., body)

Compute `body` using the context `ctx`. `ctx` is typically a named tuple, but the only requirement is that it supports `Base.getproperty`.

This macro works by creating a type-level representation of `body` and passing this to a "generalized generated" function that dispatches on the types. There's a default for named tuples:

```
julia> nt = (x=2, y=3)
(x = 2, y = 3)

julia> @with nt begin
       x^2 + y
       end
7
```

This can be extended to other types and a different number of arguments. For example,
```
julia> using NestedTuples: with

julia> NestedTuples.with(nt1, nt2, ex) = with(nt1, ex) + with(nt2, ex)

julia> @with nt nt begin
       x^2 + y
       end
14
```
or 
```
julia> NestedTuples.with(nt1, v::Vector, ex) = with(nt1, ex) .+ v

julia> @with nt [1,2,3] begin
       x^2 + y
       end
3-element Vector{Int64}:
  8
  9
 10
```
"""
macro with(args...)
    ctx = esc.(args[1:end-1])
    ex = args[end]

    tle = TypelevelExpr(ex)
    quote
        with($(ctx...), $tle)
    end 
end
