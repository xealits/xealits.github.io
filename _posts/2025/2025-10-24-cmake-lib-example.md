---
layout: post
slug: cmake_lib_example
title: Concise example of a CMake library package
tags: cmake
---

<summary>
A gist-like example of a CMake project with an app and a library sub-project.
(Updated on 2025-11-18.)
</summary>

<!--more-->

I couldn't quickly find a simple and somewhat full example of
a basic library package in CMake, and decided to post one myself.
There is a lot of information on CMake. But it is a bit dispersed.
This example combines a couple handy features in one place.
I plan to follow it up with more posts,
on the installation and `RPATH:$ORIGIN` for flexible relative dependencies,
CTest-CDash pipeline setup, CMake introspection bits, etc.

This example builds a CMake project with an application executable `app`
that uses a custom `lib` library.

The intention is that their sources live in the same version control repository.
But the library package should be a separate CMake project, buildable on its own,
in case you may want to move it to a separate repository in future.
However, both the app and the library use some common infrastructure targets,
like Catch2 for testing.

* So, the library source defines its own `CMakeLists.txt`.
Which makes it usable with `add_subdirectory` in the source tree, like a Git submodule.
And it could also be downloaded with `FetchContent` at build time.
* A later post should cover a configuration of the installation,
which would make the library binary and headers available for `find_package`.
* The library sub-project
uses some common utility targets, like Catch2 or `spdlog`.
It should be able to grab them from the parent project.
But if the library is built on its own, it finds `spdlog` on the system
or downloads it with `FetchContent`.

Let's start with the minimum.
The top project looks like this:
```sh
$ tree --gitignore
.
├── CMakeLists.txt
├── alib
│   ├── CMakeLists.txt
│   ├── include
│   │   └── lib.hpp
│   └── lib.cpp
└── main.cpp
```

The `main.cpp` calls a function from the library:
```cpp
// main.cpp 
#include "lib.hpp"

int main() {
  foo();
  return 0;
}

// alib/include/lib.hpp
int foo(void);

// alib/lib.cpp
#include <iostream>
#include <source_location>

int foo() {
  std::source_location srcl = std::source_location::current();
  std::cout << "running alib foo() at: " << srcl.function_name() << "\n";
  return 5;
}
```

The top project `CMakeLists.txt`:
```cmake
cmake_minimum_required(VERSION 3.28)

project(an_app
  VERSION 0.0.1
  LANGUAGES CXX
)

# this is the top-level app project, so the standard is known:
set(CMAKE_CXX_STANDARD 23)

# Generally useful settings:
# ignore everything in the configured build directory
file(WRITE ${CMAKE_BINARY_DIR}/.gitignore "*")
# run cmake --compile-no-warning-as-error to avoid this
set(CMAKE_COMPILE_WARNING_AS_ERROR ON)
# export compile_commands.json for users & IDEs
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Actual project:
add_executable(app main.cpp)

# use a library
add_subdirectory(alib)
target_link_libraries(app PRIVATE alib)

message(STATUS "${PROJECT_NAME} ${PROJECT_VERSION} > configured")
```

