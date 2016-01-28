# "myterm"

## introduction

alter the appearance of Iterm2 from the command line. mainly: set the
background image to be a generated image with some meaningful text on
it.




## implemetation and historical context

this is a *complete* overhaul of a little script from 4 years ago. its
objective then was merely to change the background image of terminals.
its objective now is that plus a whole lot of fun experimentation with
our "autonomous component system".




## requirements

  • the default (and for now only) "image output adapter" is one that
    uses ImageMagick (specifically, its `convert` utility must be reachable
    by that name from the PATH). we don't know what our version floor is
    here.

  • the ruby gem dependencies of this package.




## scope

at its essence this script needs only to send a single line to ImageMagick's
`convert` utility to write an image to the filesystem, and then another
small string to OS X's `osascript` command to run an AppleScript that
interacts with iTerm2, telling it to use that generated image for the
background. if it were only that simple, this utility would take up less
than a screen of code to implement. but it is never that simple:

it is our goal to make this process arbitrarily configurable in a way that
can scale out "horizontally" (so to speak): we want the user to be able
to configure arbitrary details to this process (like font, color, size,
etc), and in a way that is intuitive and usable (for a CLI).

furthermore, we as developers of this utility want to be able to add,
remove and modify "configurabilities" like these in a way that gives us
*no* pain of having to wade thru muddied or unstructured code.

futhermore still, we also decided that we wanted the idea of "adapters"
in the mix so that we aren't chained to imagemagick for image
production.

as such the code here is more complicated than it "needs" to be to set
the image, but only as complicated as it needs to be to provide the
compartmentalization and configurability we want.




## reference

  • originally inspired by (and adapted heavily from)
     [kpumuk.info] http://kpumuk.info/mac-os-x/how-to-show-ssh-host-name-on-the-iterms-background/

  • our sole reference for applescript: [iterm2.com] (https://iterm2.com/applescript.html)

  • our sole reference for imagemagick: [imagemagick.org] (http://www.imagemagick.org/Usage/text/)
