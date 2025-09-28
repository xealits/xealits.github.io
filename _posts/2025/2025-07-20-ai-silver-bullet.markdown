---
layout: post
slug: ai_silver_bullet
title: AI Silver Bullet
tags: AI software
---

<summary>
The popular promise of AI is to give everyone a silver bullet for
exactly the problem they don't want to deal with. Tech companies
can do tech and forget about "starting with the customer" and culture things.
The AI customers can forget about dealing with the complexity of their software,
which is one of its fundamental problems.
"A silver bullet for everyone" must be a common promise in hypes.
</summary>

<!--more-->

It’s curious how the popular promise of AI suggests to deliver a silver bullet for everyone.

On the side of producers of the technology, the promise is that tech companies can do just what they love: tech. There’s no “start with the customer” or wisdoms on culture and technology from Steve Jobs [[1]][steve-jobs-technology-not-enough] [[2]][steve-jobs-technology-in-search-of-customer].
The customer problem is supposedly solved because the customer wants AI.

Moreover, the AI applications don’t pose any fundamental challenge for the technology. Chip designers can just go wide, keep cramming more trivial cores into the chips, do more matrix multiplications and trivial non-linear functions, possibly with int8 and int4 (!) weight parameters. And the product will come out more valuable.

Sure there are challenges: pumping the data volume through these cores or just delivering the power and cooling the chips, etc. But that’s nothing in comparison to the challenges in single thread computing. It is at hard limit on the clock frequency. You cannot make the latency shorter by adding more hardware.  What you can do is to think a lot about the architecture and implement something smart that can figure out what’s the processing task in the stream of incoming instructions, so that the architecture can adjust its subsystems to pipeline and parallelise that task. I.e. you figure out quite complicated ways how a single core can turn into a bunch of parallel ones fitting a general purpose software program on the fly. And there is no expectation that the resulting product will impress.

On the consumer side, you hear a clear promise to deliver a silver bullet for software development. Complexity has been one of fundamental problems of software, but now you hear something like “software is just plumbing” and that AI can automate it.

The point is that a “just plumbing” part shouldn’t be the core value in your software. It’s great if something can be automated and maintained through AI. It would be even better to figure out how to eliminate it completely. However, the other side of this coin is that by automating or eliminating a routine component the software overall gets denser and more complex. That’s one of the 4 fundamental problems of software development, described in the “No silver bullet” paper by Fred Brooks long ago
[[3]][fred-brooks-no-silver-bullet].
<!--<span><a title="Fred Brooks, No Silver Bullet — Essence and Accident in Software Engineering" href="https://worrydream.com/refs/Brooks_1986_-_No_Silver_Bullet.pdf">[3]</a></span>.-->

Software becomes a condensed concentration of the know how of your application or organisation. Hopefully, the software is as complex as the know how and not more than that. The software also encodes the complexity of the hardware or whatever platform that runs the application. It’s just another part of your know how. Even if you do no-code, it’s probably better to actually know the capabilities of these services.

Now, with AI boom, you hear the promise that there is finally the silver bullet that can automate and solve this concentration of complexity and know how.

It is hard to believe that it can go so easy.

But, indeed, a good application of AI should be exactly about automating inessential things and focusing on the really valuable parts of what you do. Of course, the AI should also perform well, so that the automation process does not become another nuisance to manage.

However, a typical pitfall of automation is that it makes everything look the same. It’s like web site constructors. The problem with these cookie cutter services is that you get similar looking web pages, when your strategy is probably supposed to be that of a differentiator. And if you don’t need to differentiate your web page, then maybe you can do well with a simple site that does not need a special service to make it.

By this I don’t mean to discard the merits of AI, and the boom across the chip making that follows it. It’s just a curious aspect of the hype that I wanted to comment about. Maybe “a silver bullet for all” is a typical promised land in all hypes.

[steve-jobs-technology-not-enough]: https://www.youtube.com/watch?v=3Bh8BoyrMjs "Steve Jobs: Technology Will Not Solve The World's Problems"
[steve-jobs-technology-in-search-of-customer]: https://www.youtube.com/watch?v=rMYSpTFJYKE "Steve Jobs: technology in search of a customer 2006"
[fred-brooks-no-silver-bullet]: https://worrydream.com/refs/Brooks_1986_-_No_Silver_Bullet.pdf "Fred Brooks: No Silver Bullet — Essence and Accident in Software Engineering"
<!--<p>[1] <a name="steve-jobs-technology-not-enough"></a><a href="https://www.youtube.com/watch?v=3Bh8BoyrMjs">Steve Jobs: Technology Will Not Solve The World's Problems</a></p>
<p>[2] <a name="steve-jobs-technology-in-search-of-customer"></a><a href="https://www.youtube.com/watch?v=rMYSpTFJYKE">Steve Jobs: technology in search of a customer 2006</a></p>
<p>[3] <a name="fred-brooks-no-silver-bullet"></a><a href="https://worrydream.com/refs/Brooks_1986_-_No_Silver_Bullet.pdf">Fred Brooks: No Silver Bullet — Essence and Accident in Software Engineering</a></p>-->

Links:
1. [Steve Jobs: Technology Will Not Solve The World's Problems][steve-jobs-technology-not-enough]
2. [Steve Jobs: technology in search of a customer 2006][steve-jobs-technology-in-search-of-customer]
3. [Fred Brooks: No Silver Bullet — Essence and Accident in Software Engineering][fred-brooks-no-silver-bullet]

