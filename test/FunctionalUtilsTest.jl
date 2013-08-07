using FactCheck
using FunctionalUtils

facts("Basics") do

   context("partial, rpartial") do
        add(x, y) = x + y
        @fact partial(add, 1)(1) => 2
        @fact partial(add, 1, 2, 3)() => :throws

        @fact rpartial(string, "foo")("bar") => "barfoo"
        @fact rpartial(string, "foo", "bar")("baz") => "bazbarfoo"
    end

    context("not, complement") do
        @fact FunctionalUtils.not => exactly(complement)
        @fact FunctionalUtils.not(iseven)(3) => true
        @fact FunctionalUtils.not(iseven)(4) => false
    end

    context("truthiness") do
        @fact 1    => FunctionalUtils.truthy
        @fact 0    => FunctionalUtils.truthy
        @fact true => FunctionalUtils.truthy
        @fact nothing => FunctionalUtils.falsey
        @fact false   => FunctionalUtils.falsey
    end

end

facts("Sequence operations") do

    context("explode, implode") do
        @fact explode("foo") => ['f', 'o', 'o']
        @fact implode(['f', 'o', 'o']) => "foo"
    end

    context("cons, construct") do
        @fact cons => exactly(construct)
        @fact cons(1, [2,3]) => [1, 2, 3]
        @fact cons(1, (2,3)) => [1, 2, 3]
    end

    context("butlast") do
        @fact butlast([1,2,3]) => [1, 2]
    end

    context("take, drop") do
        @fact take(3, "foobar") => "foo"
        @fact take(1, [1,2,3]) => [1]
        @fact take(1, []) => :throws

        @fact drop(3, "foobar") => "bar"
        @fact drop(1, [1,2,3]) => [2,3]
        @fact drop(1, []) => []
    end

    context("takewhile, dropwhile") do
        @fact takewhile(iseven, []) => []
        @fact dropwhile(iseven, []) => []

        @fact takewhile(iseven, [2,2,2,3,2,2,2]) => [2,2,2]
        @fact dropwhile(iseven, [2,2,2,3,2,2,2]) => [3,2,2,2]

        @fact takewhile((c) -> c == 'x', "xxxyyy") => "xxx"
        @fact dropwhile((c) -> c == 'x', "xxxyyy") => "yyy"
    end

    context("partition, partitionall") do
        @fact partition(2, [1,2,3,4]) => Array{Int}[Int[1,2], Int[3,4]]
        @fact partition(2, [1,2,3])   => Array{Int}[Int[1,2]]
        @fact partition(2, [1])       => []
        @fact partition(3, "foobarbaz") => ["foo", "bar", "baz"]

        @fact partitionall(2, [1,2,3]) => Array{Int}[Int[1,2], Int[3]]
        @fact partitionall(2, [1]) => [[1]]
    end

    context("partitionby") do
        @fact partitionby(isodd,[1]) => Array{Int}[Int[1]]
        @fact partitionby(isodd,[1,2]) => Array{Int}[Int[1],Int[2]]
        @fact partitionby(isodd,[1,1,3,2,4,3]) => Array{Int}[Int[1,1,3],Int[2,4],Int[3]]

    end

    context("mapcat") do
        @fact mapcat((x) -> [x], [1,2,3]) => [1,2,3]
    end

    context("interpose") do
        @fact interpose(10, [1,2,3]) => [1,10,2,10,3]
        @fact interpose(10, []) => []
    end

    context("interleave") do
        @fact implode(interleave("foo", "bar", "baz")) => "fbboaaorz"
        @fact interleave([1,3], [2,4]) => [1,2,3,4]
        @fact interleave([1,3], [2]) => [1,2]
    end

    context("repeat, repeatedly") do
        @fact repeat(5, 1)  => [1,1,1,1,1]
        @fact repeat(-1, 0) => []
        @fact repeat(0, 0)  => []

        @fact repeatedly(5, ()->1) => [1,1,1,1,1]
    end

    context("cycle") do
        @fact cycle(5, [1,2,3]) => [1,2,3,1,2]
    end

    context("splitat") do
        @fact splitat(4, "foobar") => ("foo", "bar")
        @fact splitat(1, "foobar") => ("", "foobar")
    end

    context("map(::Function, ::Dict), mapkeys, mapvals") do
        @fact map((k, v) -> (k, v+1), [:x => 1, :y => 2]) => [:x => 2, :y => 3]
        @fact mapkeys(inc, [1 => 1, 2 => 2]) => [2 => 1, 3 => 2]
        @fact mapvals(inc, [1 => 1, 2 => 2]) => [1 => 2, 2 => 3]
    end

