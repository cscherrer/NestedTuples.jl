using Accessors

export flatten

"""
    flatten(x::Tuple)
    flatten(x::NamedTuple)

`flatten` a nested tuple or named tuple. The result will be a tuple consisting of the
leaves.

EXAMPLE:
```
julia> x = randnt(3,2)
(y = (f = :f, b = :b, t = :t), w = (m = :m, f = :f), s = (m = :m, v = :v, q = :q))

julia> flatten(x)
(:f, :b, :t, :m, :f, :m, :v, :q)
```
"""

flatten(x, y...) = (flatten(x)..., flatten(y...)...)
flatten(x::Tuple) = flatten(x...)
flatten(x::NamedTuple) = flatten(values(x)...)
flatten(x) = (x,)


using GeneralizedGenerated

""" 
    leaf_setter(x::Tuple)
    leaf_setter(x::NamedTuple)
    leaf_setter(::Type)

Return a function for constructing values with the same schema as `x`, given
values for the leaves.

EXAMPLE:
```
julia> x = randnt(2,2)
(b = (b = :b, n = :n), k = (h = :h, t = :t))

julia> f = leaf_setter(x)
function = (##265, ##266, ##267, ##268;) -> begin
    begin
        (b = (b = var"##265", n = var"##266"), k = (h = var"##267", t = var"##268"))
    end
end

julia> @btime (\$f)(1,2,3,4)
  0.010 ns (0 allocations: 0 bytes)
(b = (b = 1, n = 2), k = (h = 3, t = 4))
```
"""
function leaf_setter end

export leaf_setter

leaf_setter(::Type{T}) where {T} = leaf_setter(schema(T))

@gg function leaf_setter(x::NamedTuple)
    x = schema(x)
    _leaf_setter(x)
end


@gg function leaf_setter(x::Tuple)
    x = schema(x)
    _leaf_setter(x)
end

function _leaf_setter(x)
    (names, body) = exprify(x)
    args = Expr(:tuple, names...)

    return :($args -> $body)
end

export Leaves

struct Leaves end

import Accessors

Accessors.OpticStyle(::Leaves) = ModifyBased()

function Accessors.modify(f, obj, ::Leaves) 
    vs = flatten(unwrap(obj))
    args = f.(vs)
    return leaf_setter(obj)(args...)
end
