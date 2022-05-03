---
title: installing and deploying python
date: 2018-03-08T13:22:09-05:00
---

# Objective of this document

Setting up a new machine "should be easy", but in fact a developer spends
years and decades building up muscle memory for many dozens of utilities
and configurations that they may very well take for granted until the time
comes that they find themselves on a new machine they have to set up from
scratch as a development workstation (possibly even on a new operating
system yikes!).

(For posterity, we have [#018.3] a rough flowchart and [#018.4] a timesheet
that we used to guide this effort and track the project. To look at the
commit dates around this time, you can see that this timesheet alone does
not reflect the full amount of effort that was expended to this end.)


# Scope & History of this document

The current significance of this document is that it .. documents exactly
what we did (to the best of our records) to get our Ubuntu workstation
(laptop) tuned to our developer's muscle-memory, starting "from scratch"
on a clean install (Pop!\_OS 21.10 on a System76 Galago Pro, what we refer
below more generically as "Ubuntu").

More specifically, at #history-A.4 the scope of this document changed in
these two ways:

- The scope of this document broadened such that it now covers "setting up a
  new development environment (laptop) from scratch" (as opposed to just
  "setting up a python environment"); however:
- The scope of this document _shifted_ from targeting OS X to targeting
  Ubuntu (for reasons that are circumstantial but also welcome: the
  author's old laptop died and his friend donated to him a Linux laptop,
  forcing the author to get comfortable on Linux for development).

If we ever realize the grand vision of unifying this mono-repo with its
predecessor mono-repo, we will break this out into a triangle-like triad
of documents; something like:

                           [setting up the shell]
                                    |
                                    v
                          [setting up your editor]
                                    ^
                                  /   \
                                 v     v
                [setting up python]   [setting up ruby]

But while we are a single developer on a single machine, we will continue
to keep this documentation as small-and-dense as we can.

On that topic, we should always prefer configuration over documentation.
This is to say, we would rather keep our config in version control (to
whatever extent possible) than have to rely on lengthy narrative explanations
of a whole bunch of lines that are required to type in.

(Documentation *of* the configuration is probably great too.) Ideally this
file would be a small, sequential series of pointers to our own install
scripts and similar.


# What order to set things up in

Setting up a new system involves mostly:
1. typing (or pasting) things into a shell to install packages and
1. typing (or otherwise installing) config info in config files

For some steps, we can't decide what the best order is. (For example,
we can't decide whether it makes more sense to set up your shell
before or after setting up your editor. We chose shell because it
"feels" lower-level.)

But for other steps, particular orders make more sense:
It makes sense to set up your shell and editor before setting up
your development platform environment (e.g., python), so that you
are able to type things from the shell comfortably and troubleshoot
failing tests as you encounter them.

So we'll start with one operating-system-wide change, then we'll set up
the shell, then our editor, then our development runtime.


# First, one operating-system-wide keyboard mapping

We type the "Ctrl" key a lot (in combination with other keys).

It's apparently a common thing for Linux users to change the
rarely-used but prominently-placed "Caps Lock" key to instead serve as
another "Ctrl" key. We do this and find it useful.

To make this change on Ubuntu, follow these (ask ubuntu instructions)[clctrl]).

