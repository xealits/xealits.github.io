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
Rewatch his description of the code blocks.
* Introduce the name scoping rules of C++ lambdas.
Re-check the definitions.
  - Point out that the global name space is still visible.
  Show that the static file scope and the global scope are visible.
* Go for the idiom. The point is to structure a procedure.


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

