---
layout: page
title:  OpenGL lib for data visualisation
excerpt_separator: <!--more-->
description: C++ library for working with OpenGL and data visualisation, somewhat similar to <a href="https://glumpy.readthedocs.io/en/latest/">Glumpy</a> in its object-oriented interface.
---

An upcoming library that wraps OpenGL in modern C++ with an object-oriented interface
that is similar to the ideas of [Glumpy](https://glumpy.readthedocs.io/en/latest/).
The goal is to make it easy to put together advanced rendering pipelines
and complex structures of buffers and attributes in OpenGL,
and to use these capabilities in for data visualisation
in a [Grammar of Graphics](https://en.wikipedia.org/wiki/Wilkinson%27s_Grammar_of_Graphics) style.

OpenGL is a very-C library, where things happen implicitly,
as a reaction to the sequence of your commands.
Like, when you have to bind buffers by their IDs, in the right order etc.
All of that is error-prone and hard to keep in mind.
Also, all of that is just the setup of the graphics pipeline.
It does not require any particularly high performance.
So, it should be done in a normal object-oriented way,
where everything is explicit, flexible, exposes all features of OpenGL,
easy to understand for the programer,
and all the OpenGL details are automatically accounted for in by the library.

I am testing a prototype of this library,
and will publish it on Github, when the interface becomes somewhat stable.
