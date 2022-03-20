using NestedTuples
using Test

using NestedTuples: with, TypelevelExpr

@testset "NestedTuples.jl" begin
    x = (a = (a = :a, b = :b), q = (l = :l, u = :u))

    @test NestedTuples.exprify(x; rename=false) == ([:a, :b, :l, :u], :((a = (a = a, b = b), q = (l = l, u = u))))
    
    @test NestedTuples.flatten(x) == (:a, :b, :l, :u)

    @test NestedTuples.keysort(x) == (a = (a = :a, b = :b), q = (l = :l, u = :u))
    
    @test NestedTuples.leaf_setter(x)(1,2,3,4) == (a = (a = 1, b = 2), q = (l = 3, u = 4))

    @test NestedTuples.schema(x) == (a = (a = Symbol, b = Symbol), q = (l = Symbol, u = Symbol))

    @test NestedTuples.@with((x=1, y=2), x+y) == 3

    @test let nt = (x=1, y=(a=2, b=3))
        @with(nt, (x + @with(y, a + b))) == 6
    end

    @test keysort(((b=1,a=2),(d=3,c=4))) == ((a = 2, b = 1), (c = 4, d = 3))

    @test keysort(lazymerge((b=1,a=2),(d=3,c=4))) == lazymerge((a = 2, b = 1), (c = 4, d = 3))

    @test keysort(NamedTuple()) == NamedTuple()

    @test with(@__MODULE__, (x=1,), (y=2,), TypelevelExpr(:(x+y))) == 3

    @test keysort(3) == 3

    @test keysort(convert(NamedTuple, lazymerge((a = 1, b = 2, c = 3), (b = 4, d = 5)))) == keysort((a = 1, c = 3, d = 5, b = 4))
end
