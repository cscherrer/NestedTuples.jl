export fold

pre_default(t, path=(); kwargs...) = t

function fold(f, x::Tuple, pre=pre_default, path=(); kwargs...)
    new_x = pre(x, path; kwargs...)
    inner = Tuple(fold(f, steppath(pre, path)(k,v)...; kwargs...) for (k,v) in enumerate(new_x))
    return f(inner, path; kwargs...)
end

function fold(f, x::NamedTuple, pre=pre_default, path=(); kwargs...)
    new_x = pre(x, path; kwargs...)
    inner = Tuple((fold(f, steppath(pre, path)(k,v)...; kwargs...) for (k,v) in pairs(new_x)))
    return f(NamedTuple{keys(new_x)}(inner), path; kwargs...)
end

function fold(f, x, pre=pre_default, path=(); kwargs...)
    new_x = pre(x, path; kwargs...)
    return f(new_x, path; kwargs...)
end

function steppath(pre, path)
    f(k,v) = (v, pre, (path..., k))
end

#######################################




# function example_fold(x) 
#     pathsize = 10
#     function pre(x, path)
#         print("↓ path = ")
#         print(rpad(path, pathsize))
#         println("value = ", x)
#         return x
#     end 

#     function f(x::Union{Tuple, NamedTuple}, path)
#         print("↑ path = ")
#         print(rpad(path, pathsize))
#         println("value = ", x)
#         return x
#     end 

#     function f(x, path)
#         print("↑ path = ")
#         print(rpad(path, pathsize))
#         print("value = ", x)
#         println(" ←-- LEAF")
#         return x
#     end 

#     fold(f, x, pre)
# end


#######################################

# q = quote end

# function f(x, path)
#     k = last(path)
#     push!(q.args, :($k = $x))
# end

# function f(x::NamedTuple, path)
#     k = last(path)
#     if isempty(path)
#         return q
#     else
#         push!(q.args, :($k = $x))
#     end
# end


# fold(pre, post, x)

# function flat(x::NamedTuple)
#     f(x::NamedTuple, path)
