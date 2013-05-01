using FactCheck
using FunctionalUtils

@facts "Basics" begin

    @fact "partial, rpartial" begin
        add(x, y) = x + y
        partial(add, 1)(1) => 2
        partial(add, 1, 2, 3)() => :throws

        rpartial(string, "foo")("bar") => "barfoo"
        rpartial(string, "foo", "bar")("baz") => "bazbarfoo"
    end

    @fact "not, complement" begin
        FunctionalUtils.not => exactly(complement)
        FunctionalUtils.not(iseven)(3) => true
        FunctionalUtils.not(iseven)(4) => false
    end

    @fact "truthiness" begin
        1    => FunctionalUtils.truthy
        0    => FunctionalUtils.truthy
        true => FunctionalUtils.truthy
        nothing => FunctionalUtils.falsey
        false   => FunctionalUtils.falsey
    end

end

@facts "Sequence operations" begin

    @fact "explode, implode" begin
        explode("foo") => ['f', 'o', 'o']
        implode(['f', 'o', 'o']) => "foo"
    end

    @fact "cons, construct" begin
        cons => exactly(construct)
        cons(1, [2,3]) => [1, 2, 3]
        cons(1, (2,3)) => [1, 2, 3]
    end

    @fact "butlast" begin
        butlast([1,2,3]) => [1, 2]
    end

    @fact "take, drop" begin
        take(3, "foobar") => "foo"
        take(1, [1,2,3]) => [1]
        take(1, []) => :throws

        drop(3, "foobar") => "bar"
        drop(1, [1,2,3]) => [2,3]
        drop(1, []) => []
    end

    @fact "takewhile, dropwhile" begin
        takewhile(iseven, []) => []
        dropwhile(iseven, []) => []

        takewhile(iseven, [2,2,2,3,2,2,2]) => [2,2,2]
        dropwhile(iseven, [2,2,2,3,2,2,2]) => [3,2,2,2]

        takewhile((c) -> c == 'x', "xxxyyy") => "xxx"
        dropwhile((c) -> c == 'x', "xxxyyy") => "yyy"
    end

    @fact "partition, partitionall" begin
        partition(2, [1,2,3,4]) => Array{Int}[Int[1,2], Int[3,4]]
        partition(2, [1,2,3])   => Array{Int}[Int[1,2]]
        partition(2, [1])       => []
        partition(3, "foobarbaz") => ["foo", "bar", "baz"]

        partitionall(2, [1,2,3]) => Array{Int}[Int[1,2], Int[3]]
        partitionall(2, [1]) => [[1]]
    end

    @fact "mapcat" begin
        mapcat((x) -> [x], [1,2,3]) => [1,2,3]
    end

    @fact "interpose" begin
        interpose(10, [1,2,3]) => [1,10,2,10,3]
        interpose(10, []) => []
    end

    @fact "interleave" begin
        implode(interleave("foo", "bar", "baz")) => "fbboaaorz"
        interleave([1,3], [2,4]) => [1,2,3,4]
        interleave([1,3], [2]) => [1,2]
    end

    @fact "repeat, repeatedly" begin
        repeat(5, 1)  => [1,1,1,1,1]
        repeat(-1, 0) => []
        repeat(0, 0)  => []

        repeatedly(5, ()->1) => [1,1,1,1,1]
    end

    @fact "cycle" begin
        cycle(5, [1,2,3]) => [1,2,3,1,2]
    end

    @fact "splitat" begin
        splitat(4, "foobar") => ("foo", "bar")
        splitat(1, "foobar") => ("", "foobar")
    end

    @fact "map(::Function, ::Dict), mapkeys, mapvals" begin
        map((k, v) -> (k, v+1), [:x => 1, :y => 2]) => [:x => 2, :y => 3]
        mapkeys(inc, [1 => 1, 2 => 2]) => [2 => 1, 3 => 2]
        mapvals(inc, [1 => 1, 2 => 2]) => [1 => 2, 2 => 3]
    end

end

@facts "Combinators" begin

    @fact "constantly, always" begin
        constantly => exactly(always)
        always(5)() => 5
        always(always)() => exactly(always)
    end

    @fact "pipeline" begin
        pipeline(1, inc, inc, inc) => 4
        pipeline(1) => 1
    end

    @fact "comp, *(::Function ::Function)" begin
        comp(inc, inc, inc)(1) => 4
        (inc * inc * inc)(1)   => 4
    end

    @fact "everypred, somepred" begin
        everypred(ispos, iseven)(4) => true
        everypred(ispos, iseven)(-4) => false

        somepred(ispos, iseven)(-4) => true
        somepred(ispos, isodd)(-4) => false
    end

    @fact "splat, unsplat" begin
        foo(x, y, z) = x + y + z
        splat(foo)([1, 2, 3]) => 6
        unsplat(splat(foo))(1, 2, 3) => 6
    end

end

@facts "Applicative functions" begin

    @fact "update" begin
        d = [:x => 1, :y => [:z => 1]]
        update(d, :x, inc) => [:x => 2, :y => [:z => 1]]
        update(d, :x, 2)   => [:x => 2, :y => [:z => 1]]
        update(d, [:y, :z], inc) => [:x => 1, :y => [:z => 2]]
        update(d, [:y, :z], 2)   => [:x => 1, :y => [:z => 2]]
    end

    @fact "remove" begin
        remove(iseven, [1,2,3,4,5,6]) => [1,3,5]
    end

    @fact "accessor" begin
        map(accessor(1), Array{Int}[[1,2], [3,4], [5,6]]) => [1,3,5]
    end

    @fact "juxt" begin
        juxt(iseven, isodd)(2) => [true, false]
    end

    @fact "iterate, iterateuntil" begin
        iterate(5, inc, 0) => [1, 2, 3, 4, 5]
        iterateuntil((x) -> x > 5, inc, 0) => [1, 2, 3, 4, 5]
    end

    @fact "reductions" begin
        reductions(+, 0, [1, 2, 3, 4, 5]) => [0, 1, 3, 6, 10, 15]
        reductions(+, [1, 2, 3, 4, 5]) => [1, 3, 6, 10, 15]
        reductions(+, []) => []
    end

end

@facts "Higher order functions" begin

    @fact "best" begin
        best(>, [1, 3, 2, 5, 43, 76, 4]) => 76
    end

    @fact "fnothing" begin
        add3 = fnothing((x, y, z) -> x + y + z, 0, 0, 0)
        add3(1, 2, 3) => 6
        add3(1, 2, false) => 3
        add3(false, 2, 3) => 5
        add3(1, false, 3) => 4
        add3(false, false, 3) => 3
    end

    @fact "lots of curry" begin
        curry2((x, y) -> x + y)(1)(1) => 2
        curry3((x, y, z) -> x + y + z)(1)(1)(1) => 3
        curry4((x, y, z, t) -> x + y + z + t)(1)(1)(1)(1) => 4

        curry2(string)("foo")("bar") => "barfoo"
        curry3(string)("foo")("bar")("baz") => "bazbarfoo"
    end

    @fact "gt, gte, lt, lte, eq" begin
        2 => not(gt(2))
        2 => gte(2)
        2 => gt(1)
        2 => not(lt(2))
        2 => lte(2)
        1 => lt(2)
        2 => not(eq(1))
        2 => eq(2)
    end

    @fact "trampoline" begin
        even(n) = n == 0 ? true  : @bounce odd(n - 1)
        odd(n)  = n == 0 ? false : @bounce even(n - 1)

        trampoline(even(1000000)) => true
    end

end
