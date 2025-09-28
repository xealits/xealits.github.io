---
layout: post
slug: possible_in_words
title: Possible in words
tags: comments logic
---

<summary>
Words can contain any logic.
</summary>

<!--more-->

There was some self-contradictory statement
on an [ITk](https://cerncourier.com/a/a-new-atlas-for-the-high-luminosity-era/) meeting recently
which made me think that really any logic is possible in words.
It was probably something about the project timeline.
Like, "let's work on A" and a couple sentences later "we are also starting B",
but everybody will be busy with A and B actually depends on A to be able to start.

It reminded a similar "words can contain anything" situation
that
caused a bunch of confusion for me back in early university years,
when I was trying to figure out how the [Virtual Memory](https://en.wikipedia.org/wiki/Virtual_memory) works in computers.

The idea of Virtual Memory itself is simple.
The goal, the math of it, is quite apparent:
you want to run multiple software processes on one computer,
of course they should not see each other's memory,
they should see some "virtual memory" addresses
which are somehow translated into different addresses in the real physical memory.
But how?

So, I spent a couple evenings googling and trying to figure out how the CPU does it.
My impression was that it should not need a real book on CPU architecture.
The idea is simple. So, a clear explanation should be somewhere on internet.
However, the blogs, Stackoverflow, Electronics Stackexchange, Wiki, etc made no sense.

Some explanations would just converge to saying
"the CPU does the translation".
But, if you look for "how CPU works", what it can do,
you will get "the only thing a CPU does is just execution of instrucitons one by one..."
So, does it mean there are some instructions that perform the virtual-to-physical address translation?
How come? At what moment do these instructions show up in the program then?
If you compile a program and look at assembly, there are no extra instructions.

In such situations, it is clear that some point is missing,
which just adds a degree of freedom to the system behavior.

The point was that those explanations did not mention the Memory Management Unit (MMU).
Coincidentally, MMU is the thing that delivers the Virtual Memory capability.

Smaller processors don't have MMUs.
And they don't have Virtual Memory.
They run a single program directly in the physical memory addresses.
If you create some software modules in such a system,
the software itself has to take care that they don't step onto each other's memory.

MMU is the thing inside CPU that makes Virtual Memory possible.
CPU instructions access memory via MMU.
MMU contains a cache with the current translation table
of the virtual-to-physical addresses,
the Translation Lookaside Buffer (TLB).
When the current translation info has to be updated,
e.g. because the Operating System invalidated the TLB entries with the `INVLPG` instruction,
MMU reads the up-to-date info in the system memory
at the address that is given in the `CR3` register.
(These are x86 instruction and register. ARM has similar ones.)
The Operating System sets up and manages the tables in the memory for the MMU to read,
and it writes the address of the current table to the `CR3` register.
The tables contain the mappings of each process' virtual addresses to the physical system memory.

If it is possible to "explain" Virtual Memory
without mentioning or focusing on Memory Management Unit,
then anything is possible in words.