end

facts("Combinators") do

    context("constantly, always") do
        @fact constantly => exactly(always)
        @fact always(5)() => 5
        @fact always(always)() => exactly(always)
    end

    context("pipeline") do
        @fact pipeline(1, inc, inc, inc) => 4
        @fact pipeline(1) => 1
    end

    context("comp, *(::Function ::Function)") do
        @fact comp(inc, inc, inc)(1) => 4
        @fact (inc * inc * inc)(1)   => 4
    end

    context("everypred, somepred") do
        @fact everypred(ispos, iseven)(4) => true
        @fact everypred(ispos, iseven)(-4) => false

        @fact somepred(ispos, iseven)(-4) => true
        @fact somepred(ispos, isodd)(-4) => false
    end

    context("splat, unsplat") do
        foo(x, y, z) = x + y + z
        @fact splat(foo)([1, 2, 3]) => 6
        @fact unsplat(splat(foo))(1, 2, 3) => 6
    end

end

facts("Applicative functions") do

    context("update") do
        d = [:x => 1, :y => [:z => 1]]
        @fact update(d, :x, inc) => [:x => 2, :y => [:z => 1]]
        @fact update(d, :x, 2)   => [:x => 2, :y => [:z => 1]]
        @fact update(d, [:y, :z], inc) => [:x => 1, :y => [:z => 2]]
        @fact update(d, [:y, :z], 2)   => [:x => 1, :y => [:z => 2]]
    end

    context("remove") do
        @fact remove(iseven, [1,2,3,4,5,6]) => [1,3,5]
    end

    context("accessor") do
        @fact map(accessor(1), Array{Int}[[1,2], [3,4], [5,6]]) => [1,3,5]
    end

    context("juxt") do
        @fact juxt(iseven, isodd)(2) => [true, false]
    end

    context("iterate, iterateuntil") do
        @fact iterate(5, inc, 0) => [1, 2, 3, 4, 5]
        @fact iterateuntil((x) -> x > 5, inc, 0) => [1, 2, 3, 4, 5]
    end

    context("reductions") do
        @fact reductions(+, 0, [1, 2, 3, 4, 5]) => [0, 1, 3, 6, 10, 15]
        @fact reductions(+, [1, 2, 3, 4, 5]) => [1, 3, 6, 10, 15]
        @fact reductions(+, []) => []
    end

end

facts("Higher order functions") do

    context("best") do
        @fact best(>, [1, 3, 2, 5, 43, 76, 4]) => 76
    end

    context("fnothing") do
         add3 = fnothing((x, y, z) -> x + y + z, 0, 0, 0)
        @fact add3(1, 2, 3) => 6
        @fact add3(1, 2, false) => 3
        @fact add3(false, 2, 3) => 5
        @fact add3(1, false, 3) => 4
        @fact add3(false, false, 3) => 3
    end

    context("lots of curry") do
        @fact curry2((x, y) -> x + y)(1)(1) => 2
        @fact curry3((x, y, z) -> x + y + z)(1)(1)(1) => 3
        @fact curry4((x, y, z, t) -> x + y + z + t)(1)(1)(1)(1) => 4

        @fact curry2(string)("foo")("bar") => "barfoo"
        @fact curry3(string)("foo")("bar")("baz") => "bazbarfoo"
    end

    context("gt, gte, lt, lte, eq") do
        @fact 2 => not(gt(2))
        @fact 2 => gte(2)
        @fact 2 => gt(1)
        @fact 2 => not(lt(2))
        @fact 2 => lte(2)
        @fact 1 => lt(2)
        @fact 2 => not(eq(1))
        @fact 2 => eq(2)
    end

    context("trampoline") do
        even(n) = n == 0 ? true  : @bounce odd(n - 1)
        odd(n)  = n == 0 ? false : @bounce even(n - 1)
        @fact trampoline(even(1000000)) => true
    end

end
