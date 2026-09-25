---
layout: post
slug: likely_in_cpp
title: Likely in C++
tags: c++ cpu performance
---

<summary>
<a href="https://en.cppreference.com/cpp/language/attributes/likely">Attribute <code class="language-cpp highlighter-rouge">[[likely]]</code></a>
is a good minimal example
of how software can exploit processor features for maximum performance
by providing more information about the program to the compiler.
This post shows an example how <code>[[likely]]</code> affects
the compiled machine code,
talks about how it helps CPU branch predictors,
and points out some of related topics in C++ program design.
</summary>

[The `[[likely]]` and `[[unlikely]]` attributes][likely] tell the compiler
which outcome of a conditional branch to expect.
Using the attribute information,
the compiler
arranges the conditional instructions
in the generated machine code
such that the expected outcome corresponds to _not taken branches_
and the expected control flow executes an uninterrupted sequence of instructions.
The following example shows it in action ([godbolt link][godbolt_shortlink]):

<iframe width="800px" height="350ps" style="height: 350ps !important; min-height: 350ps !important; max-height: 350ps !important;" src="https://godbolt.org/e#g:!((g:!((g:!((h:codeEditor,i:(filename:'1',fontScale:12,fontUsePx:'0',j:1,lang:c%2B%2B,selection:(endColumn:11,endLineNumber:5,positionColumn:11,positionLineNumber:5,selectionStartColumn:11,selectionStartLineNumber:5,startColumn:11,startLineNumber:5),source:'int+big_procedure(void)+%7B%0A++++return+11%3B%0A%7D%0A%0Aint+main(int+argc,+char**+argv)+%7B%0A++++int+res+%3D+5%3B%0A%0A++++if+(argc+%3D%3D+3)%0A++++%5B%5Bunlikely%5D%5D%0A++++//%5B%5Blikely%5D%5D%0A++++%7B%0A++++++++res+%3D+big_procedure()%3B%0A++++%7D%0A%0A++++return+res%3B%0A%7D'),l:'5',n:'0',o:'C%2B%2B+source+%231',t:'0')),k:47.39123797109431,l:'4',n:'0',o:'',s:0,t:'0'),(g:!((h:compiler,i:(compiler:clang2010,filters:(b:'0',binary:'1',binaryObject:'1',commentOnly:'0',debugCalls:'1',demangle:'0',directives:'0',execute:'1',intel:'0',libraryCode:'1',trim:'0',verboseDemangling:'0'),flagsViewOpen:'1',fontScale:12,fontUsePx:'0',j:1,lang:c%2B%2B,libs:!((name:benchmark,ver:trunk)),options:'-Wall+-O3',overrides:!(),selection:(endColumn:1,endLineNumber:1,positionColumn:1,positionLineNumber:1,selectionStartColumn:1,selectionStartLineNumber:1,startColumn:1,startLineNumber:1),source:1),l:'5',n:'0',o:'+x86-64+clang+20.1.0+(Editor+%231)',t:'0')),k:52.60876202890571,l:'4',n:'0',o:'',s:0,t:'0')),l:'2',m:99.99999999999997,n:'0',o:'',t:'0')),version:4"></iframe>

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

The compiler puts the _likely_ control path into a single uninterupted sequence
of instructions, from `main:` to its `ret`.
The unlikely path is behind a conditional jump.

The _not taken_ conditional jump instructions
require almost no resources from the CPU.
The expected control path, where the `je .LBB1_1` branch is not taken, is
practically as efficient as if there are no conditional jump instructions whatsoever.
The compiler optimizes the code towards this ideal case,
based on the hint from the provided `[[likely]]` attribute.

# Branch predictors and corresponding CPU resources

Modern CPUs contain sophisticated branch predictor units.
The branch predictors speculatively assume
whether a given branch instruction might be taken (the control flow might jump to another address in the program)
and
they direct the CPU frontend to load code from the corresponding address
without waiting for the condition to be resolved.
A condition resolution can take a while,
because it often involves reading some variable from the memory or something even slower.
Speculative execution of branches allows the CPU to run without interruptions,
if the branches are predicted correctly.

