---
layout: post
slug: everything_is_possible_in_words
title: Everything is possible in words
tags: comments logic
---

<summary>
Words can contain any logic.
</summary>

<!--more-->
<br>


There was some self-contradictory statement
on an [ITk](https://cerncourier.com/a/a-new-atlas-for-the-high-luminosity-era/) meeting recently
which made me think that really any logic is possible in words.
It was probably something about project timeline.
Like, "let's work on A" and a couple sentences later "we should also start B",
but everybody will be busy with A and B actually depends on A to be able to start.
Or something like that.

This sort of "words can contain anything" situation
caused a bunch of confusion for me back in early university years,
when I was trying to figure out how the [Virtual Memory](https://en.wikipedia.org/wiki/Virtual_memory) works in computers.

The idea itself is simple. The goal, the math of it, is quite apparent:
you want to run multiple processes on one computer,
of course they should not see each other's memory,
they should see some "virtual memory" addresses which are somehow translated into real physical addresses.
But how?

So, I spent a couple evenings googling and trying to figure out how the CPU does it.
My impression was that I should not need a real book on CPU architecture for this.
The idea is simple. So, a clear explanation should be somewhere on internet.
But the blogs, Stackoverflow, Electronics Stackexchange, Wiki, etc made no sense.

Some explanations would begin with a pattern like:
"the CPU does _whatever is needed for translation_".
But, if you read about "what CPU can do?"
You will get "the only thing a CPU does is just execution of instrucitons one by one..."
So, does it mean there are some instructions that perform the virtual-to-physical address translation?
How come? At what moment do these instructions show up in the program then?

There were other confusing points.
It is clear that such statements miss some point that just adds a dimension to the system behavior.

The missing point in those explanations was the Memory Management Unit.
Coincidentally, it is the thing that delivers the Virtual Memory capability.

Smaller processors (micro-controllers) don't have MMUs.
And they don't have Virtual Memory.
They run a single program directly on the physical memory addresses.
If you create some software modules for such systems,
you have to take care that they don't step onto each other's memory.

MMU is the thing that makes Virtual Memory possible.
Just like wheels enable cars to smoothly ride down a road.

If one can "explain" Virtual Memory
without mentioning or focusing on Memory Management Unit,
one can really do anything in words.


# PS: Some more examples

Notice how the [Virtual Memory Wiki](https://en.wikipedia.org/wiki/Virtual_memory) mentions MMU only in two places:
> The operating system manages virtual address spaces and the assignment of real memory to virtual memory.[5]
> Address translation hardware in the CPU, often referred to as a memory management unit (MMU),
> automatically translates virtual addresses to physical addresses.
> Software within the operating system may extend these capabilities, utilizing, e.g., disk storage,..

* MMU "automatically translates virtual addresses" _when?_
In the execution of an instruction that makes a memory access,
i.e. in the execution of a memory access micro-op.
In fact, the memory access goes via MMU.
* Also, what means "the OS manages virtual addresses and the assignment of real memory"?
It means that OS manages the virtual memory translation tables for the MMU table walking unit.
I think it is crucial to say that the point is to manage the MMU, a concrete hardware device that makes the magic happen.
It is better than to say "the OS manages virtual addresses and assignments" in the abstract.
* The extension capabilities are good, but they are not really essential.

Then another mention in "Paging supervisor":
> This part of the operating system creates and manages page tables and lists of free page frames.
> ...
> The paging supervisor may handle a page fault exception in several different ways, depending on the details:
> * If the virtual address is invalid, the paging supervisor treats it as an error.
> * If the page is valid and the page information is not loaded into the MMU,
> the page information will be stored into one of the page registers.

Most of texts on MMU and Virtual Memory are just mushy and abstract like that.
These two thing don't really go together: mushiness and abstraction.

A similar confusion can happen when talking about a device driver and a corresponding device.
The driver manages the device.
So, of course, it represents a lot of device's structures,
register contents, pointers into DMA buffers, etc.
It shows up in hish speed networking, when some text calls something a "hardware buffer".
It could mean a buffer in the smart network card itself.
But it actually may mean the DMA buffer on the CPU side, in the driver.
The hardware (the network card) dumps its data via DMA into that buffer.
So, it makes sense to call it the "hardware buffer",
as opposed to other queues and buffers that the software system (like DPDK) manages to deliver all its features.

The software works like a remote representation of the hardware device.
So it is natural to confuse the two.

It is a typical pattern in particle physics Data Acquisition systems,
where devices sit in hard radiation environments, really remote from the DAQ software.
However, that brings up a caveat:
a large distance between the software and the devices under control
means a significant latency in communication.
And big latency means that the software cannot represent just the device alone.
It has to somehow account for the remoteness,
i.e. for the communication channel and the latency.
That turns it into a more involved asynchornous system.

