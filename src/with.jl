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

macro with(nt, ex)
    tle = NestedTuples.TypelevelExpr(ex)
    quote
        NestedTuples.with($nt, $tle)
    end |> esc
end
