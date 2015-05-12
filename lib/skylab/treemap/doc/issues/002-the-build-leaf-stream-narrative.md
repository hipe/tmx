# the "build leaf stream" narrrative :[#002]

(for now we are rebuilding from scratch much of the logic in [#ba-043]
with the intention of one day *perhaps* integrating the two:)

we have two fundamental design objectives in enjoyable opposition to
each other:

  1) output our output as quickly as our input is input

  2) via context, determine the "semantics" of our input nodes,
     the classification from which is part of our output.

(1) is i.e that we want this to be "streaming" - we aren't just
loading all the input into a file or memory before flushing one big
tree to output. we want to output each "thing" as soon as we can.

(2) is our payload value behavior: in essence, what we offer uniquely
is to classify leaf nodes as separate from branch nodes.

building on the algorithm of our stated mentor node, we can start
things off postulating this axiom:

    we *never* know whether the current line represents a leaf or
    branch node until we see the next line (or determine that the
    current line is the last line of input). (but IFF that do we
    always know?)

we don't prove this here, but hope that it stands to be self evident.
one more big assumption:

    when a node is "closed" it is not re-opened. if "another" node
    comes along with the same identifying string, it is treated as
    its own node, and not a re-opening of the previous counterpart
    node. this will make more sense below.

a corollary of this axiom and this assumption:

    when a (tautologically branch) node "closes" we will know the
    full "path" of it back to the root.

down to brass tacks, a pseudocode snippet towards implementing all
of this:

    (random: maybe track timestamps of the nodes as they are read from
    the input! this could be implementd as a mapping filter, transparent
    to the subject concern yay.)

    (below we often say "unit" instead of "node" to emphasize that
    the node also has data specfic to the modality system: in today's
    case every node stems from a line of input. and like a common
    "unit" in the measurement of time is seconds and a common unit
    when cooking is "ounces", the unit we deal in here when processing
    textual input is a line of text. but to emphasize the generality of
    the algorithm for other datasources, we say "unit" instead of "line".)

    we will start with an artifically constructed "root" node which
    all input units that have zero indentation will use as parent.

    we introduce a concept called "depth": the root node has a depth
    of 0 (and no other nodes in the tree will). all nodes at the first
    level will have a depth of 1, their children 2 and so on.

    we will memoize context with a "backtrack distance" of one unit:
    for any given unit we will always know the previous (i.e immediately
    above) unit. this means "above" in the input "document". it may also
    mean "above" as in "parent node" but we don't know that yet.

    in this notation system and system like it (OGDL, markdown-style outline
    format), the following rules are axiomatic: parent-child relationships
    are always expressed through indention.

    now, iterating over every unit from the upstream we can procede in
    one of three ways based on comparing the indentation of this unit
    with the previous unit:




    1) if the current unit has a DEEPER level of indentation: what an
       increase in indentation expresses is easy to interpret: it means with
       certainty that the current unit is an immediate child of the previous
       unit, i.e that unit is the parent of this one. the classification of
       this unit is still unknown, however we now *do* know that:

         • the previous unit is a branch (not leaf) node.

         • this unit is an immediate child of that unit.

       (note that we have determined the parent of the current unit)




    2) otherwise if the current unit has THE SAME level of indentation as
       the immediately previous unit, we again don't yet know the
       classification of this unit, however we now *do* know that:

         • the *previous* unit is a leaf node (using the assumptions that
           branches are never empty and never re-open).

         • this unit is sibling to the previous unit, hence this unit's
           parent is the same as the previous unit's parent.

       (note that we have determined the parent of the current unit)




     3) otherwise (and this unit has a SHALLOWER level of indentation than
        the immediately previous unit), this is the fun part:

            • you now *know* the immediately previous unit is a leaf
              (under the same assumptions from (2)).

        note that in every other case (1 & 2) we have left the then
        current node knowing its parent. if we will now determine the
        parent of this node (and this is the last of 3 cases) then we
        will always know the parent of every node.

        the challenge is that we've got to find out what the current
        level of indentation "means". all we know is that it is
        shallower than the unit immediately above us.

        (this isn't the only way but it's one way:) a stream of nodes
        can be formed by by taking the parent of the previous node, and
        then the parent node of that one and so on until we are at the
        (artificial) root node. we can do this operating under the
        assumption that every previous node's parent is known.

        with such a stream, look at each parent until one is found
        whose indentation is at an equal or lesser depth than this one.
        assume that one will be found eventually because the artificial
        root node's indent depth is artificially negative, which is not
        a naturally occuring phenomenon.

        if the node that is found has an indent depth that is shallower,
        this is a "syntax error" - the current unit cannot be parsed
        because its indentation "doesn't make sense".

        however, if we found the node we are looking for, we can take
        the parent of that node as our own parent (because the reference
        node has the same depth as us; depth expresses parenthood)
        and move on yay.




    when you get to no more input, you know that the immediately
    previous unit of input is a leaf (with again the same assumptions
    from (2)).

Caveat: we do not recognize tab characters as separate from space
characters. the "level of indent" is determined only by the *number* of
leading tab and/or space characters. tabs are neither "hard" nor "soft"
in the traditional sense: they are just counted as if they are spaces.

whew!
