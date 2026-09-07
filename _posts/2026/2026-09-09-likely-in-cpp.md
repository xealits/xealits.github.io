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
And it damages the performance as bad as it sounds.
* If the branches are correctly predicted, but they are taken,
they occupy entries in the Branch Target Buffer, BTB.
BTB is a map from the address of a branch instruction to the address of the expected taken jump.
Of course, BTB has limited size.

When a branch instruction is not taken, it does not occupy space in BTB.
And when the branch predictor sees a branch instruction with no entry in BTB, it assumes that the branch is not going to be taken.
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

There are more things that can inform the CPU about the expected control flow behavior:
* [Profile-guided optimisation](https://en.wikipedia.org/wiki/Profile-guided_optimization).
* [C++23 also has `std::expected`](https://en.cppreference.com/cpp/utility/expected)
algebraic type that embeds this common semantics
that procedures often have an expected path of behavior and a rarely taken unexpected path.
* Of course, all the standard containers should have their [`at()` functions](https://en.cppreference.com/cpp/container/vector/at)
with the expectation to not miss the boundaries.
The boundary check is practically free then.

There is a good talk about `std::expected` by Andrei ALexandrescu on CppCon 2018:
["Expect the expected"](https://www.youtube.com/watch?v=PH4WBuE1BHI).
He meantions that it is pointless to worry about the performance impact of boundary checks,
considering the modern processing hardware.

I think, a comparison with `expected` also makes it clear that `[[likely]]` is not some brittle ad-hoc hack to tune the performance.
They both provide semantic information about the meaning of the program to the compiler.
Which is often the case in how high performance is achieved:
you do not add radnom hacky bits, you express the requirements of your program more precisely and explicitly.
It is very much like in ["Programming Pearls"](https://www.oreilly.com/library/view/programming-pearls-2nd/9780134498058/)
example about implementing a sorting procedure for the telephone numbers.
A concrete implementation is way faster, and it is also simpler and clearer to maintain.
It optimally fits the real world situation and its requirements.
It is less generic than a library sort, sure. But that does not make it hacky.

There is a nice talk on SSW conference by Richard Hipp about [testing SQLite][sqlite_reliability].
Richard Hipp prises built-in testing harnesses.
He refers to the aviation guidelines [DO-178B](https://en.wikipedia.org/wiki/DO-178B)
(or the newer [DO-178C](https://store.accuristech.com/standards/rtca-do-178c?product_id=2200105))
for software (and everything else): test what you fly.
So, SQLite has built-in test mode. And they test it on the fly,
while changing the plugins that talk with the OS VFS in order to emulate a power failure, etc.

The ability to pass the `[[likely]]` info to the compiler is useful here.
You can embed a run time test-mode with no cost in the nominal program.

Check out the talk on [expected and monadic expressions and performance](https://youtu.be/cjw26MLaCCc?is=VU2trWAlNlIP9jKi)

[likely]: https://en.cppreference.com/cpp/language/attributes/likely
[weekly_cpp_220_likely]: https://www.youtube.com/watch?v=ew3wt0g99kg "C++ Weekly - Ep 220 - C++20's [[likely]] and [[unlikely]] With Practical use Case"
[sqlite_reliability]: https://youtu.be/V_qzqY1bb7I?is=ynXMdTrVr_kRU20a "Reliability Lessons From SQLite - Richard Hipp | SSW 2026"
[godbolt_shortlink]: https://godbolt.org/z/5bosfoj98
