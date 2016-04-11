# "myterm"

## introduction

alter the appearance of Iterm2 from the command line. mainly: set the
background image to be a generated image with some meaningful text on
it.

from an implementation standpoint, the bulk of this utility is concerned
with giving fine-grained control over details that go into producing
this background image.




## implemetation and historical context

this is a *complete* overhaul of a little script from 4 years ago. its
objective then was merely to change the background image of terminals.
its objective now is that plus a whole lot of fun experimentation with
our "autonomous component system".




## requirements

  • we assume that the minimum version of iTerm2 that allows for
    programmatic altering *of the background image* is
    2.9.20140903 but #todo we need to ascertain the exact version.

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

just as importantly, we as developers of this utility want to be able
to add/remove/edit "configurabilities" like these in a manner that
doesn't feel like scope creep that ultimately creates a "bowl of
spaghetti" of muddied or "poorly" structured code.

futhermore still, we also decided that we wanted the idea of "adapters"
in the mix so that we aren't chained to imagemagick for image
production. (or the hypothethic possibility of using this for a
different GUI terminal client perhaps even (unimaginably) on a different
OS one day.)

as such the code here is more complicated than it "needs" to be to set
the image, but only as complicated as it needs to be to provide the
compartmentalization and configurability we are after.




## reference

  • originally inspired by (and adapted heavily from)
     [kpumuk.info] http://kpumuk.info/mac-os-x/how-to-show-ssh-host-name-on-the-iterms-background/

  • our sole references for applescript:
    + we use this older version at [gitlab] (https://gitlab.com/gnachman/iterm2/wikis/Applescript)
    + newer version at [iterm.com] (https://iterm2.com/applescript.html) (we don't use this yet)

  • our sole reference for imagemagick: [imagemagick.org] (http://www.imagemagick.org/Usage/text/)
