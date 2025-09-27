---
layout: page
title:  CMake codemodel graphs
description: Use CMake text-api for useful C++ projects graphs.
---

[A prototype Python project](https://github.com/xealits/cmake_graph_tests)
that makes useful graphs of C++ CMake projects
from the codemodel info provided by
the [CMake file API](https://cmake.org/cmake/help/latest/manual/cmake-file-api.7.html#object-kind-codemodel).
It handles clusters of dense dependencies among CMake targets.

<!--more-->
<br>


When getting up to speed with ongoing CMake projects,
it would be nice to get some overview of the build targets,
without perusing the source code.
This project is an exploration of what such a tool should do.
[The source code on github.](https://github.com/xealits/cmake_graph_tests)

CMake does comes with a graphing option:
```
cmake -S . --graphviz=targets.dot
```

But it is not intended for serious use.
To get more info, CMake team advises to [use their file API](https://discourse.cmake.org/t/cmake-graphviz-a-way-to-show-which-source-files-correspond-to-targets/14119).

My original goal was to add [Graphviz tooltips](https://graphviz.org/docs/attrs/tooltip/)
with the info on the source files that go into the target,
where the target is defined in `CMakeLists.txt`, etc.
Now the tool does that, can output `.dot` and `.svg` files,
and it also handles clusters of dense dependensies in the project.

For example, the structure of the [CMake project](https://gitlab.kitware.com/cmake/cmake/) (zoom in for tooltips):
<object class="colem-5" type="image/svg+xml" data="./targetgraph-_cmake.svg">Browser doesn't support object tag for SVG</object>

The large circle represents a cluster of dense dependencies,
where 16 targets are used by 17 other targets in the project.

