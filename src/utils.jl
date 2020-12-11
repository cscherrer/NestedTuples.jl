
export cattuples

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

export transposetuple

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
