# ordering rationale

## table of contents

  - TL;DR: (synopsis) [#here.s1]
  - the received order and our re-ordering rationale [#here.b]  [#here.s3]
  - finally - our ordering with numbers [#here.d]
  - appendix: about older tests [#here.s5]




## TL;DR: (synopsis)

we changed the order of the categories of grammatical symbols from the
order that the `parser` gem uses, for reasons. our order is presented in
the [#here.d] last section of this document.




## the received order and our re-ordering rationale :[#here.b]

we want our test files to be in [#ts-001] bottom-up, "regression-friendly"
order.

conveniently, the `parser` gem structures its grammar symbols into a
hierarchical taxonomy (i.e a nested category system), presented to us
in the comments of `default/builder.rb` there (in the version of that
gem that corresponds to our gemfile at writing):

  - literals
    - singletons
    - numerics
    - strings
    - symbols
    - executable strings
    - regular expressions
    - arrays
    - hashes
    - ranges
  - access
  - assignment
  - class and module definition
  - method (un)definition
  - formal arguments
  - method calls
  - control flow
    - logical operations
    - conditionals
    - case matching
    - loops
    - keywords
    - exception handling
  - expression grouping

note the entire language of ruby can fit into this "skeleton" of categories.
note the toplevel categories, of which there are nine (9).

it's worth mentioning that there is perhaps nothing deeply intrinsic
about some of these toplevel categories. but we will assume that there is,
having no good reason not to.

the thing is, we are a bit OCD about our regression-friendly system,
in that we want our ordering of these nodes to "feel" lowel-level to
higher level. (see [#ts-001] for an exhausting justification of this.)

although the above taxonomy is essential in giving us the categories,
we here present our own ordering with our own refinements.

(again) here's the received ordering of the toplevel categories:

  - literals
  - access
  - assignment
  - class and module definition
  - method (un)definition
  - formal arguments
  - method calls
  - control flow
  - expression grouping

here's our ordering:

  - literals
  - assignment
  - access
  - control flow
  - expression grouping
  - formal arguments
  - method (un)definition
  - method calls
  - class and module definition

again it is perhaps arbitrary, but here is the rationale:

  - we have flip-flopped "assignment" and "access" because (conceptually,
    at least) you need to be able to assign in order to access (but not the
    reverse), so the new ordering reflects the fact that the one depends on
    the other.

  - we see control flow as the next essential building-block in programming
    generally. (indeed academic textbooks/course curricula seem to agree.)
    that is, you can write interesting small programs (think shell scripts)
    with control flow but without functions, classes and the rest; but the
    reverse is not true.

  - expression grouping "feels like" it belongs near control flow. also it
    "feels" like a lower, more fundamental construct than the remaining
    categories. (we might even move it up to before it.)

  - although you can have method definitions without formal argument
    (while the reverse is not true), since we see formal arguments as a
    smaller component of which method are made up of; we introduce the
    lower-level pieces first.

  - (note we have put method calls immediately after method definition,
    becuase of the one-way dependency there. however in practice it's quite
    hard to write even a small ruby program without a method call, so this
    is a case where the conceptual trumps the practical.)

  - using this now familar rationale; you can write ruby programs with
    functions (actually methods) but no classes; but to think of a case when
    the reverse is true challenges the imagination. hence, classes (and
    modules) after methods.




## finally - our ordering with numbers :[#here.d]

(from `tmx-test-support-subdivide 0:1000:9`)

  - literals (056)
  - assignment (167)
  - access (278)
  - control flow (389)
  - expression grouping (500)
  - formal arguments (611)
  - method (un)definition (722)
  - method calls (833)
  - class and module definition (944)




## appendix: about older tests

the place that references :#spot1.1 (another test-level README, like this
one) has an older take on the taxonomy that we came up with (willfully)
before discovering what the `parser` gem used. the taxonomy there is
(we are relieved to report) almost a perfectly clean subset of our taxonomy
here. however #todo boy is it tempting to re-order the contents of those
files to match the received order described in [#here.b].
