---
layout: page
title:  Perf records in C++
excerpt_separator: <!--more-->
description: <a href="https://github.com/xealits/perf_records">C++ library</a> for software performance studies.
---

[The library](https://github.com/xealits/perf_records)
enables a typical workflow that I follow in investions of software performance.
It is a tool for dedicated studies of performance in specific sections of software,
possibly in connection with some external hardware or software configuration within a larger system.

* It provides a simple interface to the Linux [`perf_event` subsytem](https://www.brendangregg.com/perf.html)
that manages access to the Performance Monitor Unit
of modern CPUs. And it also manages custom software counters.

  + The goal is to access all PMU events of a given CPU model.
  I do not really use the general events that have standard nicknames in Linux, like `PERF_TYPE_HARDWARE` type.
  Those events are more relevant for system monitoring in administration and operations.
  This library uses the Intel's [perfmon](https://github.com/intel/perfmon) descriptions
  to access all PMU events as `PERF_TYPE_RAW` type.

* It is easy to integrate as one or two drop-in header files.

* It dumps the counters in HTML format that is easy to copy-paste
into a Markdown document, which I typically use while logging a study.

* The Markdown is converted into an HTML, which is easy to parse
and generate CSV files with the data in the long format.
Then I use standard tools to analyse the data, like R and [ggplot2](https://ggplot2.tidyverse.org/).

  + The C++ library does not do any statistical operations,
  like aggregations or percentile calculations.
  + The goal is to get the data from the CPU and the software,
  print it out in a logable format, which is then easy to parse and dump into a long-format CSV.
  All the post-processing and analytics is done with standard tools for data analysis.

There are similar packages:

* [libperf](https://github.com/theonewolf/libperf) - the last commit is from 12 years ago.
* [PAPI](https://icl.utk.edu/papi/) - a large framework with many large industrial partnerships
that is "[Exa-PAPI team is] channeling the monitoring capabilities of hardware counters, power
usage, software-defined events into a robust PAPI software package for exascale-level systems."
* [perf-cpp](https://github.com/jmuehlig/perf-cpp) by Jan Mühlig - it is very similar
to my tool, although it is somewhat larger (the built library is a couple 10s MB)
and it does perform some statistical operations in Cpp.
Also, my guess is that there is no intention to implement a workflow with dumping
the data into an HTML for a log in Markdown.
But,
when I get a clearer idea for where my tool is headed,
I want to look more into it and check whether there is a possibility to merge some features.
