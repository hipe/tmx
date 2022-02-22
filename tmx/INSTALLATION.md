# "tmx" installation :[#002]

## overview, TL;DR

- what do we mean by installing "tmx"? [#here.b]

- installing the tmx "monolith" from a fresh checkout:

  1. install the necessary version of ruby [#here.c]

  1. use installation script that installs the essential sidesystems [#here.d]

  1. use installation script that installs the remaining (desired) sidesystems [#here.e]

  1. run tests to confirm installation is OK [#here.f]

- why don't we use bundler? [#here.g]




## what do we mean by installing "tmx"? :[#here.b]

at the moment, "tmx" is the generic term for 33-or-so related gems,
each of which can usually be categorized cleanly as either an "application"
or a library that supports these applications. so really, "tmx" itself
means nothing. (see also [#020.B] "what is *a* tmx?")

we refer to these 33 interworking gems as "sidesystems". originally, we
called them "subsystems" (borrowing the term we got from an Apple Cocoa
book), but we eventually re-named the prefix "sub-" to "side-" to emphasize
that none of these nodes is really highly subservient to any other; but
rather that we visualize them as being a flat list of libraries and are
side-by-side with each other.

for several years we have anticipated breaking these "sidesystems" up
into separate code repositories; but as yet this epochial split hasn't
ocurred. as such, we refer to the project as a "monolith" to acknowlege
that the size of this repository is not appropriate for distribution
to the outside world.

for better or worse, while this project is in its "monolith" phase there
are particular steps necessary to go from a fresh checkout to a working
installation (suited, necessarily, for develpment). the remainder of the
sections in this document cover these steps.


## New installation notes for January, 2022 (on Ubuntu) EDIT

XX Integrate this into the section that comes after it!!

Seven years later, this section contains new notes that:
- have NOT been integrated into this document yet
- DO contradict the older instructions in this document

("TMX-ruby" is such a legacy thing with mostly code-to-be-archived
that we don't bother being pretty about these instructions at the moment..)

Here in January 2022, we're experimenting with `asdf` intead of
the other options discussed here, for managing ruby versions and
virtual environments.

Per [the asdf instructions][asdf1],

```bash
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.9.0
```

The remainder of the "Installation" section describes a line to put
in your .zshrc, but at writing we have XX to the "dotfiles" sub-project
of TMX-python.

Then per [the asdf ruby instructions][asdf2], 

```bash
asdf plugin add ruby https://github.com/asdf-vm/asdf-ruby.git
```

Then

```bash
asdf install ruby VERSION
```

where VERSION is the one in `.tool-versions`.

This took about 4 minutes (give or take) on our machine at writing.



## install the necessary version of ruby [#here.c]

the details of how to install a particular version of ruby for your
particular operating system is a bit outside our scope. but here's
some notes for what you need to know, intermixed with how we did it
on our own system.

  - the ruby version that tmx expects is in `.ruby-version` file
    of the root of the project.

    - as this is a dotfile, you probably can't see it "normally"

    - to see its contents, you can from a terminal `cd` to the
      root of the project and do `cat .ruby-version`

    - from vim in a NerdTREE window, `Ctrl-i` reveals these

  - these instructions worked for us on OS X El Capitan (10.11.6)

    - recent previous tmx's worked fine on Yosemite (10.10.5)

    - if you're targeting Linux/BSD, you can likely adapt these
      instructions for your platform (e.g using `apt-get` to install
      the requisite ruby).

    - we highly doubt tmx will work on Windows, and currently have
      neither the resources or the interest to target it.

  - to install the requisite version of ruby, you may weirdly want
    to build the ruby from sources yourself, or use one of the several
    ruby version managers.

      - `rbenv` or `rvm` should work just as well, but we used `chruby`

      - athough we used both of the above in the past, we switched to
        `chruby` because it was the [simplest][zaiste.net] thing that worked.

        - following the instructions from the `chruby` website
          (or just github project page?) just worked for us.

          - we used `homebrew` to install `chruby`

            - install homebrew if you don't already have it
              using http://brew.sh (~2 minutes)

          - we did the thing where we added 2 lines to our `.zshrc`

when all this is complete, if you `cd` into the root directory of the
"monolith" and cat the `.ruby-version` file, it should be the same
version as what you see when you run `ruby -v` from within this same
directory.




[zaiste.net]: https://zaiste.net/posts/towards_simplicity_from_rbenv_to_chruby/


## other gems

When we get around to running tests we'll need these:

```bash
gem install rspec
```

(it was 3.10.2) (but ..?? XX)


## using the installation scripts

now, assuming that you have the requisite version of ruby as active
in your shell session,

  1. use installation script that installs the essential sidesystems :[#here.d]

         ./slicer/script/083-install-essential-gems -h

     reivew the above help screen, then run the command by doing the
     same thing without the `-h` option.

  1. to install the remaining sidesystems :[#here.e]

    1. make a "REDLIST" following the command suggested at the end of:

           ./slicer/script/250-reallocate-sigils -h

    1. review this help screen then run this script:

           ./slicer/script/417-install-remaining-gems -h

    1. review and run this script (YIKES):

           ./slicer/script/750-EEK-symlink-gems -h

    1. review and run the cleanup script:

           ./slicer/script/917-clean-all-gemfiles -h

    1. you can remove the "REDLIST" file, too

  1. to run tests at a macro level to confirm that the installation
     is complete, follow the techniques outlined at the end of
     this help screen:

         ./slicer/script/417-install-remaining-gems -h

     (this is a script we onced once before above.)

     this help screen is the authoritative reference on how on
     run the tests at a macro level. :[#here.f]




## for posterity, related to tests above, an introduction to "chokepoints"

the number of tests in this project ceilinged at 2796 tests in 427 spec
files before we made a concerted effort to simplify and universalize
everything.

on our typical mid-2010's development machine, running these tests all
at once takes a relatively long time (~ 78 seconds just now). this is
in excess of our self-imposed "breath" guideline (to be described
in [#ts-004] one day).

we infer that this is because the runtime reaches a "chokepoint" where
it is creating objects faster than it can de-allocate, and perhaps ends
up with memory islands, so it starts spending significanly more of its
cycles running the garbage collection routine but never releasing enough
memory to run as fast as it did in the beginning.

whatever the cause of these observed "chokepoints" is, running a
"long list" of tests takes significantly longer than it would to run them
in smaller "chunks" for some certain approximate size of "chunk". in effect
the cost of running all the tests becomes greater than the sum of the costs
of running its parts individually.

there is an ideal sweetspot where the number of chunks isn't too annoying
to run all "by hand", but still saves time over running all the tests at
once. our current such sweetspot has the total test time running at
15 seconds, which accords with our "breath" rule.

generally we make these chunks with the following approach:

  1. line up all the sidesystem names in some particular order

  2. given an "ordinal" number and a "denominator" number, run
     a particular slice of this list (for example "the first half"
     or "the sixth 10th", etc).




## sidebar: why don't we use bundler (`bundle`)? :[#here.g]

we tried folding bundler into the mix here, but concluded that at this
current moment in the tmx ecosystem's development there is little to be
gained from using it, and some nonzero cost associated with it.

  - as it stands, each sidesystem can specify the versions of the other
    sidesystems (gems) it depends on through its own `.gemspec` file. to
    place this information redudantly in a `Gemfile` is problematic, and
    to try to make the gemspec (and the building of the gem) depend on
    bundler incurs a cost of dependency to a moving API with little gain.

  - were it the case that we had multiple parallel ruby projects that
    needed different versions of gems, the above would not be the case.

  - while this is still in its "monolith" phase, we don't really have
    meaningful versions yet anyway, there's just HEAD of master, and
    every commit confirms that every sidesystem is green against every
    other in that state (the bliss of having published nothing yet).

  - bundler makes the assumption that your "project" is one gem-like
    directory from which you will do most of your work (often a rails
    application). tmx is decidedly not developed this way..

however, longer term we will need to address the above concerns so that
bundler works for us before we publish gems from this project, because
it is the case that our project requires specific versions of gems,
and bundler is the best choice to serve this need.




## other useful tools on OSX (personal notes)

although not a part of tmx per se, we exploit this space here to remind
ourselves of these softwares we can't do without:

  - ack - `brew install ack`

  - gitx

  - macvim
    - "janus" for same (or not)
    - .vimrc.before, .vimrc.after, .gvimrc.after (EDIT)




## wishlist

  - one day it would be nice to use something like boxen for these
    instructions, so do not get too attached to them :P


[asdf1]: https://asdf-vm.com/guide/getting-started.html#_1-install-dependencies
[asdf2]: https://github.com/asdf-vm/asdf-ruby


## document-meta

  - #history-A: full rewrite to explain installation scripts
    - erased note about issue with nokogiri
_