(We made this change on OS X before, but didn't document it.)

Now we can go on to setting up our shell.


# Setting up `zsh` as your shell

`zsh` is not strictly necessary to develop or run this project; but `zsh`
is what our versioned config files target and it's well outside of our
interests to broaden the surface area of this target space.

(We personally prefer `zsh` over `bash` just for the input buffer shortcuts
it has for recalling specific tokens from history.)

If you prefer your own favorite shell to `zsh` then do what is necessary
to get `pyenv` and `virtualenv` working there. (The documentation for
`pyenv` describes how to do config for some different shells.)

The below is what we did to change our shell to `zsh` on Ubuntu. We don't
remember what we did on OS X to change the shell to `zsh` (but we did
something. It sounds like maybe OS X will change to make `zsh` the default
if it hasn't already).

First,

```bash
sudo apt install zsh
```

Then from (this askubutu question)[zsh2], we did:

```bash
chsh -s $(which zsh)
```

(We don't remember if this was exactly what we did; but changing shells
is a well-documented topic.)


## Configuring your zsh

We now keep our zsh configuration files in version control and we
now have a dedicated sub-project for this ("dotfiles").

Every line in the versioned zsh configuration files corresponds to
a commit that explains what the line does and why we use that configuration.

Please see that sub-project.


## ("oh-my-zsh": A historical footnote)

We used to use "oh-my-zsh" but we opted not to this time because it overloaded
our alias space and more generally our cognitive space: it did so much stuff
"for free" that we had no idea where zsh ended and the plugins began.

This time (experimentally) we want to cherry-pick those things from
oh-my-zsh that we wish we (again) had, and write them "by hand" into our
dotfiles.

(After writing this, we discovered that [this blog][zsh3] feels the same way.)


## A Terminal Nicety: xsel or xclip or pbcopy

It's nice to be able to pipe text into the clipboard from the terminal so
you can paste it anywhere. Currently, we use `xsel` for this:

```bash
sudo apt-get install xsel
```

Then get something into the clipboard with:

```bash
echo "foo" | xsel -ib
```

(On OS X the comparable executable is "pbcopy".)

(We chose `xsel` over `xcopy` only because the equivalent command
is shorter in `xsel`. `xcopy` supposedly has some benefits over `xsel`.)


# Setting up `vim`

Which text editor a developer uses is probably some combination of
of the following:

- A matter of personal (circumstantial) history:
  "I use VSCode because I used to use TextMate and so its GUI-nature
  is more familiar to me." Or: "I use vim not emacs because vim is what
  I learned first."

- A matter of personal philosophy:
  "I use only FOSS editors because 'free' as in 'freedom'." Or:
  "I use emacs (not vim) because it's more powerful (I can watch youtubes
  in one of my split-window panes). Also, Richard M Stallman is a personal
  friend of mine."

- A matter of certain IDE's being de-facto required for the particular
  kind of development: Android Studio for android, XCode for iPhone,
  Unity for Unity; etc.

Certainly to develop for the sub-projects of this mono-repo; a particular
one editor isn't required, as long as the code produced conforms to
the code-conventions suggested by the particular sub-project.

But as it works out, a lot of this project's code is plain-old scripting
language and the author happened to use a plain-old editor: `vim`.

So, while you absolutely don't have to use `vim` to develop for this,
here we document how we installed and customized _our_ `vim` just so
we have it written down somewhere so we don't have to (again) have our
configuration trickle in over weeks and months of discovering
muscle-memories with missing referrents.

The configuration of a `vim` consits entirely of:

1. the config as written in the `.vimrc` file and
1. what plugins are installed (plugins are just directories in a directory)

(There are more complicated ways to do config involving multiple files,
but fortunately we don't need or use such a config architecture yet.)

Since the config file contains (among other things) plugin-related
configuration, below we cover installation of the plugins first before
we go over what's in the config file.

Formally, these instructions document our recent experience on Ubuntu,
but as far as we remember, these instructions "should" work for OS X as well
(because all we were doing was trying to mimic our old OS X environment
on our new Ubuntu machine).


## The `vim` plugins

Because of vim's new-ish plugin architecture, the installation of most vim
plugins is relatively straightforward: it involves simply doing a git
checkout into a particular directory.

The linked-to instructions below will all be variations on this theme.

Generally you will do the below installation instructions from the
arbitrary directory we have chosen to hold our vim plugins, so make that
directory and go into it now:

```bash
mkdir -p ~/.vim/pack/plugins/start
cd ~/.vim/pack/plugins/start/
```

These are in order of our personal perception of their primacy (which is
mostly meaningless):

1. (nerdtree)[nt1]: as directed but `plugins` not `vendor`
1. (mru)[mru1]: as directed but `plugins` not `downloads`
1. (ctrlp)[ctrlp1]: dead link there but install is straightforward. maybe not used much
1. (fugitive)[fug1]: as directed but `plugins` not `tpope`
1. (gitgutter)[gg1]: as directed but `plugins` not `airblade`

A bit more involved is installing the vim plugins for `coc.nvim` and
"ag, the silver searcher" (and their dependencies) so those have their
own sections next.


## `vim` plugin: `coc.nvim`

To get autocomplete, we chose this plugin as a workaround for whataver plugin
we used to use (we don't remember). This one requires node:

```bash
sudo apt-get install nodejs
```

which gave us:

```bash
$ nodejs --version
v12.22.9
```

Then follow the (coc.nvim)[coc1] instructions as directed but use
`plugins` not `coc`


## `vim` plugin: `ag`

Per (its installation instructions)[ag1],

```bash
sudo apt-get install silversearcher-ag
```

(The rest is not documented but it was straightforward.)


[ag1]: https://github.com/ggreer/the_silver_searcher
[coc1]: https://github.com/neoclide/coc.nvim/wiki/Install-coc.nvim
[ctrlp1]: https://github.com/kien/ctrlp.vim
[gg1]: https://github.com/airblade/vim-gitgutter
[fug1]: https://github.com/tpope/vim-fugitive
[mru1]: https://github.com/yegappan/mru
[nt1]: https://github.com/preservim/nerdtree


## The `.vimrc`

We house our `.vimrc` in version control with the (correct) assumption
that we will want changes to our vim config to travel with us easily
from machine to machine, in "both" directions: (one) we want to be able
to "pull" the config from the "cloud" on to a new machine, and (two)
as we employ new config settings, we want to be able to "push" those
changes up to the cloud to more easily keep our desired config synced
across machines.

To this end, you can install a `.vimrc` on to a new machine using
the installer script at the "dotfiles" sub-project (see). (If you don't
like the sound or feel of this, please note it simply makes a symlink
to a config file that's in version control.)


# Installing the requisite python environment

In order to reach the correct version of python and the necessary
packages, we use `pyenv` to employ virtual environments. How we do so
is covered in the following sections. Typically you only have to do this
once per machine, and then parts of it again as the requisite python
version changes, or requisite package versions change or packages are
added or removed.

To manage our own sanity in documenting this, we created [#018.2]
this flowchart, which may come in handy to refer to as you read this,
because the flowchart served as the outline this documentation was
built around.


## Is pyenv installed?

On a brand new system, `pyenv` probably isn't already installed.

You can check if it is installed (correctly) with:

```bash
which pyenv
```

To install it, follow [their instructions][pyenv1]; which is basically just
doing a git checkout into a certain directory and adding lines to your
`.zshrc` or `.bashrc` or similar to alter your `PATH` (more on this below).

Duplicating those instructions at writing, this was:

```bash
git clone https://github.com/pyenv/pyenv.git ~/.pyenv
```

(At #history-B.1 we removed instructions for how we had originally installed
it on OS X, assuming that the above instructions are more up-to-date
than the curl-pipe-to-bash way.)

We let the "dotfiles" sub-project house the `.zshrc` file we use.

If you set up your `zsh` as described above, then your `.zshrc` should
have some lines something like:

```bash
eval $(pyenv init --path)
eval $(pyenv init -)
```

(At writing, the above is producing some syntax errors,
but still appears to work.)

After this and restarting your shell (`exec "$SHELL"`), you should
be able to see that pyenv is installed with the above check.


## Is the requisite python version built?

On a new machine, you will have to build the requisite version of python once.
(More precisely, you will have to build a python once per machine per requisite
version of python.)

The requisite version of python is expressed within the contents of the
`.python-version` file at the root of the mono-repo. (At #history-B.1 the
contents of this file changed from being _the_ requisite python version,
to being an arbitrary name that _contains_ the requisite python version.)


### To see what local python version(s) pyenv already knows about:

```bash
pyenv local
```

On a brand new machine, the outputted list would be empty.


### To see what python versions are available in the world:

You may want to do this if you don't see the requisite python version
on this machine, and you want to confirm that it's a python version that
exists out in the world.

Also you  may want to check to check if there's a python version newer than
the one you're currently targeting. (But NOTE that targeting a new python
version can take a nontrivial amount of work, to handle breaking changes
it introduces (especially to our depended packages, but maybe to our own
code too).

```bash
pyenv install --list
```

This will output a long list of available versions.


## To build a version of python

Again, you should only need to do this once per machine per python version.

(On our Debian, we also had to install these, per [here][here]:)

```bash
sudo apt-get install make build-essential libssl-dev zlib1g-dev libbz2-dev \
    libreadline-dev libsqlite3-dev wget curl llvm libncursesw5-dev xz-utils \
    tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
```

Build the requisite python version:

```bash
pyenv install 3.10.1
```

This took about 5 minutes on our machine the last time we did it.

Below, we will create a virtual environment that uses this install
of python and confirm that we can reach it.


## Is `pyenv-virtualenv` installed?

As far as we can tell, pyenv-virtualenv is now distributed with pyenv,
so if you've been following along, it should be installed by now.

But, to check:

```bash
pyenv virtualenv --help
```

In case we're wrong (and you need to install it),
the instructions of the (pyenv-virtualenv)[pvenv1] docs are something like:


```bash
cd "$(pyenv root)
git clone https://github.com/pyenv/pyenv-virtualenv.git
```

A line like this should already be in your `.zshrc` if you installed it
with our "dotfiles" sub-project as describe above:

```bash
eval $(pyenv virtualenv-init -)
```

## Is the requisite virtual environment created?

The contents of the `.python-version` file consist entirely of the
virtual environment name, which is arbitrary. (This has changed from
what it was before (just the python version) at #history-B.1, as mentioned
above.)

We need to create a virtual environment that points to our requisite
version of python (built above).

To see a list of the virtual environments that pyenv knows about on this
machine:

```bash
pyenv virtualenvs
```

This should output nothing on a new machine. If it's a new machine,
or you're upgrading versions of python or otherwise troubleshooting
some package issues; the next two sections will guide you through
creating (and deleting) virtual environments.


## (To delete an existing virtual environment)

This may come in handy during development, if you're trying to start
from scratch (to rebuild from nothing, because requirements are broken
after an upgrade, for example), or maybe you just want to change the name.

```bash
pyenv virtualenv-delete <virtual-environment-name>
```

It will ask you to confirm this. To confirm it, enter `y`.

(See also a script in the "dotfiles" sub-project for clearing out your
virtual environment of packages.)


## To create the requisite virtual environment

Now that we have the requisite python version built (above), we create
a virtual environment that corresponds to the requisite build of python.

(See also a script in the "dotfiles" sub-project, which does what is
covered in this section in a more scripted way.)

The command we will issue consists of four tokens:

```bash
pyenv virtualenv <python-version> <virtual-environment-name>
```

The third token is the requisite version of python. The fourth token is
an arbitrary name we chose for the virtual environment. Although we
keep saying that the name is "arbitrary", what name you choose here
is significant:

If you're simply creating a virtual environment to correspond to the
one in the `.python-version` file (for example, on a new machine),
then use the virtual environment name exactly as it appears in that
file for the virtual environment name in the command you issue here. Once
you finish this section, *skip the next section*, instead go directly to
the section after that.

Otherwise, you're probably trying to upgrade the python version on your
development tree. After you complete this section, continue to the next one.
In such a case, chose a name for your virtual environment that has the
requisite python version.

Issue the command (with the appropriate virtual environment name) now:

```bash
pyenv virtualenv 3.10.1 my-main-venv-3.10.1

```

(This takes maybe 4 seconds to complete on the current machine.)

(At #history-B.1 we stopped using the `virtualenv` command directly.)

If we run the same command from the previous section to see the
virtual environments pyenv knows about, you will now see this name
you chose in the output.

Now either continue to the next section or the section after that
as appropriate.


## To update the virtual environment string in `.python-version`

We want the string in `.python-version` to match exactly our virtual
environment name. (In effect, the string in that file is what "selects"
our virtual environment.)

If you're attempting to upgrade your python version, you will need to
change the string in `.python-version` to match exactly the name of your
new virtual environment.

The end-result of this command is simply to overwrite the string
in that file. But it has the additional added benefit of validating
that the name you enter corresponds to an existing virtual environment.

```bash
pyenv local my-main-venv-3.10.1
```

(We last did this in (#history-B.1).)

Now, we want to confirm that our new virtual environment is active.


## To confirm that the requisite virtual environment is active

To confirm that your virtual environment is activated (accomplished by
the previous section), you can do:

```bash
which python3
```

It should say something about "../.pyenv/shims..". If it does not,

1. Ensure that you are in a directory that has the `.python-version`
   file in it (the mono-repo directory).
1. Review review the last section again, and read the vendor documentation more
   closely, because it may have changed since we last updated this document.

With this done, we can now install our required python packages as necessary
which we cover in the following sections.


## have "pip" somehow

At writing, the "pip" we have now comes along with the virtual envrionment
when we activate it. So if you have followed the instructions so far,
doing `which pip` should now show the same kind of path as `which python3`,
that is, one from the `../shims/..` directory.

(We archived how we used to get "pip" at #history-B.1)

You may, however, want to check for updates:

```bash
pip install --upgrade pip
```


## To install the mono-repo's requirements with `pip`

    pip install -r requirements.txt


(or, if you have just experimentally upgraded your python version, pray:)

    pip install --upgrade -r requirements.txt

(☝️ this takes some time, like at least 5 minutes)


## (To see what versions of a package are available in the world)

```bash
pip index versions pelican
```

(where "pelican" is the name of the package)

(note this became available only in a recent version of pip at writing)

(from [here][here])


## (To see what dependencies a package brings with it)

Current pip at writing does not do this elegantly.
See this [stack overflow post][pip1].


# Other Niceties

## A Development must-have: ssh keys

```bash
ssh-keygen
```

Accept the defaults (unless you want a passphrase). That's it!

You'll probably want to get a copy of your public key in your clipboard
at some point. Using `xsel` that we installed above (Ubuntu):

```bash
cat ~/.ssh/id_rsa.pub | xsel -ib
```
Now it's in your clipboard.


## A Development Nicety: GraphViz for viewing "\*.dot" files

There are dozens of GraphViz files ("\*.dot") spread throughout the
documentation of the sub-projects. Some of our libraries _generate_
GraphViz files from other sources (like "pho-issues" which can generate
dependency graphs from collections of issues).

To view these files, we use GraphViz, available on OS X and Linux.

On Ubuntu:

```bash
sudo apt install xdot
```

(On OS X we installed it with their installer, and got a binary called
`dot` somehow.)

Then to open (on Ubuntu):

```bash
xdot <file.dot>
```

Or (when everything is aligned correctly) (Ubuntu and OS X) simply:

```bash
open <file.dot>
```


## A General Nicety: GNU recutils

In development at writing, the "kiss-rdb" sub-project has an adapter
for reading files like this. We may use this format to hold certain
kinds of structured notes.

(At #history-B.2 we added a command-line script that needs it.)

The [documentation][recu1] doesn't say so, but there is a package for
Ubuntu. (We got this installed straightforwardly somehow on OS X too).

```bash
sudo apt-get install recutils
```

Now you can use the executable `recsel` (for example) on a file marked "\*.rec".


[recu1]: https://www.gnu.org/software/recutils/


## A Development Nicety: patchutils

We use a tool in this library only rarely, but when we need it we're glad
we have it.

```bash
sudo apt-get install patchutils
```

From this library, we use `splitdiff` which breaks up a larger patchfile
into smaller patchfiles, one for each file the patch patches.

We find this technique useful in cases close to the use cases of "git stash"
or a branch, but your work is nicely contained in one patchfile and you are
willing to let it drift from its parent commit for whatever reason (for
example because lots of development has gone on since doing this work, so
you anticipate you will have to do lots of work to re-integrate the patch).

Working with a series of relatively small patch-files can facilitate a
divide-and-conquer approach to a large integration in a manner that can be
less cumbersome and awkward than when trying to do the equivalent by
resolving lots and lots of merge conflicts in the usual way.


## Other Niceties

We don't remember why we needed this (but we seem to have):

```bash
sudo apt install gnome-tweak-tool
```

[clctrl]: https://askubuntu.com/questions/33773/how-do-i-remap-the-caps-lock-and-ctrl-keys
[here]: https://github.com/pyenv/pyenv/wiki#suggested-build-environment
[pip1]: https://stackoverflow.com/questions/11147667/is-there-a-way-to-list-pip-dependencies-requirements
[pvenv1]: https://github.com/pyenv/pyenv-virtualenv
[pyenv1]: https://github.com/pyenv/pyenv
[this_page]: https://github.com/googleapis/google-api-python-client
[zsh1]: https://scriptingosx.com/2019/07/moving-to-zsh-06-customizing-the-zsh-prompt/
[zsh2]: https://askubuntu.com/questions/131823/how-to-make-zsh-the-default-shell
[zsh3]: https://dev.to/rossijonas/how-to-set-up-history-based-autocompletion-in-zsh-k7o


## <a name='document-meta'></a>document-meta

  - #history-B.2: begin cap-server which needs recutils
  - #history-B.1: pyenv virtualenv not just virtualenv
  - #history-A.4
  - #history-A.3: virtualenv & pip, not poetry
  - #history-A.2: upgrade to 3.8.0. poetry not pipenv. sunset lots of configs
  - <a name='history-A.1'></a>#history-A.1: upgrade from python `3.6.4` to `3.6.4_3`
  - #born.
