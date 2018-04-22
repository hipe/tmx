# down town fun readme

## objective & scope

this “project” consists of several “sub-projects” whose only unifying
theme is that they are somehow of interest (maybe) to the DTF group chat.

although the sub-projects are thematically disparate from one aonther, we
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

  - mainly we use the term to avoid confusion with the term “project” which
    we use to mean _this_ directory tree we keep in version control (at the
    top of which this README file sits).

  - a sub-project can be as small as a single-file one-off, or as large as
    a full-stack application. to place sub-projects into the same project
    indicates the aspiration to share a significant portion of code (or
    documention, etc) across those sub-projects (code or documention that
    itself is under active development).

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
    the fear (wrought from experience) is thaat if a smaller project is off
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




## <a name='running-all-the-tests'></a>overview of running the tests


we "shouldn't" be specifying all these sub-project-specific instructions
redundantly here, but the desire to have this in one centralized easy
reference outweighs this concern.

at the moment our tests fall into two categories:

  1. the easy, unit-test-like tests in python

  1. the more involved tests that require a server to be running.



### the easy tests

(using [these aliases](#aliases)):

    pud modality_agnostic_test && pud game_server_test && pud grep_dump_test && pud upload_bot_test



### the more invovled tests

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




## <a name=aliases></a>(these aliases)

    alias py='python3 -W error::Warning::0'
    alias pud='py -m unittest discover'




## <a name=d></a>guidelines vaguely- or wholly-related to version control

  - please make sure you don't leave trailing whitespace on
    to the lines of any files unless you mean to.

  - when renaming files (i.e moving them), please commit the move(s) in a
    dedicated commit separate from commiting any edits to those files that
    moved. (reading edits to files in a diff can be ugly when it is paired
    with a move of the file, depending..)




## <a name="node-table"></a>the node table

(this table is explained at [\[#002\]] using the node table.)

|Id                         | Main Tag | Content
|---------------------------|:-----:|-
|[#501]-[#599]              |       | (for modality agnostic)
|[#401]-[#499]              |       | (for sakin agac)
|[#301]-[#399]              |       | (for upload bot)
|[#201]-[#299]              |       | (for grep dump)
|[#101]-[#199]              |       | (for game server)
[[\[#019\]]                 |       | normalizing `sys.path`
|<a name=018></a>[\[#018\]] |       | installing and deploying python
[[#017]                     |       | [placeholder to explain our listener pattern]
|[\[#016\]]                 |       | K hong reading notes
|[\[#015\]]                 |       | [ticker numberspace]
|[#014]                     |       | [expect tree-like screen]
|[#013]                     |       | modality-agnostic parameter expression
|[#012]                     |       | generic microservice arch (placeheld)
|[#011]                     |       | commands/parameters API (placeheld)
|[\[#010\]]                 |       | extra-conventional conventions
|[#009]                     |       | [ expect STD's ]
|[#008.F]                   | #vape | machine-generated tests
|[#008.E]                   | #wish | gettext uber alles
|[#008.D]                   | #wish | strongly typed python yikes
|[#008.C]                   | #wish | function-based commands
|[#008.B]                   | #open | remove array abuse
|[#008]                     |       | (placeheld for small internal tracking)
|[#007.D]                   | #open | PEP8 (now that we know how to activate it)
|[#007.C]                   | #open | lock current stable (python 3.6.4) w/ virtualenv/VCS
|[#007.B]                   | #open | refactor helper.py memoizers to use doctest
|[#007]                     |       | (placeheld for small wishlist items)
|[\[#006\]]                 |       | the README for the game server
|[\[#005\]]                 |       | text-based game client architecture
|<a name=004></a>[\[#004\]] |       | using the TODO stack
|[\[#003\]]                 |       | graph viz flowchart for which channel to use
|<a name=002></a>[\[#002\]] |       | using the node table
|[#001]                     |       | (this README file)




[\[#019\]]: doc/019-normalizing-sys-path.md
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




## document-meta

  - spike node table
  - #born.