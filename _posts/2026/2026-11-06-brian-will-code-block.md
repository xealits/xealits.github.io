---
layout: post
slug: lambdas_as_brian_code_blocks
title: C++ lambdas as Brian Will's code blocks
tags: c++
---

<summary>
Back 10 years ago, Brian Will made a series of YouTube videos
on various practical issues in programming.
In a video on issues with OOP,
he pointed out that well-structured long procedures
can be more readable and maintainable than a bunch of encapsulated objects,
and suggested
<a href="https://www.youtube.com/watch?v=QM1iUe6IofM&t=2435s">
a "<code>use</code> code block" language feature</a>
that works as
"an anonymous function that does not see anything in its enclosing scope"
and helps to better express the logic of a procedure
by structuring its name space.
<a href="https://en.cppreference.com/cpp/language/lambda">
C++11 introduced lambdas</a> with very similar scoping rules.
This post takes a look at how lambdas
can organise the name space of long procedures
in order to make them more readable.
</summary>

Brian Will suggested anonymous and immediately-called closure functions
that work like the following pseudocode `use` block:
```
function MyFunc() {
  int x, y;

  a = use x {
    // sees only a copy or a reference of x from the outer name scope
    println("got x = {}", x);
    user_input = getln("enter factor: ");
    return x * user_input;
  }

  // further procedure on a, x, y
}
```

The `use <names>` block limits the visible outer scope names
to the given explicit list.
It executes a procedure, like a regular `{...}` compound statement,
but with a finely defined view of the outer scope.
And it can return a value.

