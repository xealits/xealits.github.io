---
layout: post
slug: possible_in_words
title: Possible in words: examples
tags: comments logic
---

<summary>
Words can contain any logic.
</summary>

<!--more-->
<br>

It is a somewhat typical situation in technical documentation,
that some fundamental points can be said only somewhere between lines.
When it is not a new thing, made by somebody else long ago,
everything relies on it implicitly without caring
what that is, how it works, why, etc.


# Wiki example

[Virtual Memory Wiki](https://en.wikipedia.org/wiki/Virtual_memory) mentions MMU only in two places.
The page summary gives more info, but it is in the abstract:
> The computer's operating system, using a combination of hardware and software,
> maps memory addresses used by a program, called virtual addresses,
> into physical addresses in computer memory.
> ...
> The operating system manages virtual address spaces and the assignment of real memory to virtual memory.[5]
> Address translation hardware in the CPU, often referred to as a memory management unit (MMU),
> automatically translates virtual addresses to physical addresses.
> Software within the operating system may extend these capabilities, utilizing, e.g., disk storage,..

* What means "the OS, using a combination of hardware and software, maps memory addresses"
and "the OS manages virtual addresses and the assignment of real memory"?
It means that OS manages the virtual memory translation tables
for the MMU table walking unit in the system memory.
I think it is better to say that the point is to manage the MMU,
a concrete hardware device that makes the magic happen,
than to say "the OS maps virtual into physical addresses" in the abstract.

* After talking how the OS maps and manages virtual addresses,
it is worth to clarify: MMU "automatically translates virtual addresses" _when?_
During the execution of instructions that make memory accesses.
The memory access goes via MMU.
If MMU knows a given virtual address, it translates it
and accesses the corresponding address in the real memory.
If it does not know it or was told to refresh its translation info,
it reads the translation info from the memory,
which is set up and managed by the OS.

  Specifically, instructions contain memory access micro-ops,
which launch transactions between the CPU core registers and the memory.
But there are more things that are going on in modern CPUs:
memory access transactions also include operations on caches,
they can also trigger hardware cache prefetchers.

* The extended capabilities are good,
but they are not really essential for a Virtual Memory discussion.

Then another mention is in "Paging supervisor":
> This part of the operating system creates and manages page tables and lists of free page frames.
> ...
> The paging supervisor may handle a page fault exception in several different ways, depending on the details:
> * If the virtual address is invalid, the paging supervisor treats it as an error.
> * If the page is valid and the page information is not loaded into the MMU,
> the page information will be stored into one of the page registers.

Most of texts on MMU and Virtual Memory are malleable and abstract like that.
A malleable abstraction is not a good combination.


# Device drivers

A similar confusion can happen when talking about a device driver and a corresponding device.
The driver manages the device.
Of course, it represents a lot of device's structures,
register contents, pointers into DMA buffers, etc.
So, when you talk about something in this system,
the subject can be unclear:
is it about some state in the hardware device or the software driver?

For example, a text on high speed networking can call something a "hardware buffer".
Is that a buffer in the smart network card itself?
It actually may mean the DMA buffer on the CPU memory side, in the driver.
The hardware (the network card) dumps its data via DMA into that buffer.
So, it makes sense to call it the "hardware buffer",
as opposed to other queues and buffers that the software system manages
to provide all its features.

The software works like a remote representation of the hardware device.
So it is natural to confuse the two.

This case is typical in particle physics Data Acquisition systems,
where devices sit in hard radiation environments, really remote from the DAQ software.
However, that brings up a caveat:
a large distance between the software and the devices under control
means a significant latency in communication.
And big latency means that the software cannot represent just the device alone.
It has to somehow account for the remoteness,
i.e. for the communication channel and the latency.
That turns it into a more involved asynchornous system.


