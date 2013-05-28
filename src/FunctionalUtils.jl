module FunctionalUtils

export # Basic functions
       partial,
       rpartial,
       not,
       complement,
       inc,
       dec,
       halve,
       explode,
       implode,
       truthy,
       falsey,
       ispos,
       isneg,
       iszero,

       # Sequence operations
       cons,
       construct,
       rest,
       butlast,
       drop,
       takewhile,
       dropwhile,
       partition,
       partitionall,
       mapcat,
       interpose,
       mapkeys,
       mapvals,
       interleave,
       repeat,
       repeatedly,
       cycle,
       splitat,

       # Combinators
       constantly,
       always,
       pipeline,
       comp,
       everypred,
       somepred,
       splat,
       unsplat,

       # Applicative functions
       update,
       remove,
       accessor,
       first,
       second,
       third,
       juxt,
       iterate,
       iterateuntil,
       reductions,

       # HOFs
       best,
       fnothing,
       curry2,
       curry3,
       curry4,
       gt,
       gte,
       lt,
       lte,
       eq,
       trampoline,
       Continue,
       @bounce

# Basic functions
# ===============

partial(f::Function, args1...) = (args2...) -> f(args1..., args2...)
rpartial(f::Function, args1...) = (args2...) -> f(args2..., reverse(args1)...)

complement = not(f::Function) = (args...) -> !f(args...)

inc(n) = n + 1
dec(n) = n - 1
halve(n) = n / 2

explode(s::String) = [s...]
implode(cs) = apply(string, cs)

truthy(val) = !is(val, nothing) && !is(val, false)
falsey(val) = !truthy(val)

ispos(n)  = n >= 0
isneg(n)  = n < 0
iszero(n) = n == 0

# Sequence operations
# ===================

Base.convert{T}(::Type{Vector{T}}, t::Tuple) = T[e for e in t]
Base.convert(::Type{Vector}, t::Tuple) = [e for e in t]

cons = construct(head, tail) = vcat([head], convert(Vector, tail))

rest(seq) = seq[2:end]
butlast(seq) = seq[1:end-1]

Base.take(n::Int, seq) = seq[1:n]
drop(n::Int, seq) = seq[n+1:end]

function indexwhere(pred, seq)
    idx = 0
    for i=1:length(seq)
        !pred(seq[i]) ? idx = i : return idx
    end
    idx
end
takewhile(pred, seq) = seq[1:indexwhere(not(pred), seq)]
dropwhile(pred, seq) = seq[indexwhere(not(pred), seq)+1:end]

function partition(n, coll; all=false)
    if length(coll) >= n
        front, back = 1, n
        partitioned = typeof(coll[front:back])[]
        while back <= length(coll)
            push!(partitioned, coll[front:back])
            front, back = back+1, back+n
        end
        all && push!(partitioned, coll[front:end])
        partitioned
    else
        all ? [coll] : Any[]
    end
end
partitionall(n, coll) = partition(n, coll, all=true)

mapcat(f, args...) = apply(vcat, map(f, args...))

interpose(inter, seq) = butlast(mapcat((e) -> [e, inter], seq))

Base.map(f, z::Zip) = [f(tup) for tup in z]
function Base.map{K, V}(f, dict::Dict{K, V})
    d = Dict{K, V}()
    for (k, v) in dict
        k, v = f(k, v)
        d[k] = v
    end
    d
end

mapkeys(f, d::Dict) = map((k, v) -> (f(k), v), d)
mapvals(f, d::Dict) = map((k, v) -> (k, f(v)), d)

interleave(seqs...) = mapcat(partial(convert, Vector), zip(seqs...))

repeat(n, val) = [val for _ in 1:n]
repeatedly(n, f) = [f() for _ in 1:n]

cycle(n, elements) = take(n, mapcat(_ -> elements, 1:int(n/length(elements))))

splitat(i, seq) = (seq[1:i-1], seq[i:end])

# TODO:
# increasing
# decreasing
# increasingoreq
# decreasingoreq
# dispatcher
# takeskipping

# Combinators
# ===========

always = constantly(val) = (_...) -> val

pipeline(seed, fs...) = reduce((val, f) -> f(val), seed, fs)

function comp(fs::Function...)
    f = fs[end]
    fs = reverse(butlast(fs))

    function (args...)
        chain = cons(f(args...), fs)
        pipeline(chain...)
    end
end

import Base.*
*(f1::Function, f2::Function) = (args...) -> f1(f2(args...))

everypred() = (_...) -> true
everypred(pred::Function, preds...) =
    (args...) -> pred(args...) && everypred(preds...)(args...)

somepred() = (_...) -> false
somepred(pred::Function, preds...) =
    (args...) -> pred(args...) || somepred(preds...)(args...)

splat(f::Function) = (args) -> f(args...)
unsplat(f::Function) = (args...) -> f(args)

# Applicative functions
# =====================

function update{K, V}(d::Dict{K, V}, ks::Vector{K}, f::Function)
    lastkey = ks[end]
    ks = butlast(ks)
    ret = copy(d)
    target = ret

    for k in ks
        target = target[k]
    end

    target[lastkey] = f(target[lastkey])
    ret
end
update{K, V}(d::Dict{K, V}, ks::Vector{K}, val) = update(d, ks, always(val))
update{K, V}(d::Dict{K, V}, k::K, f) = update(d, [k], f)

remove(pred, seq) = filter(not(pred), seq)

accessor(key) = (coll) -> coll[key]
first = accessor(1)
second = accessor(2)
third = accessor(3)

juxt(fs::Function...) = (args...) -> [f(args...) for f in fs]

function iterate(n, f, seed)
    ret = Any[]
    result = f(seed)

    for _=1:n
        push!(ret, result)
        result = f(result)
    end

    ret
end
function iterateuntil(pred, f, seed)
    ret = Any[]
    result = f(seed)

    while !pred(result)
        push!(ret, result)
        result = f(result)
    end

    ret
end

function reductions(f, init, seq)
    ret = Any[init]
    acc = init

    for el in seq
        acc = f(acc, el)
        push!(ret, acc)
    end

    ret
end
reductions(f, seq) = isempty(seq) ? Any[] : reductions(f, seq[1], seq[2:end])

# TODO:
# partitionby

# Higher order functions
# ======================

best(f, seq) = reduce(seq) do x, y
    f(x, y) ? x : y
end

function fnothing(f, defaults...)
    function (args...)
        args = map(zip(args, defaults)) do tup
            arg, default = tup
            truthy(arg) ? arg : default
        end
        f(args...)
    end
end

curry2(f) = last -> (first -> f(first, last))
curry3(f) = last -> (middle -> (first -> f(first, middle, last)))
curry4(f) = fourth -> (third -> (second -> (first -> f(first, second, third, fourth))))

gt  = curry2(>)
gte = curry2(>=)
lt  = curry2(<)
lte = curry2(<=)
eq  = curry2(==)

immutable Continue
    thunk
end
macro bounce(ex)
    :(Continue(() -> $(esc(ex))))
end
function trampoline(c::Continue)
    while isa(c, Continue)
        c = c.thunk()
    end
    c
end
trampoline(f::Function, args...) = trampoline(f(args...))
trampoline(val) = val

end # module FunctionalUtils
