# down town fun readme

## objective & scope

for now, this can be any and everything we would like to version
for DTF: software, data, visualizations, whatever.

at the moment our scope is unbounded. but see ideas related to
project scoping [below](#sub-projects).




## <a name=b></a>development overview

this “project” consists of [“sub-projects”](#sub-projects).

as for contributing to this project, see the below comments on
[version control](#d) and our [\[#010\]] extra-conventional conventions.

see [installing and deploying python](#018) if your sub-project requires it.




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






## <a name="sub-projects"></a> what's a “sub-project”?

we offer no formal definition for “sub-project” but:

  - mainly we use the term to avoid confusion with the term “project” which
    we use to mean _this_ directory tree we keep in version control (at the
    top of which this README file sits).

  - a sub-project can be as small as a single-file one-off, or as large as
    a full-stack application. to place sub-projects into the same project
    indicates the aspiration to share a significant portion of code (or
    documention, etc) across those sub-projects (code or documention that
    itself is under active development).

  - if a sub-project gets obnoxiously huge: it can fork from this project,
    we can prune its excess and (back in this project) we can sunset it.

  - our only real provision for sub-projects is that if they contain more
    than one file that they live at the _top_ of this directory tree.
    (i.e., there are no sub-sub-projects, etc.)




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
|[#401]-[#499]              |       | (for etc)
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







## document-meta

  - spike node table
  - #born.
