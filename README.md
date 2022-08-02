# down town fun readme

## objective & scope

this “project” consists of several “sub-projects” whose only unifying
theme is that they are somehow of interest (maybe) to the DTF group chat.

although the sub-projects are thematically disparate from one another, we
keep them here in one repository for [reasons](#sub-projects).




## <a name=b></a>development overview

the specifics of development will be determined by the technologies
employed by the particular [sub-project](#sub-projects).

however, these principles apply across the sub-projects:

  - see the [below](#d) guidelines on version control.

  - see [installing and deploying python](#018) if yours is one of the
    several sub-projects that uses python.

  - also for python, see our [\[#010\]] extra-conventional conventions.

  - [passing all the tests](#running-all-the-tests)
    MUST generally be considered a prerequisit for pushing to the master
    branch. (we may explore allowable exceptons later.)




## overview of contents of this project

  - [`TODO.stack`](TODO.stack)
    - one line per item
    - see [[#004]](#004) using the todo stack

  - `bin/`
      - of course don't put actual binary files here. this is for
        executable files written in scripting languages.

  - `doc/`
      - typically this is for *static*, semi-human readable documents
        (like markdown, graph-viz)

      - you will need GraphViz to see the dotfiles (`*.dot`)

      - the numbered documents in this directory appear in the
        [node table](#e) below.

  - `script/`
      - this is like `bin/` but for little _development_ utilities and one-offs.

  - `static-html/`
      - as the name implies, this is for the rare _static_
        (i.e versioned, probably not generated) html

  - `«sub-project»`

  - `«sub-project» (etc)`




## <a name="sub-projects"></a> what's a “sub-project” (and why sub-projects)?

The repository that this document lives in has many directories at its top
level. The remainder of this section describes the charactersitics these
directories tend to share, and how they tend to relate to each other; all
towards reaching an understanding of the "architecture" of this repository:

  - Each of these directories is frequently (but not always) some sort of
    software module. So in essence, this repository is mainly a collection of
    software modules.

  - These software modules do not necessarily exist in the same universe with
    each other; that is, they are not necessarily intended to all be in the
    same "runtime". Some of the modules may be written in python; others in
    ruby. Some may be written with a compiled language, others may be for
    Angular or React.

  - (However, there's no reason we can't hypothetically chain together
    several scripts meaningfully across "platform" boundaries (for exmaple,
    piping the output of a ruby script into a python script).)

  - We'll call these directories "sub-projects", not "modules": calling them
    all "modules" may mistakenly confer the idea that (one) they are all
    software (more below on this) and (two) they all exist in the same
    universe with each other. Ditto "packages".

  - We'll avoid the term "project" because without context, it's ambiguous
    whether it means "the one big project" or a particular sub-project.
    Rather, we call this one big directory "the mono-repo".

  - A sub-project can be as small as a single-file one-off or as large as
    a full-stack application.

  - A sub-project isn't necessarily software at all: it may simply be
    documentation (e.g., reading notes) or other text-adjacent assets we
    want to keep in version contorl for whatever reason.

  - For those sub-projects that *do* depend on others here, the rule is that
    these dependencies must not cycle (they must be acyclic): any given
    module here that depends on other modules here must do so as a "stack",
    with the module in question at the "top" and its depended-upon modules
    "below" it.

  - as for why in the world we maintain this one big repository and not
    several smaller ones, here is the rationale: we want the sub-projects
    to "feel" like part of a greater whole in the hopes that this will
    encourge them to share dependency, architecture and testing decisions
    whenever it's prudent to do so; in an arrangement where both the
    "library" and "application" codebases are moving targets under active
    development. also:

  - it is our experimental belief that in its way, maintaining a project of
    sub-projects can help combat "software erosion" (an idea mentioned in
    [12 factor][heroku3], explained well in [this old heroku blog][heroku4],
    and defined more formally in a wikipedia page.)
    the fear (wrought from experience) is that if a smaller project is off
    in its own little corner, it's easy to forget it exists for a few years.
    then when it's re-discovered and dusted off, the cost of getting it to
    work again is high; sometimes prohibitively so. keeping small projects
    close together in a larger repository keeps them all at the fore, so
    that the decision of whether or not to continue to maintain a small
    project is one made intentionally, rather than as a circumstantial
    afterthought. but all of this comes with this next provision:

  - _certainly_ if a sub-project grows to any degree of usefulness and
    maturity (or just sheer size in terms of SLOC), it should fork from
    this project (repository), be sunsetted here, and `git-filter-branch`
    (or similar) used to prune its extraneous history there.

  - our only real provision for sub-projects is that if they contain more
    than one file that they live at the _top_ of this directory tree.
    (i.e., there are no sub-sub-projects, etc.)


## running the tests for a specific sub-project

For a sub-project called "foo_bar", run the corresponding test suite
"foo_bar_test" with `pud foo_bar_test` (using an alias described
the [below section on aliases](#aliases). For example, for the "grep_dump"
sub-project:

```bash
pud grep_dump_test
```

That's all.



## <a name='running-all-the-tests'></a>overview of running the tests

We're currently experimenting with different ways we run the whole test
suite universe-wide (something we don't usually do at each commit).

The below uses an alias described in the [relevant section](#aliases).

This is the current sketch:

```bash
cat mono-repo.test-these.list | while read line; do >&2 echo -n " $line "; 2>&1 pud -fq "$line"; if [ $? -ne 0 ]; then; >&2 echo "ERRRORRED"; break; fi; done | awk '/^Ran ([0-9]+) test/ { printf "+%d", $2}'
```

This gives progressive
output only of each sub-project name as it _starts_ and doesn't show a stack
trace. (If the test suite X failed, just do `pud -vf X` to see details).



### running with coverage testing :[#021]

We use the python module called `coverage`. Consult their documentation.

But here's an example that worked at the moment of writing:

```bash
coverage run --source pho.cli.commands.issues pho_test/test_3925_issues/test_3975_CLI.py -vf
coverage html
open htmlcov/index.html
```



### more complicated (and now legacy) test suites

testing the API server of the "upload bot" is more involved. it its own
terminal:

    upload_bot_test/script/run-web-server

(if the server is already running, the PID of the process is displayed;
otherwise the server starts in that terminal.
stopping and starting the server is necessary whenever relevant code
changes, like when you're jumping version.
(`Ctrl-c` stops the server.))

then in your 'main' terminal:

    node_modules/newman/bin/newman.js run upload_bot_test/test_700_web/test_100_intro.postman_collection.json

(this presupposes that `npm install` was run at some point.)



## Developing with tests (doctest)

This is out of scope for this readme, but apparently we don't have a
dedicated document on the subject yet, so we're stowing this away in here
for now: Whirlwind tour of how to doctest:

In the asset code:

```python
def my_ting():
    """
    >>> my_ting(('A', 'B', 'C'))
    'A, B and C'
    """
```

At the bottom of the asset file:

```python
def _run_doctest():
    from doctest import testmod as func
    func()


if __name__ == "__main__":
    _run_doctest()
```

And, to get these to run from some proximal unit-test file:

```python

def load_tests(loader, tests, ignore):  # (this is a unittest API hook-in)
    from doctest import DocTestSuite
    tests.addTests(DocTestSuite(subject_module()))
    return tests
```



## <a name=aliases></a>(these aliases)

These aliases are now installed by the "dotfiles" sub-project (see).

### alias for executing python:

```bash
alias py='python3 -W error::Warning::0'
```

- At #history-A.2 we had to let warnings thru for tatsu, but this may
  change at any moment
- Wanting to exit with an error at the first warning is peak OCD


### alias for executing a directory of tests:

```bash
alias pud='py -m unittest discover'
```


### alias for our issue-tracking thing:

```bash
alias pi='py pho/cli/commands/issues.py'
```

- Can also be reached by `pho issues`, but the above saves a little overhead
- (run `setup.py` to get the `pho` executble)




## <a name=d></a>guidelines vaguely- or wholly-related to version control

  - please make sure you don't leave trailing whitespace on
    to the lines of any files unless you mean to.

  - when renaming files (i.e moving them), please commit the move(s) in a
    dedicated commit separate from commiting any edits to those files that
    moved. (reading edits to files in a diff can be ugly when it is paired
    with a move of the file, depending..)

  - write commit messages following these
    [git commit message guidelines][hugo-cmg]; namely that the first line
    of the message start with a capital letter, not have ending punctuation,
    be in the imperative mood, etc.




## <a name="node-table"></a>the node table

(this table is explained at [\[#002\]] using the node table.)

|Id                         | Main Tag | Content |
|---------------------------|:-----:|-
|[#900]-[#910]              |       | (anim)
|[#895]-[#899]              |       | ([tilex])
|[#890]-[#894]              |       | (app-flow & cap server)
|[#880]-[#889]              |       | (pho)
|[#851]-[#879]              |       | (kiss-rdb)
|[#811]-[#850]              |       | (reserved for [#406] CMS app for now)
|[#801]-[#810]              |       | (for redbean experiment)
|[#701]-[#799]              |       | (for tag lyfe)
|[#609]-[#655]              |       | (for text lib)
|[#601]-[#608]              |       | (for script lib)
|[#501]-[#599]              |       | (for modality agnostic)
|[#432]-[#499]              |       | (data-pipes)
|[#401]-[#431]              |       | (sakin-agac mostly; some moved to data-pipes)
|[#301]-[#399]              |       | (for upload bot)
|[#201]-[#299]              |       | (for grep dump)
|[#101]-[#199]              |       | (for microservice lib)
|[#023.2]                   | #trak | places where we wish we had auto-vivify
|[#022]                     | #trak | places where we wish we had strongly typed
|[#021]                     | #trak | mentions of coverage testing
|[#020.3]                   | #trak | track this one gripe about contextlib
|[#020.2]                   | #hm   | track this one gripe about argparse
|[#020]                     | #trak | track all issues with python itself
|[#019]                     |       | package filesystem conventions ..
|[#018.B]                   | #edit | edit documentation
|<a name=018></a>[\[#018\]] |       | installing and deploying python
|[#017.3]                   |       | explain listeners placeholder - use [#511] now instead - see help screen file deleted at #history-B.2
|[\[#016\]]                 |       | K hong reading notes
|[\[#015\]]                 |       | [tickler numberspace]
|[#014]                     | #hole |
|[#013]                     |       | modality-agnostic parameter expression
|[#012]                     |       | generic microservice arch (placeheld)
|[#011]                     | #hole |
|[#010.B]                   | #edit | edit documentation
|[\[#010\]]                 |       | extra-conventional conventions
|[#009]                     | #hole |
|[#008.13]                  | #open | how to setup.py
|[#008.12]                  | #trak | function reflection
|[#008.11]                  | #trak | CLI error case expression
|[#008.10]                  | #trak | places where you refer to that-other-project
|[#008.I]                   | #trak | wish we could hook into importing
|[#008.H]                   | #wish | come back when you understand data science better
|[#008.G]                   |       | track callable modules
|[#008.F]                   | #vape | machine-generated tests
|[#008.E]                   | #wish | gettext uber alles
|[#008.4]                   | #open | symlinks, `__path__`
|[#008.C]                   | #wish | function-based commands
|[#008.2]                   | #trak | track state machine implementations
|[#008]                     |       | (placeheld for small internal tracking)
|[#007.E]                   | #open | probably refactor all `format` and (probably) `%` to use f-strings
|[#007.D]                   | #open | PEP8 (now that we know how to activate it)
|[#007.3]                   | #trak | track where we use 'z' as a temp dir (1x)
|[#007.2]                   | #open | refactor helper.py memoizers to use doctest (now, general doctest wishers)
|[#007]                     |       | (placeheld for small wishlist items)
|[\[#006\]]                 |       | the README for the game server
|[\[#005\]]                 |       | text-based game client architecture
|<a name=004></a>[\[#004\]] |       | using the TODO stack
|[\[#003\]]                 |       | graph viz flowchart for which channel to use
|<a name=002></a>[\[#002\]] |       | using the node table
|[#001]                     |       | (this README file)




[\[#019\]]: doc/019-package-filesystem-conventions.md
[\[#018\]]: doc/018-installing-and-deploying-python.md
[\[#016\]]: game-server-doc/016-K-hong-reading-notes.md
[\[#015\]]: game-server-doc/015-tickler-file.md
[\[#010\]]: doc/010-extra-conventional-conventions.md
[\[#006\]]: game-server-doc/README.md
[\[#005\]]: doc/005-text-based-game-client-architecture.dot
[\[#004\]]: doc/004-using-the-TODO-stack.md
[\[#003\]]: doc/003-which-channel-flowchart.dot
[\[#002\]]: doc/002-using-the-node-table.md




[heroku4]: https://blog.heroku.com/the_new_heroku_4_erosion_resistance_explicit_contracts
[heroku3]: https://12factor.net/
[hugo-cmg]: https://github.com/gohugoio/hugo/blob/master/CONTRIBUTING.md#git-commit-message-guidelines




## document-meta

  - #history-B.2
  - #history-A.2
  - spike node table
  - #born.
