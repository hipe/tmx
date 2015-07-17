# what is the front model? :[#002]

## introduction

it's a long-running daemon that receives requests. we are modeling it as
a model (for now) because it meets the criteria of a model. although it
is a lot like the [br] kernel.




## algorithm to adapt scripts [#.A]

synopsis: we implement a strategy to treat a *qualifying*
executable script into a "reactive node" for our generated reactive
node macro-tree.

the implementation of this lives in an ancillary node to the subject node.

it's useful to have fleshed-out, [#br-100] "reactive tree" applications
in our universe. it is also useful to have plain-old, one-off scripts
(typically only one file in length) in this same universe. this
algorithm is an attempt to make the other appear like the one in our
special "macro tree" we are building in subject.

that qualifying criteria is currently something like:

  • the file's entry name must start with 'tmx-', to show that it's
    playing along. (it is useful to support the existentce of other
    files without this prefix living in our one 'bin' directory for
    example to support git extensions, something outside of this scope.)

  • sadly, at present such files *must* be written in ruby. in fact
    we could eliminiate this restriction with some tricks (we could peek
    at the "shebang" line, and if says something other than ruby we could
    not load it but only run it, making all the other applicable
    assumptions below.) but because we only *happen* to have no such
    scripts yet (at this top of our project), we haven't done this yet.

  • all participating scripts must exhibit a "normal" response to
    receiving the '-h' string as single argument. a variety of patterns
    and strategies will be applied to parse its output.

  • this is a contentious one that we would not do were it not for the
    performance gain from it: the script must anticipate that it will be
    loaded *either* as an executable *or* as a library. (to add this
    behavior requirement allows us to load the (at this moment) 19
    script in a single runtime instead of needing to spawn a new
    operating process for each one, a choice that has an order of
    magnitude impact on performance.)

so, with that, the algorithm:

(we assume for whatever reason that file hasn't been loaded yet.)
we load the file.
we assume that having done this, the loading of the file will have set
an *isomorphically named* const (per [#ca-060]) derived from the relevant
"slug" portion of the containing filename (when) *immediately under* the
toplevel const of our project. got that? :P

  so: a file named "tmx-foo-bar-baz"
  should set: `::Skylab::Foo_Bar_Baz`

note that the file implicitly effects a poka-yoke by setting one const
*under* a certain module that the script itself didn't create. in other
words, when things aren't right this will hopefully fail early as
opposed to failing silently.

the value it sets to this const must be a ..




## .. universal command line utility proc :[#.B]

..which is a proc that takes exactly these five derks in this order:

    ( stdin, stdout, stderr, program_name, argv )

it will never be called with less than these five. if it ever takes
more than five we shoould probably revisit this whole design.
