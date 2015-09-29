# reading notes

## about this document

because our studies take unexpected turns as unknown unknowns become
known unknowns, during the course of our studies it is difficult to
achieve a well-balanced hierarchical taxonomy of the information
encountered in real time. it is for this reason that we have organized this
document into more-or-less chronoloical nodes.

we put the most recent nodes at the top of the document. so to read it
chronologically, start from the last node in the document. within the
nodes, however, the flow will typically be chronological.




## contents (entry "nodes")

### Se



### September mid -

  • (udacity) Intro to HTML & CSS L3: Bootstrap & other frameworks
    * frameworks
      + [Bootstrap]: (http://getbootstrap.com/)
      + [Foundation]: (http://foundation.zurb.com/)
      + [Yaml]: (http://www.yaml.de/)
      + [960 Grid]: (http://960.gs/)
      + [Suzy]: (http://susy.oddbird.net/)
      + [Frameless]: (http://framelessgrid.com/)

  • (note to self - look at these)
    * http://beebom.com/2015/01/best-front-end-frameworks-for-bootstrap-alternative
       (near montageJS)
    * http://modernweb.com/2014/02/17/8-bootstrap-alternatives/
       (near HTML Kickstart)




### Semptember 13th - begin tutorials

welp looks like google has some [good tuts][].

    google developers
    ├ android
    | ├ home
    | ├ guides
    | └ reference
    |
    ├ iOS
    | ├ x
    | └ x
    |
    └ web
      ├ (dev tools, starter kit, stay up to date, shows, showcase)
      └ fundamentals
        ├ device access & integration
        ├ discovery and distribution
        ├ forms and user input
        ├ images, audio & video
        ├ look and feel
        ├ monetization
        ├ multi-device layouts
        ├ optimizing performance
        ├ principles of site design
        └ tools


[good tuts]: (https://developers.google.com/web/fundamentals/)

• there is this "udacity" thing.

3:55 AM - udacity i guess..

  • I learned: Cmd-Opt-J or Ctrl-Alt-J to open developer tools

  • 4:12 I learned how to spoof user agents. Wow udacity is fuuunnn!!

  • 4:20 start lesson 2

    * i learned what a "hardware pixel" is

    * i leared "DIP" (device independent pixel): mobile browsers will
      render the page as if it's for a screen that's 980 DIPs wide
      imagine a phone that is 360 dips wide, etc.

    * i learned what "font boosting" is and why it's bad.

    * laporte: 'adding the "viewport" tag is us telling the browser
        we know what we are doing.'
      generally, we would rather have the content reflow instead of
        scaling it.

    * 320 pixels is generally the fewest on a device.

    * our fingers are about 10 mm wide (1/2 inch), which is about 40
      CSS pixels. so shoot for 48x48. make sure to keep at least 40px
      between such "tap targets".

    * i learned about "nav" tag and "main" tag

  • 5:48 start lesson 3 - "building up"

    * the only media types worth using are "screen" and "print".
      ("handheld", "projected", "embossed" never gained traction)

    * these are the three ways to apply media queries:

      + use the "media" attribute on a linked stylesheet,
            <link rel="stylesheet" media="screen and (min-width: 500px)" href='over-500.css'>

      + embed them with an "@media" tag:
            @media screen and (min-width: 500px) {
              /* CSS here */
            }

      + import them with an "@import" tag:
            @import url('x.css') only screen and (min-width: 500px);

        - for performance reasons, AVOID USING "@import"

    * the only queries you will generally use are "min-width" and
      "max-width". ("min-device-width" and "max-device-width" are
      strongly discouraged.)

    * we call these things "breakpoints" - the screen widths at which
      the layout changes.

    * they call that (damn) thing the "hamburger" icon.

    * "minor breakpoints" are when there is something slightly different

    * "scott yeoh [sp?] said it best: we shouldn't chose breakpoints at
      all. instead, we should find them using our content as a guide."

    * (15th "morsel") "the grid fluid system". examples: "bootstrap" or
      the 960 grid layout system.

    * in the intro to HTML & CSS course, they cover grid-based layouts.

    * "flexbox is one of the most powerful tools you can use for
      layout":
        + display: flex; flex-wrap: wrap;  [..] order: 1 [etc]

  • lesson 4 - Common Responsive Patterns (10:20AM)

    * 4 of them: "column drop", "mostly fluid", "layout shifter",
      "off canvas"

    * can be used in some combinations

  • lesson 5 - Advanced Techniques (11:05AM)

    * "art direction" and the new "picture" element

  • (we jumped to intro to HTML/CSS) ..




### September 3rd - reading notes re: which javascript framework?

  2007 ember
  2009 angular
  2010 backbone

7:05 AM we decide to go with angular per what we read in
https://www.airpair.com/js/javascript-framework-comparison
near the size of the community, etc.

we might migrate to ember later; its supposed similarity to Cocoa is
enticing. we will probably not use backbone.

also we like Angular's emphasis on testing.




### September 2nd

hit a wall with Java runtime being needed, it's a legacy one
that's needed

    http://community.sitepoint.com/t/angularjs-book-error-on-sh-scripts-e2e-test-sh/113532

finally (at step 04) understanding the significance of two-way data
binding.




### September 1st

1:26 AM: we are pleased with Karma (detects file changes)

23:58 install grunt (less than a minute)




### August 31st, 09:42 AM start "learning" angular ..
