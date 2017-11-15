# unparsing losslessly :[#026]

## table of contents

  - justification, objective & scope
  - predicates of the algorithm (assumptions)
  - algorithm-ish
  - detail: seeding the recursion




## justification, objective & scope

objective: do what `unparse` does but preserve the use of whitespace and
other arbitrary non-semantic elements (the use of optional parenthesis,
indention, line breaks, and comments) that are present in the source
document (this assumes there is a source document) while allowing that
the "terminal values" of the AST could have changed from what is in the
document.

justification: `unparse` does not offer this behavior.

outer scope: there is the tiniest chance that we would abstract this into
its own gem to serve as a complement to `unparse`. in a fact a fair chance.




## predicates of the algorithm (assumptions)

### maps, AST nodes, source buffers and ranges

this algorithm will generally be recursive because that's the easiest
approach given the fundamentally recursive nature of the input structures.

at any given node ("recursal"), we have two structures:

  1) the "map" (a `::Parser::Source::Map`)
  2) our structured node (that simply wraps the `::Parser::AST::Node`)

explaining either of these is out of our scope, but as for (1) just know
that it amounts to a tuple of ranges where each relevant range is the
range in the "source buffer" (source document) where that *terminal*
element's surface representation is. so while this won't explicitly have
a range for "the whitespace between the `def` keyword and the method
name", it *will* have a range for "the `def` keyword" as well as the
method name. it even has a range for the `end` keyword.

(the "coordinate system" for ranges is definitely a thing but it's perhaps
too detailed to worry about here. we *think* it's safe to think of the
"source buffer" as one big string of every byte from the document,
and "range" as a plain old ruby `::Range` (exclusive) into that string.
so note that ranges themselves don't intrinsically "know" what line they
are on, but this can be "decomposed" trivially, as exposed by the source
buffer class and then the range class using it.)



### what we have to work from, specifically

as introduced above, we have (1) maps and (2) structured nodes. at one
"recursal", assume we have one of each. the thing is, each of these
structures has ordered child components with symbolic names, and each
of these lists of components is necessary to be able to rewrite our
document, BUT the real thing is: we don't know how the two interleave.

take, for example, this contrived but syntactically valid method definition:

    +---------
    |
       def xx a, b
         do_some_thing
       end

note we are showing "the edge of the paper" so we can see that the thing
is indented by two spaces.

we want to visualize this as a continuous stream of bytes (in part because
later we'll be employing it as an "ASCII grid") so we'll flatten all the
lines into one line:

    +-----
    |  def xx a, b~do_some_thing~  end

we are using `~` to signify a newline so that its visual representation
takes only one character of width.

so, when we parse this with the vendor library and wrap it in our own work,
we get (again) two things:

  1) a "structured node" (a wrapped `::Parser::AST::Node`)

  2) a `::Parser::Source::Map`

first of all, the structured node exposes these components (with names
that we have chosen in our subject library):

  - `method_name`
  - `args`
  - `any_body_expression`

also, within the (vendor) AST node, we can access its "map". while the
ordered membership here is probably an emergent by-product of the target
language, the names themselves are exposed by the vendor. they are:

  - `keyword`
  - `operator`
  - `name`
  - `end`

we're going to ignore `operator` until TODO.

let's first consider the spans of characters that are isomorphed directly
in the "map" structure's terminal ranges. that is, of the child components
(ranges) of the map structure, how to they correspond to our input string?

        +-----
        |  def xx a, b~do_some_thing~  end
    ->  |  rr1 r3                      rr4

`rr1` is the first range in the above list, `r3` is the third range in the
list, and so on. note the second range (`operator`) is not present in our
map structure and so it is not relevant here.

now, let's consider those spans in our run that we're going to assume will
be covered by recursals. in other words, try to line-up spans of the run
with child components of our structured node.

        +-----
        |  def xx a, b~do_some_thing~  end
    ->  |      c1 ccc2 cccccccccccc3

so `c1` is `method_name`, `c2` is `args`, and `c3` is `any_body_expression`.
a few things to note about this one: 1) our method name is again
represented in this structure as it was before in our map structure.
2) we haven't shown any newlines as being under the domain of any range
but that's TODO up for debate.

