"""
    julia> cattuples((1,2),(3,4))
    (1, 2, 3, 4)
"""
# cattuples(a::Tuple,b::Tuple...) = (a..., cattuples(b...)...)
# cattuples(a::Tuple) = a

cattuples(x) = _cattuples(x...)
@inline _cattuples(x, y...) = (_cattuples(x)..., _cattuples(y)...)
@inline _cattuples(x, y) = (_cattuples(x)..., _cattuples(y)...)
@inline _cattuples(x::Tuple) = _cattuples(x...)
@inline _cattuples(x) = (x,)

"""
    julia> transposetuple(((1,2),(3,4),(5,6)))
    ((1, 3, 5), (2, 4, 6))
"""
function transposetuple(t)
    return Tuple((getindex.(t,j) for j in 1:length(t[1])))
end

allequal(a) = true
allequal(a,b) = a==b
allequal(a,b,c...) = (a==b) && allequal(b,c...) 

export randnt

""" 
    randnt(width::Int, depth::Int)

Construct a random nested NamedTuple with `Symbol`s at the leaves, width
`width`, and depth `depth`

EXAMPLE:
```
julia> randnt(3,2)
(a = (y = :y, r = :r, p = :p), v = (f = :f, e = :e, v = :v))
```
"""
function randnt(width, depth)
    k = unique(Symbol.(rand('a':'z', width)))
    if depth ≤ 1
        return namedtuple(k)(k)
    else
        nts = Tuple((randnt(width, depth-1) for _ in 1:length(k)))
        return namedtuple(k)(nts)
    end
end 

export unwrap
unwrap(x) = x