The C++ lambdas are anonymous functions that follow very similar scoping rules.
A basic lambda looks like this: `[captures] (params) {body}`.
The visible outer names are defined by
[the lambda captures](https://en.cppreference.com/cpp/language/lambda#Lambda_capture):
> The `captures` defines the outside variables that are accessible from within the lambda function body.

So, you can explicitly define what the lambda sees from the outer scope:
```cpp
#include <iostream>

int main() {
  // a long procedure with many stages
  int x = 5, y = 10;

  // one of sub-procedures
  auto a = [x] (void) {
    // x is there:
    std::cout << "got x = " << x << "\n";
    // y is not captured:
    //std::cout << "got y = " << y << "\n";

    std::cout << "enter a factor: ";
    int input_factor; // un-initialized
    std::cin >> input_factor;
    if (std::cin.fail()) {...}

    return x * input_factor;
  } (); // call the lambda immediately

  // further procedure on a, x, y
}
```

The global namespace is visible inside the lambda body.
For example, `std::cout` and `std::cin` are visible.
Which makes sense.
The global namespace is sort of the language of the program.
So, it is reasonable that everything in the program can talk that language.
Also, lambdas are implemented as anonymous structs
that are declared in the global scope.
Lambdas are a sort of syntactic sugar that
works as a shortcut to
a bunch of nicely put together basic C++ features.

Interestingly, `constexpr`s do not need to be captured:
```cpp
int x = 5;
constexpr int z = 2;

auto a = [x] (void) {
  // both x and z are there:
  std::cout << "got x = " << x << "\n";
  std::cout << "got z = " << z << "\n";
}();

std::cout << "got a = " << a << "\n";
// got a = 7
```

The `[x]` captures `x` by copy, but you still cannot modify it in this lambda:
```cpp
auto a = [x] (void) {
  ...
  // return x * input_factor;
  x *= input_factor;
  std::cout << "modified x inside the lambda to: " << x << "\n";
  return x;
} ();

// clang:
// error: cannot assign to a variable captured by copy in a non-mutable lambda
// |     x *= input_factor;
// |     ~ ^
```

The reason is that lambda's `operator ()` is `const` by default.
And the captures are members of the lambda object.
So a `const` member function cannot modify them.
You can declare lambdas with the `mutable` specifier to avoid the `const` function call:
```cpp
auto a = [x] (void) mutable {
  ...
  // return x * input_factor;
  x *= input_factor;
  std::cout << "modified x inside the lambda to: " << x << "\n";
  return x;
} ();
```

Another option is to pass `x` as a simple argument:
```cpp
auto a = [] (auto x) {
  x *= input_factor;
  std::cout << "modified x inside the lambda to: " << x << "\n";
  return x;
} (x);
```

It is a bit cumbersome to write `x` two times.
Lambda captures are a better fit for the procedural style
that Brian Will suggested.
What you want is just the usual `{...}` compound statements
with a fine and explicit control of the name scope.
And lambdas provide exactly that.

There are small differences with the `use` block.
For example, lamdas are not called immediately.
They are just not tailor-made to enhance compound statements.
Instead, lambdas combine a bunch of already existing and known C++ features
for building anonymous closures that serve many use-cases.


# Expressive code blocks

One simple and nice thing that you can do with a lambda is
a clean initialization procedure for a `const` value:
```cpp
// in a really simple case:
const int simple_value = condition ? 0 : 1;

// in more complex cases:
const int complex_value = [&condition](void) {
  int res;
  SomeTempValue temp1, temp2;
  ...
  return res;
} ();
```

It is nice because the code says exactly what it does
and
the name scoping also meaningfully contributes to saying what the code does.
The lambda pocedure takes only a `const` reference of the `condition` from the outer scope,
executes some procedure without leaking its internal variable names,
and returns a value for the initialization of the `const` variable.

It also profits from the [return value optimization](https://en.cppreference.com/cpp/language/copy_elision)
and constructs the `complex_value` only once, inside the lambda.
You can check it out
[in this example on godbolt](https://godbolt.org/z/4ec9G6fWd)
that uses a typical `Lifetime` struct,
but with most constructors deleted.

The return value of a lambda can be unpacked
with a [structured binding](https://en.cppreference.com/cpp/language/structured_binding),
to further improve the readability in some cases:
```cpp
{
  int x = 5, y = 10;

  auto [a, b, c] = [x] (void) {
    float input_factor{1.1};
    return std::tuple{x, input_factor, x * input_factor};
  } ();

  std::cout << "got:"
    << " a = " << a
    << " b = " << b
    << " c = " << c << "\n";
  // got: a = 5 b = 1.1 c = 5.5
}
```

Lambdas lead into functional programming.
Indeed, one can try adding some processing stages to these procedural blocks:
```cpp
using Data = int;
using Err = std::runtime_error;
using DataOrErr = std::expected<Data, Err>;

{
  Data final_result = [argc](void) -> DataOrErr {
    ...;
  } ()
  .transform(...)
  .transform_error(...)
  .value_or(Data{});
  // it could be handy if value_or took a lambda as an argument
}
```

But I do not think that it makes sense for the sub-procedures
and the use-case that Brian Will discussed.
Monadic operations are about combining reusable components in the program,
therefore they are about handling the connections between the components.
But Brian Will's talk is all about declining to try to invent reusable components
when there is no visible need for them.

The main use-case of sub-procedures is to improve
readability and maintainability
of a complex procedure that is _unique_ in your program.

It is not about things like handling a `parse_int(string)`
which may hit different error conditions
and which may be used in multiple places in a program.
It is about a procedure that starts up some hardware or some complex software framework.
Maybe certain parts of the start-up will become reusable in the future.
But if that has not happened yet, there is no point in making them reusable speculatively.
(If there is a clear view of the future architecture, then it can work.
Because you are not speculating in that case, you are planning,
hopefully competently planning.)

An example from personal experience
where this style of writing sub-procedures with lambdas
could have helped.
I worked on an application
that talked to instrumentation hardware, VME bus cards from [CAEN](https://caen.it/).
The hardware came with a C library,
and our application was written mostly in C style.
So, the application had one place where it would set up the hardware
with a bunch of calls to its library,
checking the return codes for errors etc.
It looked something like this:
```cpp
int Setup(enum Param setting) {
  int param = TranslateSetting(setting);
  int data_call_a;
  int status = call_a(param, ..., &data_call_a);
  if (status < 0) {
    ...;
    throw ...;
  }

  // perform call_b, call_c
  // ...
  // check something on data_call_a, _b, _c

  return 0;
}
```

Most of the code lines were about handling errors and other bits.
The main logic of the program was dimly glittering through that.
And that was at a time when the whole project was at a prototyping stage.
So the main logic of the setup was a subject of work and change.

Sub-procedures can wrap the handling of the C-style calls
and let the top procedure focus on the main logic:
```cpp
int Setup(enum Param setting) {
  const int data_call_a = [setting](void) {
    // TranslateSetting could also be a nested sub-procedure:
    const int param = [setting](void) {
      switch (setting) {
        case Param::A:
          return 1;
        ...
      };
    } ();

    // C-style call
    int data;
    int status = call_a(param, ..., &data);
    if (status < 0) {
      ...;
      throw ...;
    }

    return data;
  } ();

  // ...
  return 0;
}
```

The name space is cleaner.
The exceptional cases are handled inside the sub-procedure blocks,
instead of everything happening in the same name space.
And you can easily fold the `{}` blocks in your text editor
to look only at the main control flow of the program.


# Extra comments

Reaching for lambdas and other advanced features may not always be necessary.
Basics are often sufficient to improve readibility.
And basics have the advantage of compiling faster.

Appropriate name-scoping with `{...}` compound statements can be all you need.
And C++ allows you to instrument `{...}` blocks with RAII-style objects:
the lifetime of an object is tied to the name scope,
the constructor is executed at the beginning and the destructor at the end of the scope,
with correct behavior in case of thrown exceptions.

C++17 introduced [init-statements for the `if` statement](https://en.cppreference.com/cpp/language/if):
now you can write `if (Type obj{}; condition) {}` and the `obj` is defined only for the `{}` body.
[Here is a good 2016 post from Steven Lorimer about it](https://skebanga.github.io/if-with-initializer/).
C++17 also introduced a very welcome `if constexpr`, with init-statements included.
Nicolai Josuttis' talk on ACCU 2018 ["C++17 - The Best Features"](https://youtu.be/e2ZQyYr0Oi0?t=251)
includes a bunch of excellent examples that demonstrate these and other features,
and also show their combinations.

It goes without saying that lambdas have many more uses than just arranging the name space.
Among many things, they can be template arguments. Which brings them to compile-time programming.

Finally, Brian Will mentioned
an interesting idea of ["surface area of the code"](https://youtu.be/QM1iUe6IofM?t=1910)
in the same original video.
If you consider the name space of a program,
the number of individual names and how their visibility is structured,
it gives you a good idea about the complexity and readability of the program.
(One could also call it "surface area of the _interface_".)
A small surface area is easier to read, understand, and maintain.
It is an interesting topic, and I will get back to it in a future post.

One curious point about it is to also consider the testability of a program.
In principle, a large surface area of the interface is better for testability.
So, is there a conflict between the two, and if so then what drives it?
That will be another post.