finally, let's look at the isomorphism of the two structures together.

        +-----
        |  def xx a, b~do_some_thing~  end
        |  rr1 r3                      rr4
        |      c1 ccc2 cccccccccccc3

with what we can see above, note a few things:

  1) it appears that all the surface phenomena in the source input string
     are "covered" (whitespace not so, but we'll worry about that later).
     also later, we'll worry about what we would do if they weren't.

  2) notice that all coverage is non-redundant, except that of the method
     name. later we'll discuss how this is actually *not* redundant,
     because from the one element we get a range into the source string,
     and from the other element we get the (possibly replacement) content.




## algorithm-ish

so finally, here's gonna be our general approach:

  - generally what we're doing is outputing a rewritten string given the
    source string and the possibly updated AST node.

  - we'll traverse along the formal components in their order.

  - formal components that co-occcur (as `r3` and `c1` do above) will be
    given special handling.

  - so the very first thing is, we need the offset into the (any) first
    character of the first line of the full surface string in the source.
    (how this is acquired is not important, but it's something like
    `@structured_node._node_location_.expression.begin_pos`.)

  - so traverse along the formal actions. we make "hops" from one "semantic
    column" to another, at each hop taking particular actions based on what
    kind of state transition it is.

    here's the kind of transitions present in our example:

      - start state to terminal range state (s2r).
      - terminal range state to "both" state (r2b).
      - "both" state to associated component state (b2a).
      - associated component state to itself (a2a).
      - associated component state to range state (a2r).
      - range state to the end of the input string (r2e).

    in addition to transitions effected by this example, we anticipate
    having a few of the other categories (permutations) of transition
    along these lines. (this model predicts a total of 3 kinds of start
    transitions, 3 kinds of end transition, and 9 kinds of inner
    transitions.)

  - here's a rough hashing out of the actions to take at each category
    of transition:

      - `s2r`: make a note of the range (or not).

      - `s2b`: xx

      - `r2b`: flush the static string up to the beginning of the current
               range (of this column). write the terminal value (TODO).
               make a note of the range (that points to the original string).

      - `b2a`: make a note of the end of the range you are leaving.
               recurse into the associated component, telling it the
               noted offset. the recursal *must* tell you what the index
               into the original string is when you return from it.

      - `a2a`: similar to above..

      - `a2r`: as above, we have the last offset that we were left with.
               make a note of the last offset of this range too.

      - `b2e`: ..

      - `r2e`: flush. done!




## detail: seeding the recursion :[#here.D]

the central "recursal" sub-algorithm is predicated on knowing the
offset of the last character that was output (either as part of a
replacement run or part of the "static string", indifferently).

when we are *not* in a *sub*-recursal (i.e we are in the root
recursal), we have to "seed" our algorithm with such an offset.

consider this snippet:

    +---
    |class Foo
    |
    |  def wee
    |    code
    |  end
    |
    |  def ohai
    |    code
    |  end
    |
    |  def wiz


imagine we are going to replace the `ohai` method. in the below examples
we illustrate the replacement expression with x's, and newines with `~`.

here is how we *thought* this would work:

    |  end
    |
    |xxxxxxxxxxxxxx..~
    |xxxxxxxxxxxxxx..~
    |xxxxx~
    |
    |  def wiz

note that the replacement expression falls on the boundaries of line
boundaries. the replacement expression is comprised of three lines, each
one being newline terminated.

in fact this is how we want the replacement expressions to look:

    |  end
    |
    |  xxxxxxxxxxxx..~
    |xxxxxxxxxxxxxx..~
    |xxxxx
    |
    |  def wiz

note two things that stand in contrast to what we expected:

  1) the replacement starts at the first character of the `def` keyword and

  2) the replacement ends at the last character of the `end` keyword (and
     does *not* include any trailing newline)

as such, we should be aware of issues near [#sa-011] "line termination
sequences" (LTS) but hopefully we are mostly insulated from these issues
here.




## document-meta

  - #born
