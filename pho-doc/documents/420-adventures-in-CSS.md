---
title: "adventures in CSS"
date: "2018-08-18T03:49:55-04:00"
---
# adventures in CSS

(this article is a stub. i can help expand it.)

[John Earle's medium article][source1] was a good intro to the theory of
the pure-CSS parallax effect.

but then this [one by Karl Danninger][source2] had the advantage of
feeling cleaner because of its use of simple background images (but
we might jump back)..




## our crazy experimental CSS effect .. model

we're calling this "nagel halftone" in reference to the famed late-80's
illustrator and the comic book visual effect; respectively. (we'll revisit
this etymology again below.)

the objective is to do a variation on the "CSS parallax" effect.
normally, in its purest form this effect involves two layers:

       _____________
      / x X x X x  /|   the layer with the
     / X x X x X  / /   context (the text)
    /____________/ /
    |____________|/
        /  ^            as you drag it up and down, it
       /  /             moves pixel-per-pixel one-per-one
      v  /              along with your drags.
         _________
        /  . .   /|     this "parallax container"
       /  \_.   / /     has the picture (peeking
      /________/ /      "above" the content at first)
      |________|/

        /  ^            as you drag, it moves "with" your drags
       v  /             but less distance (slower, if you like)

when you drag the "page" upwards (to try to see more content that's
downwards), the "parallax" effect is where the image moves "more slowly".

now, our *intended* effect wants to take this one step further, with
a *third* layer as an experimental exagerration of this effect:

       __________
      /  s      /|     david bowie
     /    S    / /     ziggy stardust
    /_________/ /      makeup lol
    |_________|/       (moves more)
         /  ^
        /  /
       /  /
      v  /
       _____________
      / x X x X x  /|   text
     / X x X x X  / /   (the one you drag)
    /____________/ /
    |____________|/
        /  ^
       /  /
      v  /
         _________
        /  . .   /|     picture
       /  \_.   / /     (moves less)
      /________/ /
      |________|/
        /  ^
       v  /

the idea is when you scroll (drag) the page up and down, the picture
moves _less_ than you're moving, and the floating ziggy starbucks makeup
moves _more_ (woah!).

(although we're referencing the famous david bowie makeup above,
you'll see an effect suggestive of this in the some of the works of
patrick nagel (for example his duran duran album cover) where it looks
like there's wisps of color floating "above" the subject's face.

finally (and this is very subject to change), here's some more
design criteria for us:

  - we don't just want the picture "peeking above" the text,
    we want it to be in a frame, kind of like the magical moving
    harry potter images in frames; or a bit like looking out a window.

  - we're not sure but we think we don't want the ziggy layer
    to be the topmost because we don't want it to #edit [#410.W]

so, experimentally:

       _____________
      /      X x X /|    a "clear" overlay
     /     x X x  / /    with the writing
    /____________/ /     (the one you drag)
    |____________|/
       ______
      / s   /|
     /   S / /    a "clear" david bowie overlay
    /_____/ /     (that we'll call the "parallax container near")
    |_____|/      (moves the most)
       _____________
      / _____      /|    a "matte" with a "cutout"
     / /|___/     / /    (moves exactly with the one you drag)
    /____________/ /
    |____________|/
       _________
      /  . .   /|    the "parallax container far"
     /  \_.   / /    with the picture.
    /________/ /     (moves the least)
    |________|/


the "matte" layer gives a four-edge boundary for the picture to peek
out from behind around (again just like an ordinary window). probably we
can simplify this later..



## and so..

read [this about clipping][source3].




[source3]: https://getflywheel.com/layout/css-svg-clipping-and-masking-techniques/
[source2]: https://www.okgrow.com/posts/css-only-parallax
[source1]: https://medium.com/@johnearle/all-in-perspective-2996ee463509


## (document-meta)
  - #born.
