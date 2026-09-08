---
layout: post
slug: likely_in_cpp
title: `[[likely]]` in C++
tags: c++ cpu
---

<summary>
[Attribute `[[likely]]`][likely] is a good minimal example
of how software can exploit processor features for maximum performance
by providing more information to the compiler.
This post presents an example how `[[likely]]` affects
the compiled machine code and the execution performance.
And it brings up some practical implications.
</summary>

The `[[likely]]` or `[[unlikely]]` attribute tells the compiler
which outcome of conditional branching is expected.
In result, the compiler generates machine code that maximises not taken branches
and streamlines the instruction sequences,
according to the provided expectation.

Let's see it in [Godbolt][godbolt_shortlink]:

<iframe width="800px" height="200px" src="https://godbolt.org/e#g:!((g:!((g:!((h:codeEditor,i:(filename:'1',fontScale:18,fontUsePx:'0',j:1,lang:c%2B%2B,selection:(endColumn:5,endLineNumber:9,positionColumn:5,positionLineNumber:9,selectionStartColumn:5,selectionStartLineNumber:9,startColumn:5,startLineNumber:9),source:'int+big_procedure(void)+%7B%0A++++return+11%3B%0A%7D%0A%0Aint+main(int+argc,+char**+argv)+%7B%0A++++int+res+%3D+5%3B%0A%0A++++if+(argc+%3D%3D+3)%0A++++%5B%5Bunlikely%5D%5D%0A++++//%5B%5Blikely%5D%5D%0A++++%7B%0A++++++++res+%3D+big_procedure()%3B%0A++++%7D%0A%0A++++return+res%3B%0A%7D'),l:'5',n:'0',o:'C%2B%2B+source+%231',t:'0')),k:47.39123797109431,l:'4',n:'0',o:'',s:0,t:'0'),(g:!((h:compiler,i:(compiler:clang2010,filters:(b:'0',binary:'1',binaryObject:'1',commentOnly:'0',debugCalls:'1',demangle:'0',directives:'0',execute:'1',intel:'0',libraryCode:'1',trim:'0',verboseDemangling:'0'),flagsViewOpen:'1',fontScale:14,fontUsePx:'0',j:1,lang:c%2B%2B,libs:!((name:benchmark,ver:trunk)),options:'-Wall+-O3',overrides:!(),selection:(endColumn:1,endLineNumber:1,positionColumn:1,positionLineNumber:1,selectionStartColumn:1,selectionStartLineNumber:1,startColumn:1,startLineNumber:1),source:1),l:'5',n:'0',o:'+x86-64+clang+20.1.0+(Editor+%231)',t:'0')),k:52.60876202890571,l:'4',n:'0',o:'',s:0,t:'0')),l:'2',m:99.99999999999997,n:'0',o:'',t:'0')),version:4"></iframe>

The C++ source:
```cpp
int big_procedure(void) {
    return 11;
}

int main(int argc, char** argv) {
    int res = 5;

    if (argc == 3)
    [[unlikely]]
    //[[likely]]
    {
        res = big_procedure();
    }

    return res;
}
```

The assembly with `-O3` optimizations:
```ASM
big_procedure():
  mov eax, 11
  ret

main:
  mov eax, 5  ; with unlikely
 ;mov eax, 11 ; with likely
  cmp edi, 3
  je .LBB1_1  ; with unlikely
 ;jne .LBB1_1 ; with likely
  ret
.LBB1_1:
  mov eax, 11 ; with unlikely
 ;mov eax, 5  ; with likely
  ret
```

The compiler puts the _likely_ control path into a single uninterupted sequence of instructions,
assuming that the branching instructions are not taken.
It makes the decision whether a branch outcome is expected based on the provided `[[likely]]` attribute.

The point is that _not taken_ conditional branches are practically free,
they require almost no resources from the CPU.
So, if the `je .LBB1_1` branch is not taken,
the code in the example runs as if there is no conditional branch instruction whatsoever.
The compiler optimizes the code towards this ideal case.

