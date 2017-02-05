# non-interactive CLI fail early :[#064]

## introduction/objective/scope/purpose of this document (STUB)

a "fail early" mock library for non-interactive CLI.

to describe "fail early" mechanics is outside this scope, but
it should happen somewhere #todo.

this document exists only to hold incidental "code notes"




## "this dichotomy" :[#here.B]

as referenced inline in the asset node, there "should be" a dichotomy
between a structure represention an "expectation" and a performer whose
responsibility is to carry out the "assertion" of that expection.

however, *for now* we are experimentally munging these two disparate
concerns into single classes. this could come back to haunt us if ever
we are trying to use the same setup across different cases; but so far
(fingers crossed) it seems not to be an issue.




## `expect_styled_content` :[#here.A]

the subject method is a "standalone" "macro" (standalone because
it implements its distinct features all in this method) that
provides as a convenience a way to express one of a category of line
styled with an ASCII escape sequence. this category is those lines
that have a head-anchored span of zero or more leading whitespace
characters (tab or space only) and the rest of the line is "content"
nested in a "typical" escape sequence (one that "opens" with one or
more style codes and "closes" with `0`). so:

    str = "  foo"
    sym_a = [:strong, :green]

expresses an expected string of:

      "  \e[1;32mfoo\e[0m"

which we can desconstruct as:

       mmEEEEEEEEcccEEEEE"

the 'm' span is the "margin" (head-anchored whitespace), the 'c'
part is the content, and the 'E' parts are the escape sequences
("open" and "close", our own informal concepts not part of the
ASCII escape sequence spec).

  - the margin is derived from the any leading head-anchored
    part of the string that is tabs or spaces.

  - the content part of the string is the rest

  - the `1` and `32` come from sending the remote facility
    `:strong` and `:green`




## document-meta

  - #born a good while after the conception of the library
