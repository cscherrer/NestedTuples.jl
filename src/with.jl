export @with

using GeneralizedGenerated

struct TypelevelExpr{T}
    expr::Expr
    TypelevelExpr(expr::Expr) = new{to_type(expr)}(expr)
end

with(nt::NamedTuple, ex) = with(@__MODULE__, nt, ex)

with(nt1::NamedTuple, nt2::NamedTuple, ex) = with(@__MODULE__, nt1, nt2, ex)

with(m::Module, nt::NamedTuple, ex::Expr) = with(m, nt, TypelevelExpr(ex))

function with(m::Module, nt1::NamedTuple, nt2::NamedTuple, ex::Expr)
    with(m, nt1, nt2, TypelevelExpr(ex))
end

@gg function with(m::Module, nt::NamedTuple{N,T}, ::TypelevelExpr{E}) where {N,T,E}
    ex = from_type(E)
    q = quote end
    for x in N
        xname = QuoteNode(x)
        push!(q.args, :($x = Base.getproperty(nt, $xname)))
    end
    push!(q.args, ex)
    @under_global :m q
end


@gg function with(
    m::Module,
    nt1::NamedTuple{N1,T1},
    nt2::NamedTuple{N2,T2},
    ::TypelevelExpr{E},
) where {N1,N2,T1,T2,E}
    s1 = schema(NamedTuple{N1,T1})
    s2 = schema(NamedTuple{N2,T2})
    ex = from_type(E)
    q = quote end
    for x in N1
        xname = QuoteNode(x)
        T = getproperty(s1, x)
        push!(q.args, :($x = Base.getproperty(nt1, $xname)::$T))
    end
    for x in N2
        xname = QuoteNode(x)
        T = getproperty(s2, x)
        push!(q.args, :($x = Base.getproperty(nt2, $xname)::$T))
    end
    push!(q.args, ex)
    @under_global :m q
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
