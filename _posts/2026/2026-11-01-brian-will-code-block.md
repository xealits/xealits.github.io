---
layout: post
slug: lambdas_as_brian_code_blocks
title: C++ lambdas as Brian Will's code blocks
tags: c++
---

<summary>
Back 10 years ago, Brian Will made a series of YouTube posts
on various practical issues in programming.
In the video on OOP,
he suggested
<a hreff="https://www.youtube.com/watch?v=QM1iUe6IofM&t=2435s">a "code block" language feature</a>
that works as
"an anonymous function that does not see anything in its enclosing scope".
Such code blocks are useful for structuring long procedures,
expressing the logic more explicitly in the lexical structure.
C++11 introduced lambdas with very similar name scoping rules.
Since then, C++ lambdas got improved and expanded into quite a capable semantic vehicle.
This post takes a look at lambdas
as a tool to structure sections of code.
</summary>


* Introduce what Brian Will was talking about.
Rewatch his description of the code blocks. - Done.
* Introduce the name scoping rules of C++ lambdas.
Re-check the definitions.
  - Point out that the global name space is still visible.
  Show that the static file scope and the global scope are visible.
* Go for the idiom. The point is to structure a procedure.

He suggests defining anonymous functions inside other functions,
but limit the name scope that they see.
He writes pseudocode (based on Go?), which means the following:
```
function MyFunc() {
  int x, y;

  // we want to execute an anonymous function here
  function () {
    // but the anonymous function does see x and y
    // - I am not sure, is that how sub-functions in Go or Javascript work?
    // it is true for C++ code blocks {}
  } ();
}

a = use x, y {
  ...
  // sees only x and y copies or references from the outer name scope
  return x + y;
}
```

