---
title: installing and deploying python
date: 2018-03-08T13:22:09-05:00
---

# Objective, Scope & History

The current significance of this document is that it .. documents exactly
what we did (to the best of our records) to get our Ubuntu workstation
(laptop) tuned to our developer's muscle-memory, starting "from scratch"
on a clean install (Pop!\_OS 21.10 on a System76 Galago Pro, what we refer
to more generically as "Ubuntu" below).

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

Setting up a new system mostly involves:
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
rarely-used but prominently placed "Caps Lock" key to instead serve as
another "Ctrl" key. We do this and find it useful.

To make this change, follow these (ask ubuntu instructions)[clctrl]).

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


## (Historical Note)

We used to use "oh-my-zsh" but we opted not to this time because it overloaded
our alias space and more generally our cognitive space: it did so much stuff
"for free" that we had no idea where zsh ended and the plugins began.

This time (experimentally) we want to cherry-pick those things from
oh-my-zsh that we wish we (again) had, and write them "by hand" into our
dotfiles.


# Setting up `vim`

Which text editor a developer uses is probably some combination of
of the following:

- A matter of personal (circumstantial) history:
  "I use VSCode because I used to use TextMate and so its GUI-nature
  is more familiar to me." Or: "I use vim not emacs because vim is what
  I learned first."

- A matter of personal philosophy:
  "I use emacs (not vim) because it's more powerful (I can watch youtubes
  in one of my split-window panes). Also, Richard M Stallman is a personal
  friend of mine. And, 'free' as in 'freedom'."

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

The next two sections correspond to these two aspects (in the opposite
order of above, because the config file references plugin things).

Formally, these instructions document our recent experience on Ubuntu,
but as far as we remember, these instructions "should" work for OS X as well
(because all we were doing was trying to mimic our old OS X environment
on our new Ubuntu machine).

Because config in the config file will refer back to installed plugins,
we'll do the plugins first before we look at the config.


## The `vim` plugins

EDIT order in terms of perceived primacy (i.e., the order is meaningless)

INstallation generally EDIT

1. (nerdtree)[nt1]: as directed but `plugins` not `vendor`
1. (mru)[mru1]: as directed but `plugins` not `downloads`
1. (ctrlp)[ctrlp1]: dead link there but install is straightforward. maybe not used much
1. (fugitive)[fug1]: as directed but `plugins` not `tpope`
1. (gitgutter)[gg1]: as directed but `plugins` not `airblade`

[ctrlp1]: https://github.com/kien/ctrlp.vim
[gg1]: https://github.com/airblade/vim-gitgutter
[fug1]: https://github.com/tpope/vim-fugitive
[mru1]: https://github.com/yegappan/mru
[nt1]: https://github.com/preservim/nerdtree


## The `.vimrc`

We "install" the `.vimrc` as provided by our "dotfiles" sub-project (see).

We let our `.vimrc` "live" in this sub-project to ease the pain of future
development machine migrations.


# have correct python version (once per version per system)

The requisite python version lives in .python-version.

The following sections will guide us through how we get
this version of python installed.



## have "pip" somehow

On Ubuntu, we did:

```bash
sudo apt install python3-pip
```

On OS X, we don't remember how we got it or if it was pre-installed.



## install pyenv (once per system)

    curl https://pyenv.run | bash
    # (above worked on OSX and Ubuntu)
    # (also worked:) brew upgrade pyenv

EDIT the remainder of this section to reflect dotfiles

Add to ~/.zshrc

    export PATH="$HOME/.pyenv/bin:$PATH"
    eval "$(pyenv init -)"

Restart shell:

    exec "$SHELL"



## to see what python version(s) pyenv has installed:

    pyenv local



## to see if newer python versions exist in the world:

    pyenv install --list



## (debian: we had do to this to install the requisite python at writing)

(from [here][here]:)

    sudo apt-get install make build-essential libssl-dev zlib1g-dev libbz2-dev \
        libreadline-dev libsqlite3-dev wget curl llvm libncursesw5-dev xz-utils \
        tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev



## build target python version (once per version per system)

    pyenv install 3.10.1  # might take 5 minutes
    pyenv local 3.10.1  # writes .python-version
    py -V  # confirm this says the right version (uses aliases in README.md)



# virtual environment stuff

EDIT change this section to reflect pyenv-virtualenv


## create your virtualenv (once per project directory)

    virtualenv --python=python3 my-venv



## enter your virtualenv (once per work session (terminal))

    source my-venv/bin/activate



## one per virtual environment per (set of dependencies)

    pip install -r requirements.txt


(or, if you have just experimentally upgraded your python version, pray:)

    pip install --upgrade -r requirements.txt

(☝️ this takes some time, like at least 5 minutes)



# Other ancillaries and auxiliaries

All of this is for Ubuntu for now.

If you want to view the GraphViz dotfiles generated by some sub-projects,

```bash
sudo apt install xdot
```

We don't remember why we needed these (but we seem to have):

```bash
sudo apt install gnome-tweak-tool
```


[clctrl]: https://askubuntu.com/questions/33773/how-do-i-remap-the-caps-lock-and-ctrl-keys
[here]: https://github.com/pyenv/pyenv/wiki#suggested-build-environment
[pyenv1]: https://github.com/pyenv/pyenv
[this_page]: https://github.com/googleapis/google-api-python-client
[zsh1]: https://scriptingosx.com/2019/07/moving-to-zsh-06-customizing-the-zsh-prompt/
[zsh2]: https://askubuntu.com/questions/131823/how-to-make-zsh-the-default-shell


## <a name='document-meta'></a>document-meta

  - #history-A.4
  - #history-A.3: virtualenv & pip, not poetry
  - #history-A.2: upgrade to 3.8.0. poetry not pipenv. sunset lots of configs
  - <a name='history-A.1'></a>#history-A.1: upgrade from python `3.6.4` to `3.6.4_3`
  - #born.
