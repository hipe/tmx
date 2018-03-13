# installing and deploying python

## XXX

XXX does this close #open [#007.C]?


## synopsis

    cd «the root of this project»
    «install requisite version of python3 using your package manager»
    python3 -m venv my-venv
    source my-venv/bin/activate
    pip install pipenv
    pipenv install

the below will describe (in painful detail) how we arrive at the above
and what it all means.




## objective & scope: introducing versions and their management

not all our sub-projects use python, but more than one of them do.

each of these sub-projects will require a particular version of python.

(quick sidebar: as a rule, all of the sub-projects that use python must
all use the same version of python. that is, when we upgrade one
sub-project to use a newer version of python, we must upgrade all of the
sub-projects to use that new version.)

in addition to the sub-project requiring a particular version of python,
the sub-project will frequently require a particular set of python
_packages_ (external libraries). each of these packages will themselves
be expected to be at a particular version, too.

when developing and deploying alike, it becomes important to do a good job
of managing all the versions across all the various machines the
sub-project runs on. consider:

  - if there are multiple developers and they aren't all using the
    same versions of things, bad things happen.

  - likewise it’s essential that the environments for development and
    production be identical in terms of the versions of the kinds of
    things we're talking about.

managing these versions “by hand” is (at best) tedious and error-prone,
and (at worst) an unscalable show-stopper.

fortunately the python ecosystem seems to have developed a solution
for all of this. and although these tools are straightforward enough
to use, it’s all too much to remember for a novice like the author.

as such, we maintain this document as a centralized reference (think
cheatsheet) to keep our notes about exactly what we do to get the
necessary python environment set up on a new machine (be it a developer’s
machine or a production server).




## meta-roadmap and roadmap

our sequence of steps can be modeled by starting from our final objective,
then working backward from there, at each step asking: “what does it
depend on?”. we repeat this recursively until we reach the base case of a
step that itself has no prerequisite steps:

           your objective
                 |
                 V
        +-------------------+
        | all the packages  |         +--------+
        | you need (correct |-------->| pipenv |
        | versions thereof) |         +--------+
        +-------------------+             | depends
                                          V   on
                    +------+           +-----+
         depends +--| venv |<----------| pip |
           on    |  +------+  depends  +-----+
                 v              on
        +---------------------+
        | the correct version |
        | of python itself    |
        +---------------------+

this sequence in reverse order forms (vaguely) the steps  one must take
to get a new instance installed. these steps in turn create a rough
outline for the remaining sections of this document.




