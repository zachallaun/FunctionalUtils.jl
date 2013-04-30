## Functional Julia

Useful functions for functional programming in Julia. Based heavily on
[fogus/lemonad](https://github.com/fogus/lemonad). I make no claims that
all of these are Good Ideas. Some (or many) may be removed.

See the
[tests](https://github.com/zachallaun/FunctionalUtils.jl/blob/master/test/FunctionalUtilsTest.jl)
for examples.

Current exports:

```.jl
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
       @jump
```