The project links `app` to the library target `alib`.
The `app` does not need to expose this library as a part of its [interface](https://cmake.org/cmake/help/latest/manual/cmake-buildsystem.7.html#target-command-scope) to the build users.
Therefore `alib` is linked as `PRIVATE`, not `INTERFACE` or `PUBLIC`.
([Qt YouTube on the topic](https://www.youtube.com/watch?v=ARZd-fSUJXY).)
In fact, `app` is an executable, it probably does not have build-time users.

The important bit is that [`target_link_libraries()`](https://cmake.org/cmake/help/latest/command/target_link_libraries.html)
adds the whole interface of the `alib` target to the `app` build process.
The library include directory is added to the target interface with [`target_include_directories`](https://cmake.org/cmake/help/latest/command/target_include_directories.html):
```cmake
cmake_minimum_required(VERSION 3.28)

project(alib
  VERSION 0.0.2
  LANGUAGES CXX
)

# Generally useful settings:
# only set the cxx_standard if it is not set by someone else
if (NOT DEFINED CMAKE_CXX_STANDARD)
  set(CMAKE_CXX_STANDARD 23)
endif()

# ignore everything in the configured build directory
file(WRITE ${CMAKE_BINARY_DIR}/.gitignore "*")
# run cmake --compile-no-warning-as-error to avoid this
set(CMAKE_COMPILE_WARNING_AS_ERROR ON)
# export compile_commands.json for users & IDEs
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# the sources of the lib:
# the source code and the interface header
add_library(alib lib.cpp)
target_include_directories(alib INTERFACE ${PROJECT_SOURCE_DIR}/include)
# for IDEs:
target_sources(alib INTERFACE ${CMAKE_CURRENT_SOURCE_DIR}/include/lib.hpp)

message(STATUS "${PROJECT_NAME} ${PROJECT_VERSION} > configured")
```

And you can build either the top or the library:
```
$ cmake -B build
-- The CXX compiler identification is GNU 13.3.0
-- Detecting CXX compiler ABI info
-- Detecting CXX compiler ABI info - done
-- Check for working CXX compiler: /usr/bin/c++ - skipped
-- Detecting CXX compile features
-- Detecting CXX compile features - done
-- alib 0.0.2 > configured
-- an_app 0.0.1 > configured
-- Configuring done (0.2s)
-- Generating done (0.0s)
-- Build files have been written to: /home/ubuntu/tests/cmake/blog-cmake-2025-10/build

$ cmake --build build
...
```

Let's add Catch2 tests to the `alib` code.
```sh
$ cd alib/
$ tree
.
├── CMakeLists.txt
├── include
│   └── lib.hpp
├── lib.cpp
└── tests
    ├── CMakeLists.txt
    └── test.cpp
```

The `tests/` subdirectory declares an executable target that runs Catch2 tests.
Catch2 [exports two targets](https://github.com/catchorg/Catch2/blob/devel/docs/cmake-integration.md):
`Catch2::Catch2` and `Catch2::Catch2WithMain`.
The `alib` project checks whether `Catch2::Catch2WithMain` already exists,
or it runs FetchContent to either find an installed Catch2 on the system
or download it from GitHub.
```cmake
# tests/CMakeLists.txt
cmake_minimum_required(VERSION 3.28)

# only set the cxx_standard if it is not set by someone else
if(NOT DEFINED CMAKE_CXX_STANDARD)
  set(CMAKE_CXX_STANDARD 23)
endif()

# get Catch2
if(TARGET Catch2::Catch2WithMain)
  message(STATUS "${PROJECT_NAME} > GOT Catch2 from parent project")

else()
  message(STATUS "${PROJECT_NAME} > Top level - FetchContent Catch2 w FIND_PACKAGE_ARGS 3")

  include(FetchContent)
  FetchContent_Declare(
    Catch2
    GIT_REPOSITORY https://github.com/catchorg/Catch2.git
    GIT_TAG        v3.8.1 # or a later release
    FIND_PACKAGE_ARGS 3
  )
  FetchContent_MakeAvailable(Catch2)
endif()

# check that Catch2 target exists
if(TARGET Catch2::Catch2WithMain)
  message(STATUS "${PROJECT_NAME} > GOT Catch2")
endif()

add_executable(${PROJECT_NAME}_tests test.cpp)
target_link_libraries(${PROJECT_NAME}_tests PRIVATE Catch2::Catch2WithMain)
target_link_libraries(${PROJECT_NAME}_tests PRIVATE alib)
message(STATUS "${PROJECT_NAME} > tests in ${PROJECT_NAME}_tests")
```

The target is named `${PROJECT_NAME}_tests`, to avoid name collisions
with the users of the `alib` project.

Also, `FetchContent_Declare` uses the feature `FIND_PACKAGE_ARGS 3`
to try to `find_package()` an installed Catch2 on the system
before downloading from GitHub.
It is available in FetchContent
[since CMake 3.24](https://discourse.cmake.org/t/how-to-find-package-optional-in-cmake-3/15309).
In earlier versions, you would need to call `find_package(Catch2 3 QUIET)` yourself.

The tests code:
```cpp
// tests/test.cpp
#include <catch2/catch_test_macros.hpp>

#include "lib.hpp"

unsigned int Factorial(unsigned int number) {
  return number <= 1 ? number : Factorial(number - 1) * number;
}

TEST_CASE("Factorials are computed", "[factorial]") {
  REQUIRE(Factorial(1) == 1);
  REQUIRE(Factorial(2) == 2);
  REQUIRE(Factorial(3) == 6);
}

TEST_CASE("Big factorial is computed", "[factorial]") {
  REQUIRE(Factorial(10) == 3628800);
  REQUIRE(Factorial(11) == 39916800);
}

TEST_CASE("My lib foo()", "[lib]") { REQUIRE(foo() == 5); }
```

And let's add the tests under `BUILD_TESTING` condition:
```cmake
# alib/CMakeLists.txt
cmake_minimum_required(VERSION 3.28)

project(alib
  VERSION 0.0.2
  LANGUAGES CXX
)
...

if(BUILD_TESTING)
  add_subdirectory(tests)
endif()

message(STATUS "${PROJECT_NAME} ${PROJECT_VERSION} > configured")
```

Now when building the library with tests:
```sh
$ cd alib/
$ cmake -B build -DBUILD_TESTING=ON
-- The CXX compiler identification is GNU 13.3.0
-- Detecting CXX compiler ABI info
-- Detecting CXX compiler ABI info - done
-- Check for working CXX compiler: /usr/bin/c++ - skipped
-- Detecting CXX compile features
-- Detecting CXX compile features - done
-- alib > Top level - FetchContent Catch2 w FIND_PACKAGE_ARGS 3
-- alib > GOT Catch2
-- alib > tests in alib_tests
-- alib 0.0.2 > configured
-- Configuring done (0.2s)
-- Generating done (0.0s)
-- Build files have been written to: /home/ubuntu/tests/cmake/blog-cmake-2025-10/alib/build
```

You get an executable that wraps all the test cases:
```
$ build/tests/alib_tests --list-tests
All available test cases:
  Factorials are computed
      [factorial]
  Big factorial is computed
      [factorial]
  My lib foo()
      [lib]
3 test cases

$ build/tests/alib_tests
Randomness seeded to: 3679069128
running alib foo() at: int foo()
===============================================================================
All tests passed (6 assertions in 3 test cases)

$ build/tests/alib_tests "My lib foo()"
Filters: "My lib foo()"
Randomness seeded to: 3878183522
running alib foo() at: int foo()
===============================================================================
All tests passed (1 assertion in 1 test case)
```

It is handy when all tests are packed into a single executable
and you can list them and run individually.
Less targets to compile and link etc.
In more complex cases, it may be necessary to build the test code in separate executables.

In general, it is worth to add the testing execitables to the CTest framework.
It would mean to add `include(CTest)` in `CMakeLists.txt` config,
which sets `BUILD_TESTING=ON` by default.

So, I will follow up with a post on a basic CTest-CDash setup.
I will also try to put together something on logging,
how to make it really optional, with `spdlog` or just `iostream` printouts.
You may want to have an option to go back to `iostream`
in restricted environments, like re-building something on Zynq systems
that have only serial connection, etc.
There should also be a post about the installation and `RPATH` with `$ORIGIN` parameter.
And there are more interesting topics:
CMake presets & VSCode setup with a dev container,
compilation on Windows, and cross-compilation to ARM.

For now this example demonstrates a basic project:
* It is a CMake project with an executable application and a library sub-project.
The library can be a sub-directory in the source tree, like a git submodule,
or it could be downloaded at build time, according to the build configuration.
* It links the library as `PRIVATE`.
* The library exposes its headers as `INTERFACE` with the `target_include_directories()` command.
* It also uses Catch2 for tests.
Unless Catch2 is already available in the project,
the library gets it with FetchContent and optional `FIND_PACKAGE_ARGS`,
* The CMake configs include the common good practice for setting
`CMAKE_CXX_STANDARD` and `CMAKE_EXPORT_COMPILE_COMMANDS` etc.

Also, for a bunch of good practical tips on daily CMake, check out:
[Harald Achitz: Some tips for the everyday CMake user, SwedenCpp](https://www.youtube.com/watch?v=3VJPfwn1f2o)

