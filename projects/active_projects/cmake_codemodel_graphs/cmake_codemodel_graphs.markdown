---
layout: page
title:  CMake codemodel graphs
excerpt_separator: <!--more-->
---
[A prototype Python project](https://github.com/xealits/cmake_graph_tests)
that makes useful graphs of C++ CMake projects from the codemodel info
provided by the [CMake file API](https://cmake.org/cmake/help/latest/manual/cmake-file-api.7.html#object-kind-codemodel).
It handles clusters of dense dependencies among CMake targets.
<!--more-->

<br>


When getting up to speed with ongoing CMake projects,
you want to get some overview of the build targets
without perusing the source code.
This project is a prototype of such a tool.
It is a Python project with a couple modules and `cmake_graph` CLI.
[The source code on github.](https://github.com/xealits/cmake_graph_tests)

CMake does comes with a graphing option:
```
cmake -S . --graphviz=targets.dot
```

But it is not intended for serious use.
To get more info, [CMake team advises](https://discourse.cmake.org/t/cmake-graphviz-a-way-to-show-which-source-files-correspond-to-targets/14119) to [use their file API](https://cmake.org/cmake/help/latest/manual/cmake-file-api.7.html#object-kind-codemodel).

My original goal was to add [Graphviz tooltips](https://graphviz.org/docs/attrs/tooltip/)
with the info on the source files that go into the target,
where the target is defined in `CMakeLists.txt`, etc.
The `cmake_graph` tool makes `.dot` and `.svg` files with that information.
And it also handles clusters of dense dependensies in the project.

For example, the structure of the [CMake project](https://gitlab.kitware.com/cmake/cmake/) (zoom in for tooltips):
<object class="colem-5" type="image/svg+xml" data="./targetgraph-_cmake.svg">Browser doesn't support object tag for SVG</object>

The large circle represents a cluster of dense dependencies,
where 16 targets are used by 17 other targets in the project.

The SVG was made like this:
```
git clone --recursive git@gitlab.kitware.com:cmake/cmake.git cmake_src
cd cmake_src
cmake_graph setup -B build/
cmake -S . -B build/
...
cmake_graph graph -B build/ --skip-types UTILITY
ls targetgraph-.svg
```

