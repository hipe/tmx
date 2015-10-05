# the isomorphic methods client narrative :[#104]

(EDIT: this was transplated from the sunsetted [hl]. we have chopped
away all that is no longer relevant, but we have not made the remainder
into a pretty, coherent narrative yet..)

the central thesis statement of this experiment
is: [#104] "can a clean isomorphicism be drawn between the public methods of
a particular class and its collection of supported "commands"?". this remains
the space of active inquiry and we embark on our eights or so rewrite of an
implementation of this idea.

to get pseudo-formal for a second, the grammar ends up looking something like:

    class Foo < [ subject ]

      NODE_DEFINITION *

      NODE_DEFINITON : NODE_MODIFIER *  COMMAND

      COMMAND: ( a public method definition )
    end

the above is to say, a DSL-enhanced box class contains zero or more node
definitions. a node defintion is be zero or more node modifiers followed
by one command. a command is (simply) a public method definition.

so note that by this defintion, the empty class by itself is still a valid
box node, as is one with only one public method definition..

..

the essence of this node is in this 'method_added' hook.
_
