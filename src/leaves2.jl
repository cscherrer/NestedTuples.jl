

using GeneralizedGenerated
using NamedTupleTools: merge_recursive

leaf_setter(::Type{Tx}, ::Type{Ty}) where {Tx, Ty} = leaf_setter(schema(Tx), schema(Ty))

@gg function leaf_setter(x::NamedTuple, y::NamedTuple)
    x = schema(x)
    y = schema(y)
    _leaf_setter(x, y)
end

@gg function leaf_setter(x::Tuple, y::Tuple)
    x = schema(x)
    y = schema(y)
    _leaf_setter(x,y)
end

function _leaf_setter(x, y)
    (xnames, xbody) = exprify(x)
    (ynames, ybody) = exprify(y)

    xargs = Expr(:tuple, xnames...)
    yargs = Expr(:tuple, ynames...)

    (_, body) = exprify(merge_recursive(
        leaf_setter(x)(xnames...),
        leaf_setter(y)(ynames...)); rename=false)

    q =  quote
        (x,y) -> begin
            $xargs = x
            $yargs = y
            return $body
        end
    end

    return q
end