In general, the bad and the good case of speculative execution affect the CPU in the following ways:
* If a branch is mispredicted, the CPU has to roll back its speculative execution
and process the correct branch.
Which obviously wastes a lot of resources and is bad for performance.
It is also an issue for security.
* If a branch is correctly predicted and is taken,
then the branching instruction occupies an entry in the Branch Target Buffer, BTB.
BTB is a map from the addresses of branch instructions
to the addresses of their expected jump targets.
BTBs are pretty large and can track multiple patterns of branching in the control flow.
But, of course, BTB is limited in size.
It is a finite resource, and [if you use up all of BTB, the performance will degrade](https://stackoverflow.com/questions/38811901/slow-jmp-instruction).

When a branch instruction is not taken, it does not occupy space in BTB.
And when the branch predictor sees a branch instruction with no entry in BTB,
it assumes that the branch is not going to be taken.
This no-history speculation is called static branch prediciton, and the rules can be slightly more complex.
CPUs usually follow the backward taken, forward not taken rule, BTFNT.
(Which fits loops perfectly.)

Hence, if the static not-taken assumption is correct, it is the ideal case:
the CPU executes the right code speculatively, and the branch does not occupy any space in BTB.
The only thing that the CPU does with a not taken branch instruction
is a lookup in BTB, which is basically free.
The `[[likely]]` attribute guides the compiler to produce this ideal case for the CPU.

A collateral nice thing about the control flow with not taken branches
is that the execution goes through an uninterrupted sequence of instructions.
Which is generally good for the instruction prefetcher.
Although,
prefetchers are usually so efficient,
that it is hard to hit a case when their performance noticeably degrades.
An example of such an edge case can be found on Intel's N150 low-power processor
[when the execution happens in a loop at a memory alignment boundary](https://stackoverflow.com/a/79740110/1420489).

# Benchmarking branch predictors

[Chips and Cheese](https://chipsandcheese.com/)
include evaluations of branch prediction performance
in their review articles of different processor models,
such as [this article on E-cores in Intel Lunar Lake](https://chipsandcheese.com/i/149874004/frontend-branch-prediction).
They estimate
how many branch instructions
and how many different branching patterns can be sustained by the branch predictor
without the program losing performance.

These characteristics depend on the size of BTB.
And not taken branches do not take any space in BTB.
It could be interesting to somehow factor out the effect of statically-predicted branches.
For example,
rerun their benchmark for the branching patterns,
but fix the pattern at compile time and compile with profile-guided optimization.
It should show that statically-predicted branches cost nothing at run time.

# Related topics

There are more ways to inform the compiler about the expected control flow pattern:
* [Profile-guided optimization](https://en.wikipedia.org/wiki/Profile-guided_optimization).
* [C++23 introduced the `std::expected`](https://en.cppreference.com/cpp/utility/expected)
algebraic type that expresses this common semantics
that procedures often have an expected path of behavior
and a rarely taken unexpected path where some run-time exception has to be handled.
* I guess, all standard containers already use `[[likely]]` and
have their [`at()` functions](https://en.cppreference.com/cpp/container/vector/at)
with the expectation to not miss the boundaries.
The boundary check is practically free then.

There is a good talk about `std::expected` by Andrei Alexandrescu on CppCon 2018:
["Expect the expected"](https://www.youtube.com/watch?v=PH4WBuE1BHI).
He meantions that it is pointless to worry about the performance impact of boundary checks,
considering modern processing hardware.

There is a nice [talk about testing SQLite by Richard Hipp on the SSW conference][sqlite_reliability].
Richard Hipp prises built-in testing harnesses.
He refers to the aviation guidelines for software
[DO-178B](https://en.wikipedia.org/wiki/DO-178B)
(or the newer [DO-178C](https://store.accuristech.com/standards/rtca-do-178c?product_id=2200105))
and brings up their rule: test what you fly.
So, SQLite has a built-in test mode. And they test the compiled binary on the fly,
while changing the plugins that talk with the OS VFS in order to emulate power failures
and that kind of things.

The ability to pass the `[[likely]]` control flow info to the compiler is useful here.
You can embed a run-time test-mode with no cost for the nominal program execution.

More information about the run-time expectations can be passed to the compiler
with [the `[[assume]]` attribute](https://en.cppreference.com/cpp/language/attributes/assume).
You can pass some facts from a hardware specification to the compiler like that.
Here are a couple [minimal examples on godbolt](https://godbolt.org/z/vEYjPc3Gn).
Notice that the assumptions of the attribute can lead to undefined behavior,
like in the examples where the compiler optimizes away whole `if` statements.
So, it should be used with care.

## Exception handling

A big group of rarely-taken paths in programs are exceptions.
C++ has different mechanisms for different error situations.
(A couple good presentations on modern error handling:
[by Sebastian Theophil on CppCon 2025](https://www.youtube.com/watch?v=TG-trWOZq6Y "Robust C++ Error Handling in C++26 - Sebastian Theophil - CppCon 2025")
and
[by Phil Nash on CppCon 2024](https://www.youtube.com/watch?v=n1sJtsjbkKo "Modern C++ Error Handling - Phil Nash - CppCon 2024").)
There are two main mechanisms for the exceptions that are handled by the program:
* you can `throw` an exception in a `try{}` block
to handle it in a corresponding `catch(){}` block,
* or use the `std::unexpected` part of a `std::expected` return value.

In either case, the semantics is clear on which control path is to expect and which is not.
Compilers can detect when an `if` branch leads to a `throw` and generate the code accordingly.
At least, that is the case in the [following example as seen on godbolt](https://godbolt.org/z/nvs4Wo8K9):
```cpp
constexpr bool throw_in_else = false; // true

int main(int argc, char** argv) {
    int res = 5;

    if (argc == 3)
    //[[unlikely]]
    //[[likely]]
    {
        if constexpr (throw_in_else) {
            res = 11;
        }
        else throw std::runtime_error("argc == 3");
    }

    else {
        if constexpr (throw_in_else)
            throw std::runtime_error("argc != 3");
        else {
            res = 153;
        }
    }

    return res;
}
```

If the `[[likely]]` attributes are commented out,
the compiler generates code where the throw is placed behind the jump of the `argc` condition,
either under `if` or `else`, depending on the `constexpr bool`.
So, the compiler assumes that the exception throw is unexpected, as it should be.

In general, the `try catch` way should be optimal for the happy path performance.
Both `try catch` and `std::expected`-based programs have to take a mandatory `if`
branch inside every sub-procedure that considers whether to throw an exception.
The difference is that the `try catch` does not check for an exception in the happy path,
while
the `std::expected` program checks whether it got the unexpected value from every sub-procedure call.
The `std::expected` way basically doubles the number of `if` statements in the
happy path of the execution.
However, since the compiler knows what to expect,
the additional branches in the `std::expected`-based programs are generated in
the optimal way and should be practically free.
Therefore,
both the exceptions and the `std::expected`
should have a very similar happy path performance.

A caveat about `std::expected` is that it leans towards functional style programming.
In typical functional style, you tend to pass things by value or move values.
So, it can introduce more copies, moves, and constructor calls than necessary.
Which can be noticeable if you pass large or complex objects.

But the largest difference is the performance in the bad path.
When an exception is thrown, the program [unwinds the call stack](https://learn.microsoft.com/en-us/cpp/cpp/exceptions-and-stack-unwinding-in-cpp?view=msvc-170)
to find a corresponding `catch` statement.
It is a complex generic runtime-heavy and painfully slow operation.
Just the fact that there is a huge timing difference between the good and the bad
paths of the exceptions-based programs can be a deal-breaker in some applications.
With `std::expected`, the bad case behavior is not very much different from the good case.

The differences between exceptions and `std::expected`
and a performance benchmark example can be found in
[the CppCon 2025 talk by Vitaly Fanaskov](https://youtu.be/cjw26MLaCCc?is=VU2trWAlNlIP9jKi "Can std::expected with Monadic Operations REALLY Boost Your C++ Code Performance?")
The presented bad path benchmark is quite compelling.
Although, I am not sure whether the presented happy path benchmark is entirely correct.
It seems that the `try catch` example makes unnecessary copies or moves,
which make it somewhat slower.

# Wrap up

The `[[likely]]` attribute
provides real information about the program to the compiler.
It helps to fully express the semantics of such constructions as `std::expected`.
It is not some brittle ad-hoc hack to tune the performance.
And that is often the way how high performance is achieved:
you do not add random hacky bits,
you express the requirements of your program more precisely and explicitly.

The `[[likely]]` attribute also serves as a good primer
on how CPU features support common patterns of software behavior,
and how well fitted software-hardware systems achieve optimal performance.

[likely]: https://en.cppreference.com/cpp/language/attributes/likely "CppReference for attribute likely"
[weekly_cpp_220_likely]: https://www.youtube.com/watch?v=ew3wt0g99kg "C++ Weekly - Ep 220 - C++20's [[likely]] and [[unlikely]] With Practical use Case"
[sqlite_reliability]: https://youtu.be/V_qzqY1bb7I?is=ynXMdTrVr_kRU20a "Reliability Lessons From SQLite - Richard Hipp | SSW 2026"
[godbolt_shortlink]: https://godbolt.org/z/oW34cdnKv "example of likely on godbolt"
