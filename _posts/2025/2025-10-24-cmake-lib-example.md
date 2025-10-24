---
layout: post
slug: cmake_lib_example
title: Concise example of a CMake library package
tags: cmake
---

<summary>
A gist-like example of a library package in CMake.
</summary>

<!--more-->

I couldn't quickly find a simple and somewhat full example of
a library package in CMake, and decided to write one myself.
The library package should be a separate CMake project, buildable on its own.
And it should be usable as an `add_subdirectory`, like a Git submodule.
It may grab some common utility target, like `spdlog`, from the parent project.

So, the top project looks like this:
```
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

project(an_app LANGUAGES CXX)

# Generally useful settings:
# this is the top-level app project, so the standard is known:
set(CMAKE_CXX_STANDARD 23)
# ignore everything in the configured build directory
file(WRITE ${CMAKE_BINARY_DIR}/.gitignore "*")
# run cmake --compile-no-warning-as-error to avoid this
set(CMAKE_COMPILE_WARNING_AS_ERROR ON)

# Actual project:
add_executable(app main.cpp)

# use a library
add_subdirectory(alib)
target_link_libraries(app PRIVATE alib)

get_target_property(AVAR app INTERFACE_INCLUDE_DIRECTORIES)
message(STATUS "INTERFACE_INCLUDE_DIRECTORIES = ${AVAR}")
get_target_property(AVAR app INCLUDE_DIRECTORIES)
message(STATUS "INCLUDE_DIRECTORIES = ${AVAR}")
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

project(alib LANGUAGES CXX)

# only set the cxx_standard if it is not set by someone else
if (NOT DEFINED CMAKE_CXX_STANDARD)
  set(CMAKE_CXX_STANDARD 23)
endif()

# the sources of the lib:
# the source code and the interface header
add_library(alib lib.cpp)
target_include_directories(alib INTERFACE ${PROJECT_SOURCE_DIR}/include)
# for IDEs:
target_sources(alib INTERFACE ${CMAKE_CURRENT_SOURCE_DIR}/include/lib.hpp)

get_target_property(AVAR alib INTERFACE_INCLUDE_DIRECTORIES)
message(STATUS "${PROJECT_NAME} > INTERFACE_INCLUDE_DIRECTORIES = ${AVAR}")
get_target_property(AVAR alib INCLUDE_DIRECTORIES)
message(STATUS "${PROJECT_NAME} > INCLUDE_DIRECTORIES = ${AVAR}")
```

CMake configuration:
```
$ cmake -B build
-- The CXX compiler identification is GNU 13.3.0
-- Detecting CXX compiler ABI info
-- Detecting CXX compiler ABI info - done
-- Check for working CXX compiler: /usr/bin/c++ - skipped
-- Detecting CXX compile features
-- Detecting CXX compile features - done
-- alib > INTERFACE_INCLUDE_DIRECTORIES = /home/ubuntu/tests/cmake/app-n-lib-clean/alib/include
-- alib > INCLUDE_DIRECTORIES = AVAR-NOTFOUND
-- INTERFACE_INCLUDE_DIRECTORIES = AVAR-NOTFOUND
-- INCLUDE_DIRECTORIES = AVAR-NOTFOUND
-- Configuring done (0.8s)
-- Generating done (0.0s)
-- Build files have been written to: /home/ubuntu/tests/cmake/app-n-lib-clean/build
```

The library can grab an existing `spdlog` target
or [`FetchContent`](https://cmake.org/cmake/help/latest/module/FetchContent.html)
on its own when it the package is [`PROJECT_IS_TOP_LEVEL`](https://cmake.org/cmake/help/latest/variable/PROJECT_IS_TOP_LEVEL.html):
```cmake
# alib/CMakeLists.txt
# let's check whether spdlog is defined or fetch it
if (TARGET spdlog)
  message(STATUS "${PROJECT_NAME} > GOT spdlog from parent project")

elseif (PROJECT_IS_TOP_LEVEL)
  message(STATUS "${PROJECT_NAME} > Top level - Fetching spdlog from github")
  # this logic should configure the logging submodule of this project
  include(FetchContent)
  FetchContent_Declare(
          spdlog
          GIT_REPOSITORY https://github.com/gabime/spdlog.git
          GIT_TAG        v1.16.0
  )
  FetchContent_MakeAvailable(spdlog)

else()
  message(STATUS "${PROJECT_NAME} > No spdlog")
  add_compile_definitions(NO_SPDLOG)
endif()

target_link_libraries(alib PRIVATE spdlog)
```

Although, that may not be the best solution.
(There used to be [a flag soup](https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2023/p2800r0.html) in the compilation,
and this looks like a target soup for a library.)

Nice practical tips for daily CMake:
* [Harald Achitz: Some tips for the everyday CMake user, SwedenCpp](https://www.youtube.com/watch?v=3VJPfwn1f2o)

