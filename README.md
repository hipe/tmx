# down town fun readme

## objective & scope

for now, this can be any and everything we would like to version
for DTF: software, data, visualizations, whatever.

so at current, the scope is unbounded. but see the next section.




## development

for now, this project may host several disparate sub-projects.

as necessary, the sub-project (in the eyes of version control) may fork
into its own versioned project, after the fact. this is just to say: not
every project needs to start out with its own versioned repository.

that is, work on any given DTF-related may start within this project at
first. (it is assumed that generally many of these sub-projects will be
small in scale and small in code-side, so there is probably no reason to
create a large diaspora of small versioned projects, when one large
macro-project would suffice.)




## contents of this project:

  - [`TODO.stack`](TODO.stack)
    - one line per item
    - see [[#004]](#004) using the todo stack

  - `bin/`
      - of course don't actually put binary files in here. this is for
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




## guidelines vaguely- or wholly-related to version control

  - please make sure you don't leave trailing whitespace on
    to the lines of any files unless you mean to.

  - when renaming files (i.e moving them), please commit the move(s) in a
    dedicated commit separate from commiting any edits to those files that
    moved. (reading edits to files in a diff can be ugly when it is paired
    with a move of the file, depending..)




## the node table <a name="node-table"></a>

(this table is explained at [\[#002\]] using the node table.)

|Id                         | Main Tag | Content
|---------------------------|:-----:|-
|[\[#006\]]                 |       | the README for the game server
|[\[#005\]]                 |       | text-based game client architecture
|[\[#004\]]<a name=004></a> |       | using the TODO stack
|[\[#003\]]                 |       | graph viz flowchart for which channel to use
|[\[#002\]]                 |       | using the node table
|[#001]                     |       | (this README file)



[\[#006\]]: game-server-doc/README.md
[\[#005\]]: doc/005-text-based-game-client-architecture.dot
[\[#004\]]: doc/004-using-the-TODO-stack.md
[\[#003\]]: doc/003-which-channel-flowchart.dot
[\[#002\]]: doc/002-using-the-node-table.md







## document-meta

  - spike node table
  - #born.
