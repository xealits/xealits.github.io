---
layout: page
title:  CMake codemodel graphs
description: Use CMake text-api for useful C++ projects graphs.
---

Use [CMake file-api](https://cmake.org/cmake/help/latest/manual/cmake-file-api.7.html)
for useful graphs of build targets in C++ projects.

<!--more-->

# Examples

Structure of the [CMake project](https://gitlab.kitware.com/cmake/cmake/) (zoom in for tooltips):
<object class="colem-5" type="image/svg+xml" data="./targetgraph-_cmake.svg">Browser doesn't support object tag for SVG</object>

The large circle represents the cluster of dependencies,
where 16 targets are used by 17 other targets in the project.
