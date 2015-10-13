# "tmx" installation

## installation on OSX

in a treatment that is perhaps too broad and too narrow at the same
time, the end of this section is an outline detailing exactly how we get
a development system up and running "from scratch" on a system with
nothing but an OS (in theory).

First, some caveats:

  • here we do not cover getting our editors/IDE's set up.

  • one day it would be nice to use something like boxen for these
    instructions, so do not get too attached to them :P

  • today we are installing from an OS X Yostemite (10.10.5)

Here's the outline:

  1) we will use homebrew for the next step. if you have not installed
     it before now, install it per http://brew.sh which takes around
     2 minutes.

  2) to manage different versions of ruby we will use `chruby`

    • we chose `chruby` over `rbenv` and `rvm` because of the compelling
      manifesto at [zaiste.net][].

    • per the instructions there, having done `brew install chruby` we
      add the two lines to our (in our case) .zshrc

    this whole thing takes only a few minutes.

  3) as the author of `chruby` does, we build the ruby we want
     with `ruby-install`:

    • per https://github.com/sstephenson/ruby-build, follow
        "Installing as a standalone program (advanced)" (about 70 seconds)

      • (using brew to install this might have worked too)

    • to install openssl and ruby in this manner takes under 7 minutes:
        mkdir ~/.rubies
        ruby-build 2.2.3 ~/.rubies/ruby-2.2.3

    • to have this new ruby appear in the list of rubies (output by the
      `chruby` command alone), I had to open a new shell after the above
      was completed.

   4) now that our requisite ruby is installed, when we `cd` into
      the top directory of this project, the `.ruby-version` file is
      seen and the correct ruby version is activated (whew!). do this.

      with that done, we need to install the requisite gems thru bundler:

      • we had to do this, we don't know when we should have done it:

        `gem update --system`

        (per [this nokogiri note][])

      • `gem install bundler` - takes under a minute.

      • `bundle`

  [zaiste.net]: http://zaiste.net/2013/04/towards_simplicity_from_rbenv_to_chruby/ zaiste.net

  [this nokogiri note]: http://www.nokogiri.org/tutorials/installing_nokogiri.html#mac_os_x  this nokogiri note




### other useful tools on OSX

although not a part of tmx per se, we exploit this space here to remind
ourselves of these softwares we can't do without:

  • ack - `brew install ack`

  • gitx

  • macvim
    • "janus" for same
    • .vimrc.before, .vimrc.after, .gvimrc.after (#todo)





## testing (too much detail)

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

we make these "chunks" by grouping particular lists of sidesystems together
and running those chunks one at a time (currently 2 chunks). these
chunks are listed in GREENLIST.txt.

try:

    ./script/test-all -h
_
