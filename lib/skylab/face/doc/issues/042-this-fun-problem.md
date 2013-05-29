# this fun design problem.

the matryoshka doll model [#040] is solid and we are sticking with it
(for now). one of its driving design principles was to offer over its
chronological predecessors (porcelain/legacy and headless CLI) is relative
simplicity of design:

you subclasses classes, use DSL's, and that's it. no pesky instance methods
modules or module methods modules to remember, no complex inheritence graphs
to create. its goal is that you can write simple, usable interfaces with it
that themselves use a simple usable interface to interact with the Face
library.

A challenger appears when it comes time to customize or DRY things up:
take for example the entity relationship diagram presented below, modeling
(in part conceptually) a typical single-classed CLI application, and what
is happening underneat. Take the arrow to mean "inherits from" (i.e
is a subclass of:)

                                        +---------+
                                   +-~->| command |
                      +--------+   |    +---------+
                 +--->|   ns   |---+
    +-------+    |    +--------+
    |  cli  |----+
    +-------+
        ^                              (frameworks-ville)
    . . | . . . . . . . . . . . . . . . . . . . . . . . .
        |                              (businessland)
        |
    +--------+
    | my cli |
    +--------+

    fig 1 - an ERD showing a typical simple 1-class app using the library.

The above reads, "in the framework-ish, there is a command called `command`
of which `namespace` (ns) is a subclass (sort of / conceptually), and
`cli` in turn subclasses `namespace`. in your application, then,
("businessland",) you will almost certainly subclass `cli` to make your own
cli client (that is one of the main points of the library). now, the trouble
begins with trying to get any extensibility into this mix. the below is
an **imaginary** **hypothetical** entity relationship diagram:

                                        +---------+
                                   +-~->| command |
                      +--------+   |    +---------+
                 +--->|   ns   |---+
    +-------+    |    +--------+
    |  cli  |----+        ^
    +-------+             |
        ^                 |            (frameworks-ville)
    . . | . . . . . . . . | . . . . . . . . . . . . . . .
        |             +--------+       (businessland)
        |         +-->| my ns  |
    +--------+    |   +--------+
    | my cli |----+
    +--------+

    fig 2 - this shows the desired inheritence relationships but is impossible.
    it is impossible because in single inheritence model, you can't have a
    node with more than one arrow emanating off of it.

it is reasonable to add extensibility to your cli class by e.g adding
private methods to it and that will work and is good. however, if your app
uses namespaces (which you should at least anticipate using in the future,
if you don't now, for ye olde scalability); then the problem becomes how
do you extend both your child namespaces and your topmost namespace, your CLI
"modality" client? let's explain why this is a problem:

you could sublcass the library's namespace class, but then you should most
likely want that same behavior in your topmost client. if you subclass your
custom namespace class to make your would-be topmost client, it is no longer
actually so because it needs also to subclass the `cli` class from the library.
since we cannot subclass more than one class in ruby (nor do we want to), we
need to find a way to implement this same graph conceptually by some other
means.

one answer, of course, is modules. let the double-headed arrow below mean
"includes":
                                        +---------+
                                   +-~->| command |
                      +--------+   |    +---------+
                 +--->|   ns   |---+
    +-------+    |    +--------+
    |  cli  |----+        ^
    +-------+             |
        ^                 |              (frameworks-ville)
    . . | . . . . . . . . | . . . . . . . . . . . . . . .
        |             +--------+         (businessland)
        |             |  my ns |------+
    +--------+        +--------+      |
    | my cli |----+                   |
    +--------+    |   /-----------\   |
                  +->>| my ns i.m |<<-+
                      \-----------/

    fig 3 - one possible workaround, using modules.

another possibility, one that we are conceptualizing as we write this, and
so is not yet possible with the library at the time of this writing, is:

    /-------\                           +---------+
 +>>|cli i.m|                      +-~->| command |
 |  \-------/         +--------+   |    +---------+
 |      ^^       +--->|   ns   |---+
 |      |        |    +--------+
 |  +-------+    |        ^
 |  |  cli  |----+        |
 |  +-------+             |
 |                        |              (frameworks-ville)
 |  . . . . . . . . . . . | . . . . . . . . . . . . . . .
 |                    +--------+         (businessland)
 |              +---->|  my ns |
 |  +--------+  |     +--------+
 +--| my cli |--+
    +--------+

    fig 4 - another possible workaround, using modules. note the
    same number of arcs and nodes fig 3., only businessland need not
    concern itself with creating modules, only including them.

what this model does is, it puts all the "modality client" customizations
in a module ("cli instance methods (i.m)") insted of class `cli`. the `cli`
class could then, in the library, be totally empty except for including the
i.m module.  Then, the businessland application space has a choice as to
whether to include the i.m or subclass the class. this is slated for
#todo:during:8

~
