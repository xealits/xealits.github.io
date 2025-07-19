---
layout: post
title: Pop up a full image in Web
highlighter: rouge
---

3 ways to open a full image:

{% highlight html %}
<img src="/img/thumb"
  onclick='this.src="/img/full"'>
<img src="/img/thumb"
  ondblclick='window.open("/img/full", ...)'>
<a href="image2.gif">
  <img src="image1.gif">
</a>
{% endhighlight %}


<!--more-->

This page uses a fixed-width grid, and images fit into it.
When you have a situation like that, with thumbnails of images,
how to open them into full size images?

Three nice ways from Stackoverflow.
1. Make the in-grid image [link to the full picture](https://stackoverflow.com/questions/467927/how-can-i-make-a-thumbnail-img-show-a-full-size-image-when-clicked/468088#468088):

   ```
   <a href="image_full.gif">
     <img src="image_thumb.gif">
   </a>
   ```

   It is nice, but it looks like the link `<a>` does not support double-clicking.
   I don't want to spread single-click events all over the web page.
   It would be like traps for the user everywhere.
  
2. [Use JS & ondblclick to change `this.src`](https://stackoverflow.com/questions/467927/how-can-i-make-a-thumbnail-img-show-a-full-size-image-when-clicked/467946#467946):

   ```
   <img src="/img/thumb" onclick='this.src="/img/full"'>
   ```
   
   Good JS, but it works in-place. I need to open it in a new window.

3. [Open a window](https://stackoverflow.com/questions/32954980/html-js-how-to-open-an-image-in-an-image-popup-by-clicking-on-it/63511881#63511881) instead of `<a>` to use the `<ondblclick>` event:

   ```
   <img src="/img/thumb" ondblclick='window.open("/img/full", ...)'>
   ```

   Let's stick with this one.

