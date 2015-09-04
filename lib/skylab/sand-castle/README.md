# ("sand castle" ramblings)

## intro

a sand-castle is like a tumblr for presenting interactive infographics.

  • imagine different members of the community forking and and modifying
    each other's sand castles.

a sand-castle can be built from different "forms" provided by
the platform. (forms are like the "tools" of a Photoshopper's toolbox.)

one available form is a "cull table". [..] one possible side-effect of i
building (and playing with) a cull table is that you can find "hidden stories" in the data, like (EDIT).




## which javascript framework?

### reading notes -

  2007 ember
  2009 angular
  2010 backbone

7:05 AM we decide to go with angular per what we read in
https://www.airpair.com/js/javascript-framework-comparison
near the size of the community, etc.

we might migrate to ember later; its supposed similarity to Cocoa is
enticing. we will probably not use backbone.

also we like Angular's emphasis on testing.




## "requirements" & suggestions for our "table sort" (cull)

  • informatically (might be visually too)

    * (later) drag-move whole column to left or right (to re-order columns)

    * hide or show any column (see next supersection)

    * toggle sort between asc/desc (like wikimedia, but different design)

    * each column's "scalarizer" (sort criteria) has an XXX

    * for "enum-like" column "classifications" ..


  • visually (when not informatically)

    * no mouseover - imagine this is all touch

    * it would be nice if by default we styled these to look like
      a wikipedia table

    * hiding/showing columns needs design

  • implementation-wise,

    * as stated in previous section, we would like to use angular
    * notwithstanding above, consider that mediawiki (wikipedia) uses
      the "tablesorter" jquery plugin


## angular

### August 31

09:42 AM we start "learning" it ..

### Sept 01

1:26 AM: we are pleased with Karma (detects file changes)

23:58 install grunt (less than a minute)

### Sept 02

hit a wall with Java runtime being needed, it's a legacy one
that's needed

    http://community.sitepoint.com/t/angularjs-book-error-on-sh-scripts-e2e-test-sh/113532

finally (at step 04) understanding the significance of two-way data
binding.
