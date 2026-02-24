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

OpenGL has a very-C interface, where things happen implicitly,
as a reaction to a sequence of your commands.
Like, when you have to bind buffers by their IDs in the right order etc.
All of that is error-prone. And there is no point to keep it in mind.
Also, all of that is just the setup of the graphics pipeline.
It does not require any particularly high performance.

What is really needed is a normal object-oriented interface to OpenGL,
where everything is explicit and flexible.
It must expose all features of OpenGL and be easy to use correctly.
All the OpenGL details must be handled by the library itself.

I am testing a prototype of this library,
and will publish it on Github, when the interface becomes somewhat stable.