## what version of python are we targeting?

  - the particular version of python we are targeting lives in the last
    section of this document. (it’s  the topmost relevant entry in the
    [document meta](#document-meta) section below.)

  - terminology: for discussing version numbers we use
    the lexicon and semantics of [semver.org](http://semver.org):
    we call the components of a typical three-part version number
    `MAJOR.MINOR.PATCH`. so version `1.2.3` has a major version of `1`,
    a minor version of `2`, and a patchlevel of `3`.

  - (NOTE about a redundancy: the current python version “lives”  in this
    document, but also the python version exists semi-redundantly in the
    `Pipfile` and `Pipfile.lock` files (introduced [below](#f)).
    generally this redundancy would be a bad thing: it would be best (per
    don't-repeat-yourself (DRY)) to have exactly one authoritative place
    where this value “lives”. however, we maintain this redundancy for now
    because we want to track changes in the _patch_ number, something that
    the `Pipfile` seems disinterested in. this is all subject to change.
    (that is, we might stop keeping the version number in this document.))

  - we will generally target the latest stable of the highest major version
    of python as it exists on package managers. so:

      - e.g. at writing, python's highest major version is `3`. the
        highest stable version of _that_ seems to be `3.6` right now.
        if there's a `python4`, we haven't heard of it and/or assume it
        has no stable release yet so we don't target it. so we target
        `3.6` right now. (again, we're using this target version only
        as an example.)

      - (at writing we don’t exactly know what python’s version numbering
        conventions are vis-à-vis stabile releases..)

  - assume we develop/deploy on a variety of operating systems/distros.
    (we do.) as offered above, “bad things happen” unless we use the same
    versions of things across the machines.
    so, we want the same major and minor version of python across the
    machines. (as for the patch level, we can try to enforce that as a
    uniform thing across machines if it ever matters,
    but for now we’ll allow ourselves fudge-room here to say that, for
    example, version `1.2.3` and `1.2.4` _can_ co-exist among different
    developers’ machines MAYBE..)

  - as new stable versions of python percolate out into the world, they
    don’t all become available to all distros/OS’s (as a package) at the
    same instant. so note these criteria become competing objectives: we
    can’t get the latest stable on each of our machines until we are able
    to get it on all of our machines (a tautology).

  - (in the weeds: there may be times where we are “held back” by a
    “caboose” distro that gets a package for the latest stable later than
    other distros do. as possible and when necessary, we can compile from
    source towards getting a latest stable for such a caboose; however,
    keeping our machines on the same version should ultimately take
    precedence over having the latest stable. but this whole point might be
    a distraction: generally the latest stable should become available to
    all our platforms probably within a few days of each other.)




## <a name='d'></a>getting the necessary version of python installed

  - this is a thing you have to do probably once per development machine,
    and once again each time the python version experiences a bump.
    (we have yet to see the idiomatic way to handle this..)

  - on OS X we used homebrew (`brew`) to install the latest stable version
    of python 3..  see if you can use your package manager to get installed
    the [target version](#document-meta) of python.

  - the rest of this document is written assuming that after the above,
    the python interpreter installed by the above is reachable as `python3`
    from the command line. (for us `python3` resolves to
    `/usr/local/bin/python3`.)




## <a name='e'></a>setting up the virtual environment (the directory itself)

  - this is a thing you will have to do perhaps once per development
    “tree” (that is, project directory on your filesystem). vaguely this
    means you will have to do this once every time you `git clone` the
    repository. (but you won’t have to do it every time you hop around
    to different versions of the project itself, probably..)

  - we’ll assume you have a rough idea of what [virtual environments][venvs] are.
    for our purpose they are a way we can have specific versions of
    everything (including python) per project (that is, for a particular
    directory). this way you can have different projects that use different
    versions of python and develop them all relatively painlessly on the
    same machine. likewise you can have different projects that each use
    their own particular versions of python packages.

  - our virtual environment will “know” what particular version of python
    it was created with. so when we say `python3` below we mean for it to
    point to the correct version of python per the [above section](#d).

    so from the root of this project:

        python3 -m venv my-venv

    this tells python to load the module `venv` and then (fortunately)
    that module magically knows what to do with the last argument: it
    makes a virtual environment (a directory) called `my-venv`.

    about the name “my-venv”:

      - the name is mostly arbitrary.

      - however, (obvious or not) it should be a valid simple directory
        name that doesn’t collide with any other toplevel directory names
        in our project.

      - although canonic examples do, we didn’t call our virtual
        environment “venv”. we avoid this name to avoid confusion with the
        python module of the same name. (this point is certainly subject to
        change — we might change this so it uses the canonic choice of name
        “venv”.)

      - note we add a line in the `.gitignore` corresponding to this
        virtual environment (directory) name. this is because we don't want
        to track this whole directory in version control; and we don't want
        to be reminded continually of the fact that it’s not tracked. (we
        _do_ however keep the `Pipfile`s in version control.)

  - (sidebar: if you’re looking for a mention of `pyvenv`, you won’t find
    it here. `pyvenv` (whatever that is) happened to become deprecated at
    the very version of python we started from (near
    [#history-A.1](#history-A.1)).)




## <a name='f'></a>pipenv frop pip

(everything in this section is culled from the thoughtbot blog [here][thoughtbot_1].)

in the [section above](#e), we created our virtual environment (a directory
tree) but we didn’t activate it. activate it now:

    source my-venv/bin/activate

(the command you use to activate your virtual environment will depend on
your shell. the above is what you use for for `bash`/`zsh` (as found on OS X
and linux). if you have a weird shell, see (again) the
[python documention about virtual environments][venvs] near “zsh”.)

having done this, now when we take steps to install packages (etc) for our
project, information about these packages (if not the packages themselves)
will go into our (project-specific) `my-venv` directory.

to install `pipenv` we will use `pip`. (explaining either of these is
outside of our scope and in fact outside of our current understanding.)

`pip`, it seems, is now a part of the python standard distribution, so
we already have it.

if you run:

    which pip

you should see that the `pip` we will use is one that “lives” in our
virtual environment (directory). (if you’re not seeing that, something
is wrong and you should just give up.)

now that we have `pip` we install `pipenv`:

    pip install pipenv

(reminder: be in the root of the project directory.)
what will happen now?

    pipenv install

NOTE what we see from the above will vary based on whether there was
already a `Pipfile.lock` file or not..




## (adding a package)

(here is how we add a new package to the Pipfile)

    pipenv install foo-fah




[thoughtbot_1]: https://robots.thoughtbot.com/how-to-manage-your-python-projects-with-pipenv
[venvs]: https://docs.python.org/3/library/venv.html




## <a name='document-meta'></a>document-meta

  - <a name='history-A.1'></a>#history-A.1: upgrade from python `3.6.4` to `3.6.4_3`
  - #born.
