---
layout: page
title:  CMake codemodel graphs
excerpt_separator: <!--more-->
description: <a href="https://github.com/xealits/cmake_graph_tests">A prototype Python project</a> that makes useful graphs of C++ CMake projects from the codemodel info provided by the <a href="https://cmake.org/cmake/help/latest/manual/cmake-file-api.7.html#object-kind-codemodel">CMake file API</a>.  It handles clusters of dense dependencies among CMake targets.
---

When getting up to speed with a CMake project,
you want to get some decent overview of the build targets
without perusing the source code.
It should show
which source files are built into the targets,
the compilation definitions,
how the targets depend on each other, etc.
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
<object class="colem-8" type="image/svg+xml" data="/dir/files/cmake_graph/targetgraph-_cmake.svg">Browser doesn't support object tag for SVG</object>

The large circle represents a cluster of dense dependencies,
where 16 targets are used by 17 other targets in the project.

The SVG was made like this:
```
git clone \
  git@gitlab.kitware.com:cmake/cmake.git \
  cmake_src
cd cmake_src
cmake_graph setup -B build/
cmake -S . -B build/
...
cmake_graph graph -B build/ --skip-types UTILITY
ls targetgraph-.svg
```

