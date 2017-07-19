# mountable standalone scripts and related :[#020]

## what is *a* "tmx"? :[#here.B]

at its essence "tmx" is nothing more than an automagic bundling of other
facilities.

if a gem wants itself to be exposed thru tmx, at least three things must
be true:

  1) the gem must be installed, and installed in the "main" gem
     directory (whatever `Gem.paths.home` points to).

  2) the gem's name must have a particular prefix (for now, "skylab-").

  3) the gem must have one or more executables in its `bin` directory
     that have the prefix "tmx-".
     (this may have changed somewhat..)

the bulk of the implementation here is just jumping thru hoops to make
a CLI client that "mounts" the remote sidesystems as if they were
reactive nodes in our own model.




## theory at a higher level: intro to different kinds of scripts ~:[#here.c]

at writing the general obsession of the tmx ecosystem is with
"microservice frameworks", with any eye towards weird interface
experiments.

however there are certainly times when we just want to write a
plain old standalone script that isn't at all "frameworky", and has no
dependencies except the platform language.

  - one perfect use-case for this is the installation scripts
    that install tmx itself, in [sli]

for the smallest of these efforts that get versioned, we typically
put them in a `scripts/` directory immediately under the
sidesystem directory.

if for some reason we think that the effort is something we might
want to re-use with any frequency, we then typically put the standalone
script in a `bin/` directory, so rubygems puts a stub for the script
in a bin directory so that the script is accessible from "anywhere"
(for definitions of).

  - these scripts almost always start with "tmx-", so that (in part)
    we play nice with the namespace, or more specifically that we
    trample on the namespace on a normal way.)

  - the `bin/` directory holds the entrypoint executable files for
    the big applications, but that's not the focus of this article.

for our purposes here, we'll call these efforts "standalone scripts".




## "moutable standalone" scripts ~:[#here.d]

for a further twist on this idea, we experiment with allowing these
standalone scripts to be "mounted" usually by their nearby big
applications of their host sidesystem. this simply means that the
scripts get to appear in the giant tree of endpoints as it is expressed
by the UI, alongside (or nearby) the application's operations.




## this tag :[#here.5]

the experiment of mountable standalone scripts requires that the
script "know" whether it is being *invoked* or merely just loaded.

(it's debatable whether this is a smell. when a script gets to
this point it might be a good time to make it a library file. the
cost to this, however, is that it looses the independence and
resilience of being a standalone script..)

anyway, the canonic way to determine if a script was invoked or
merely just loaded is

    if __FILE__ == $PROGRAM_NAME
      # ..

however, when we employ the [#sli-161.4] symlinks trick for development
(which we always do for development), those two paths are the same only
at the last two elements (e.g `bin/tmx-foo`).

our workaround for this (*for now*) is to check only the last component
of the path is the same, but DO NOTE that this implicitly creates the
requirement that the *basename* of every mountable standalone executable
be universally unique in the context of the whole tmx ecosystem. whew!

this is one (but not the only) good justification for the fact that
every such executable under a sidesystem called `wiz_bang` will have names
like `tmx-wiz-bang-frobulate`, etc.

but anyway, the main point of all this is that since we can't DRY up this
code in a true standalone script (because we can't rely on our own pre-
existing functions), this tag tracks the code that implements this somewhat
shaky decision.