// Not sure if this is needed:

Without the `-O3` optimization, the code mixes the branch body with the `main` flow.
The control flow winds through either the branch code or the jump  etc.

Without the `-O3` optimization, the code mixes the branch body with the main flow.
There is only one `ret` from the `main` function.
And the control flow winds through the `main` body,
either going via the branch code or by jumping over it to the label at `ret`:
```
...
  cmp dword ptr [rbp - 8], 3
  jne .LBB1_2
  call big_procedure()
  mov dword ptr [rbp - 20], eax
.LBB1_2:
  mov eax, dword ptr [rbp - 20]
  add rsp, 32
  pop rbp
  ret
```

Even in the expected case, the CPU has to maintain the knowledge
that the path to `call big_procedure()` won't be taken,
and it also has to perform the jump to other label.

# Branch predictors and corresponding CPU resources

// Get to the point on the branch predictors
// intro what they do
// main thing is the CPU resources involved
//
// Then what it means for CPU performance:
// how branch predictor works, the branch target table, etc.

Modern CPUs contain sophisticated branch predictor units.
The branch predictors speculatively assume
whether a given branch instruction might be taken (the control flow might jump to another address in the program)
and
they direct the CPU frontend to load code from the corresponding address
without waiting for the condition to be resolve.
A condition can take a while to be resolved,
because it often involves reading some variable from the memory or something even slower.
The speculative execution of branches allows the CPU to run without interruptions.
That is if the branches are predicted correctly.

There are generally two groups of CPU resources that are involved in the speculative execution of branches:
* If the branch is mispredicted, the CPU has to roll back its execution.
Which damages the performance as badly as it sounds.
* If the branches are correctly predicted, but they are taken,
then the branching instructions occupy entries in the Branch Target Buffer, BTB.
BTB is a map from the addresses of branch instructions to the addresses
of their expected jump targets.
BTBs are pretty large and can track multiple patterns of branching in the control flow.
But, of course, BTB is limited in size. It is a finite resource,
which should not be wasted unnecessarily.

When a branch instruction is not taken, it does not occupy space in BTB.
And when the branch predictor sees a branch instruction with no entry in BTB,
it assumes that the branch is not going to be taken.
Hence, if the not-taken assumption is correct, it is the ideal case:
the CPU executes the right code, and the branch does not occupy any space in BTB.
The `[[likely]]` attribute guides the CPU towards this ideal case.

# Effect on performance

Keep adding not-taken jumps until there is a visible performance penalty,
compare taken and untaken branches, show that the speed is the sasme,
but the branch table size is limited.

And let's measure the performance to showcase the untaken branches?

Do not implement just just refer to a Chips & Cheese article on some CPU with testing the depth of branch predictors.

# Related topics

