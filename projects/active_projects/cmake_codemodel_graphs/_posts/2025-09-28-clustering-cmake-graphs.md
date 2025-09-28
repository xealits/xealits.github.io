---
layout: post
slug: clustering_cmake
title: Clustering CMake graphs
tags: cmake software tools
---

Making CMake codemodel graphs more readable by clustering dependency edges.

<!--more-->
<br>

A graph of dependencies among targets in a CMake project
can be quite complex.
For example, a graph of targets in CMake itself looks like this:
```
git clone --recursive https://gitlab.kitware.com/cmake/cmake.git
cmake -S . --graphviz=cmake_targets.dot
```
<img style="width: 100%;" src="/dir/files/cmake_graph/cmake_graphviz_targetgraph-_crop.png" alt="Example output picture (cropped) from the CMake builtin graphviz tool">

In this case, the graph is complex because
there is a cluster of 16 targets that are used by 17 others.
There are simply too many edges that connect all-to-all
in this group of targets.
Now the [`cmake_graph_tests`](https://github.com/xealits/cmake_graph_tests)
project includes a simple clustering algorithm,
implemented in `DepCluster` class,
`find_cluster` and `find_all_cluster` functions.

The clusters look like the following in CMake:
```
cmake_graph graph -B cmake/build --skip-types UTILITY --frequent-deps-threshold 3
```
<object class="colem-8" type="image/svg+xml" data="/dir/files/cmake_graph/targetgraph-_cmake.svg">Browser doesn't support object tag for SVG</object>

A graph of [`rocksdb`](https://github.com/facebook/rocksdb) without test targets turns out manageable too:
```
cmake_graph graph -B rocksdb/build --skip-types UTILITY --skip-names "rocksdb_check|.*test.*" --frequent-deps-threshold 3
```
<object class="colem-8" type="image/svg+xml" data="/dir/files/cmake_graph/targetgraph-Debug_rocksdb_notests.svg">Browser doesn't support object tag for SVG</object>

I also tried to make a graph of [Abseil](https://github.com/abseil/abseil-cpp).
It still looks too busy to be useful.
Of course, using `--skip-names` filters it would turn out a bit more manageable.
But I want to look at it a bit more,
to try to figure out whether something can make the graph more readable,
yet retaining all the precise info about the software.