Brian Will [points out](https://youtu.be/QM1iUe6IofM?t=1955) a good idea of "surface area of the code".
When you split large functions into small ones, you increase the surface area for no good reason.
This is exceellent.

One issue with it is testability.
When you expose a larger surface area than what is actually used,
you expose more internals for the testing tools.
That's probably what is meant sometimes when people say "write programs that are testable".
However, I'd argue that it is not a good idea to expose more interface than is actually used,
just because that is the only way to get testing tools to run on internal control flow branches.
It is not great to modify the logic of the program, its interface surfaces,
just to fit a testing tool.
It would show more green checkmarks, sure. But what is the value in those checkmarks?
Also, could there be another way to test, that reaches internal structures somehow?

The issue here, if the program exposes only the minimal interface of its own logic,
then the tests must be able to reach all the internal control flow branches.
And if a procedure is large and there are many branches, the combinatorics of
internal branchs grows fast, even if the internal structure of the procedure is trivial.
In principle, breaking stuff up into small units works against this combinatorics.
Even if a large procedure is a trivial combination of small sub-procedures,
the testing tool does not know that. The tool sees the interface of a large procedure,
and it does not know that the interface somehow factors out.
So, in order to test some internal branch,
it has to pass the inputs that affect that branch together with each variant of all other inputs.

The unitification of functions, splitting them into small units,
expresses how the internal functionality and interfaces factor out.
It makes the testing run easier. And it is useful information in general.
You just do not want it to be exposed to the normal program as if that internal
structure can be used elsewhere in the overall program.
**So, it is a good question how to do it well, aside of the the usual exposing the internal stuff.**
Like, does just a class with a bunch of members fit here? A static class?
Instead of defining a function, define a static class with `operator()` and private members.
The sub-functions go into private members.
Yeah, you still break up the main code inside `operator()`,
but you clearly show that these procedures are used only here, and they are defined for testing too.
**Maybe it could go into a "use static classes" post.**

It may be indeed a bad influence of tooling:
you run a procedure only as a sub-procedure in a single place in the program,
but testing to test it, you need to expose it as a part of the interface...
Can you _declare_ it as a part of the interface, but _define_ it only where it actually runs?
No, I don't think that's possible.

* I should mention this whole thing here and make another post on it.
Carefully and simply describe the combinatorics and procedure interfaces there.
  - Brial Will shows `void (*)(void)` procedures. There are no inputs. Hence,
  there are no problems with factoring them out for testing.
  So, mention this too.

* Thesis: exposing more of the internal interface surface
  describes how that surface factors out, which greatly reduces the combinatorics of testing.
  The important part is not that you expose the internal interfaces just to make
  them available for testing tools. Testing tools could run on the large procedure
  and scan its input parameter space.
  The point is that space is way too large, unless you somehow describe that it factors out.

* Maybe also show a progression of procedure evolution?
Just a procedure, then with simple code blocks for sections,
then with lambdas for getting output from the code blocks,
then you want to test it,
you want to express the fact that the functionality and the interface factor out.


# Name scope of a C++ lambda


# Jotted down idioms:

My motivation for initializing a `const`:

* In general, I am not sure whether lambda with `ref&` is that much better than just a code block.
  Yeah, a lambda limits the name scope. It is nice. But it is not such a big deal on practice.
  On the contrary, a code block does not return anything, and lambda does return stuff.
  Lambdas are more useful with return values here.

* So, I would say in the description of lambda name scope rules:
here is how lambda limits the name scope,
here is how you can explicitly capture what you need,
but then lambdas also return stuff.
You control the scope for input and output of this block.
And proceed to this section with idioms.

Brian Will's original point was to just do stuff in the function, make some side effects.

* Are there some handy idioms for a procedure with side effects?

In the following idioms, I initialize something from the code block.
In principle, this is more typical. Because, if the code block does not see anything in its scope,
then the point of the code block should be to return something.

* Initialize a `const` is one of them. Do show an example with a `constexpr` inside lambda.

* Show lambda initializing a `constexpr`. Get a new GCC or Clang and initialize a constexpr `std::vector` or `std::set`.
The point is that you can generate and built-in content into your binary like that.
For example, you could pre-generate some textures or meshes for a game like that.
Mention `consteval` code blocks can `return` a `constexpr` value too.
  - All this should be verified. In case of a lambda and `constexpr`,
  a compiler is allowed to convert it into a runtime procedure, right?

* Show capture by constant.
It could also pass a parameter by const-ref.
But that changes the meaning to a wrong one.
The lambdas in this post are just code blocks,
they are not called multiple times.
Hence, they must not have parameters and the parameters must not be passed.
These lambdas must only capture the needed stuff from the name scope.

* Show the return value optimisation.
So, make a Godbolt example, show assembly. Show a complex custom object.
Add a pointer or just a string or a vector inside the object.
  - It also shows that you can have complex return values in C++.

* Combine it with the multi-name [structured binding](https://en.cppreference.com/cpp/language/structured_binding)?
  - Multi-name binding, this could unpack a tuple, and a tuple is weirdly a polymorphic data structure.
  Is there something here? Run a templated loop on a tuple, then unpack? Why do that inside a lambda?

* Code block with a possible exception:
`std::expected` monadic operations
to initialize a variable and handle exceptions
from [Phil Nash](https://youtu.be/n1sJtsjbkKo?t=1227&is=BwJeY0u50CNJ-yNE).

* Also to note: lambda lets you define a function inside another function.
So, if you want to call something a few times inside a function,
but you call it only there and you don't want to expose it to the static scope of the file,
you can use a lambda.

* And that's enough? This should be enough for the case of returning something from a lambda,
without capturing anything or doing anything unusual with the capture, i.e. capturing by constant.

But, if you return nothing, then maybe you capture something and act on it?
That is also useful as a code block, because it is explicit in the lambda what it captures and acts upon.
An interesting capture is when it is captured by reference without const, when you act on it.
Which is kind of unusual, to act on an object in a bunch of sequential procedures.
You execute some calculations on a big object like that?
Maybe you work with some UI like that.
Otherwise, is it some complex initialization? Maybe adding a bunch of layers of Decorators?

* What if the lambda captures a thread-safe SPSC queue,
processes some UI and pushes the UI commands to the queue?
This should be a named function, imho. For debugging and sanity.

* You could contain `const_cast` in a lambda like that.
Again, lambda is just a block of code, with a limited scope input.
Maybe a lambda around a `const_cast` would make it more explicit that this is a danger zone.
But I am not sure if it is really needed.

* **So, a good example for a `ref&` capture is an open question.**


## More ideas to check

**Check if it is worth to mention factory registry.**
Notice, the static initialization can make use of some smart procedures.
The procedures can be lambdas.
Does it simplify an object factory registry?

* In principle, it is nice to just show running a procedure for a static initialization.

Lambda idioms. Note lambda template parameters:
```cpp
auto fn = []<typename T>(T, T) {};
```

In principle, the template parameters are not useful for this post,
because here I do not pass any parameters.
I capture or no stuff

# Wrap up

Check this.
[Immediately invoked _coroutine_ lambdas: lifetime pitfalls etc](https://www.youtube.com/watch?v=mF2YMIKZUMg).

Mention that lambdas are useful in many more situations.
And show the perf counter parameter as an example?

Also, mention that there are other ways to statically structure code.
RAII for code blocks.
And `if` initializers, for example `dynamic_cast<>` or lock in an if.
Check [Josuttis on a new lock in C++17](https://www.youtube.com/watch?v=e2ZQyYr0Oi0&t=638s).