There are more ways to inform the CPU about the expected control flow pattern:
* [Profile-guided optimisation](https://en.wikipedia.org/wiki/Profile-guided_optimization).
* [C++23 also has `std::expected`](https://en.cppreference.com/cpp/utility/expected)
algebraic type that expresses this common semantics
that procedures often have an expected path of behavior and a rarely taken unexpected path.
* Of course, all the standard containers should have their [`at()` functions](https://en.cppreference.com/cpp/container/vector/at)
with the expectation to not miss the boundaries.
The boundary check is practically free then.

There is a good talk about `std::expected` by Andrei ALexandrescu on CppCon 2018:
["Expect the expected"](https://www.youtube.com/watch?v=PH4WBuE1BHI).
He meantions that it is pointless to worry about the performance impact of boundary checks,
considering the modern processing hardware.

Considering `expected`, it is clear that `[[likely]]` is not some brittle ad-hoc hack to tune the performance.
It provides real information about the program to the compiler.
That is often the way how high performance is achieved:
you do not add random hacky bits, you express the requirements of your program more precisely and explicitly.
It is very much like in the ["Programming Pearls"](https://www.oreilly.com/library/view/programming-pearls-2nd/9780134498058/)
example about that implements a sorting procedure for telephone numbers.
In comparison with a library sorting algorithm,
the custom implementation is way faster and is also simpler and clearer to maintain.
It optimally fits the real world situation and its requirements.
It is less generic than the library sort, sure. But that does not make it hacky.

There is a nice talk on SSW conference by Richard Hipp about [testing SQLite][sqlite_reliability].
Richard Hipp prises built-in testing harnesses.
He refers to the aviation guidelines [DO-178B](https://en.wikipedia.org/wiki/DO-178B)
(or the newer [DO-178C](https://store.accuristech.com/standards/rtca-do-178c?product_id=2200105))
for software (and everything else): test what you fly.
So, SQLite has built-in test mode. And they test it on the fly,
while changing the plugins that talk with the OS VFS in order to emulate a power failure, etc.

The ability to pass the `[[likely]]` info to the compiler is useful here.
You can embed a run time test-mode with no cost in the nominal program.

## Exception handling

Another group of rarely-taken paths in programs are exceptions.
C++ has two mechanisms for exceptions:
`try {} catch {}` with `throw`ing them,
and the `std::unexpected` part of `std::expected`.
In either case, the semantics is explicit about what to expect.
I think, compilers can detect when an `if` branch leads to a `throw` and generate the code accordingly.
At least, that is the case in the [following example as seen on Godbolt](https://godbolt.org/z/nvs4Wo8K9):
```cpp
int main(int argc, char** argv) {
    int res = 5;

    if (argc == 3)
    //[[unlikely]]
    //[[likely]]
    {
        throw std::runtime_error("argc == 3");
    }

    return res;
```

I am not sure whether it is intentional,
but when the attribute is commented out,
the compiler generates the `[[unlikely]]` version as one would expect.

In general, the `try catch` way should be optimal for the happy path.
A `try catch` program has to take an `if` branch inside every sub-procedure
that considers whether to throw an exception.
An equivalent `std::expected` program will have an equivalent if branch
in every sub-procedure that considers whether to return `std::unexpected`.
The difference is that the `try catch` checks the exception only once, when it is thrown.
But the `std::expected` program checks whether it got the value from every sub-procedure.
However, since the compiler knows what to expect,
the additional `if`s in the `std::expected`-based programs are practically free.
And the happy path performance should be optimal with either exceptions or `std::expected`.

There are more differences between exceptions and `std::expected`.
Check out the CppCon 2025 talk ["Can std::expected with Monadic Operations REALLY Boost Your C++ Code Performance?"](https://youtu.be/cjw26MLaCCc?is=VU2trWAlNlIP9jKi)
by Vitaly Fanaskov with a nice example and an overview.

The largest difference is the performance in the bad path.
When an exception is thrown, the program has to [unwind the call stack](https://learn.microsoft.com/en-us/cpp/cpp/exceptions-and-stack-unwinding-in-cpp?view=msvc-170) etc, which is a complex generic and painfully slow operation.
On the other hand, using `std::expected` leans towards functional-style programming
with practically o performance loss on the checks for the unexpected control flow path.
However, functional programming tends to pass things by value or move values.
It can introduce more constructor calls, copies and moves than absolutely necessary.

[likely]: https://en.cppreference.com/cpp/language/attributes/likely
[weekly_cpp_220_likely]: https://www.youtube.com/watch?v=ew3wt0g99kg "C++ Weekly - Ep 220 - C++20's [[likely]] and [[unlikely]] With Practical use Case"
[sqlite_reliability]: https://youtu.be/V_qzqY1bb7I?is=ynXMdTrVr_kRU20a "Reliability Lessons From SQLite - Richard Hipp | SSW 2026"
[godbolt_shortlink]: https://godbolt.org/z/5bosfoj98
