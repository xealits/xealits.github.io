---
layout: page
title:  Modern C++ for programming Ti MSP430
excerpt_separator: <!--more-->
description: <a href="https://github.com/xealits/msp430chip">C++14 library for MSP430</a> and a better workflow for embedded programming.
---

Embedded programming can be quite painful.
A lot of effort produces limited results.
Which is not fun to do as a hobby on a weekend.

Electronics and hardware are pretty tough on their own.
But software does not have to be like that.

[This project](https://github.com/xealits/msp430chip)
combines several tools and methods to streamline and improve
the development of embedded software for Ti MSP430.
The goal is to make it palatable for weekend projects
that are more complex than just a one-off toy.
Other chips (like Ti C2000, ESP32, Atmel, and Nordic) can be included in future.

The project started with a modern C++ library for MSP430,
and now it combines several things:

* C++14 library for MSP430. The 14 standard is chosen
because it is the highest standard that the Ti compiler for MSP430 `cl430` supports.
The library describes the memory map of MSP430 in an explicit way,
using purely static compile-time features, like fully static classes, namespaces, and templates.
Instead of a 1000-line header with `#define` macros,
where each definition is an acronym of >3 letters and numbers,
you get structured compile-time definitions that are easily understood by IDEs (or VSCode).
The code also comes with Doxygen comments that contain info from the User Guides and datasheets.

* Single-sourced parsable datasheet-like documentation.
This is an old idea from PhD times.
The point is to combine many documentation files on embedded devices and their C headers into a single document
that is easily accessible for parsing.
So that you do not have to look through many PDFs, C headers, libraries, and your code
while working on basic features.

  + On practice, I combine the [SLAU144K User Guide](https://www.ti.com/lit/ug/slau144k/slau144k.pdf)
with the info from concrete chips datasheets
([SLAS735J for msp430g2553](https://www.ti.com/lit/ds/symlink/msp430g2553.pdf))
into a Markdown+HTML document like the [`prototype_datasheet`](https://github.com/xealits/msp430chip/blob/main/prototype_datasheet.md).
 A simple Pandoc command is used to generate an HTML out of that.
 And a Python Beautifulsoup4 script is used to generate the device headers
 using the structures of the C++ library.
 Thanks to the explicitness of the modern C++, the generation of the code is very straightforward.
 The generation script adds Doxygem comments with the info from the datasheet and User Guide to the code.
  + Effectively, a single window in any standard IDE should show you all the information about the devices that you need.

* Example projects that build up a handy software architecture for MSP430 devices.
I would like to build up some support for a typical architecture with an event loop:
interrupts register tasks and the main loop executes them in a cooperative scheduling fashion.
Like in the articles by [Nathan Jones on EmbeddedRelated](https://www.embeddedrelated.com/showarticle/1636.php).
Or, I would like to just use an existing open source framework,
like from [QuantumLeaps](https://github.com/QuantumLeaps/qpcpp).

  + On top of a single-chip software,
 it would be great to set up an expandable system with many MSP430 chips.
 The front-end chips use I2C and other features (ADC, Comparator)
 to talk with the hardware. (The 4-pin Grove connectors.)
 On the backend side, they are either just available for the user directly over UART.
 Or they use SPI to talk with a controller chip, and the controller chip talks on UART.
 (The 6-pin JST SH connectors.)
  + This architecture fits the features and capabilities of MSP430 well.

* Investigation into verification capabilities of things like
[Rocq](https://rocq-prover.org/), [TLA+](https://lamport.azurewebsites.net/tla/tla.html),
and [synchronous languages](https://www-verimag.imag.fr/~halbwach/PS/iee03.pdf) like [Ceu](http://www.ceu-lang.org/).
I think it should be possible to write the simple embedded programs in modern C++
such that the program follows the semantics of synchronous languages.
Which should permit to automatically convert the C++ code into an input to a verification system,
and get some useful feedback from it.

