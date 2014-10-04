# the iambics narrative :[#046]


## introduction

in keeping with the tradition of wacky experiments in this universe,
the iambic experiment is one of the grandest and wackiest of them all.
it has so far yielded a spectrum of phenomena ranging from smelly to
indispensible.

if it means anything to you, one way of looking at iambics is that they
are a family of approaches to making a mini-DSL, typically for a method.

formerly called "tagged argument lists", it will be fun one day to do a
full study of their origins. for better or worse, they are gradually
taking over the "argument parsing" landscape in this universe.

broadly, we use "iambic" either as an adjective or a noun. when a noun,
we typically mean an array of arguments that need to be parsed. as an
adjective it usually describes formal or acutal arguments that are
parsed in this manner.

to the uninitiated none of this will make sense without the examples
below.




## meaning of the name 'iambic'

we borrowed the term from the form of verse "iambic pentameter" popular
with Shakespeare: verse written in iambic pentameter has a two-step
rhythm (dah-DUH dah-DUH dah-DUH ..) and often (but certainly not
always!) our tagged arguments list also have this same two-step rhythm.

originally for whatever reason we mistakenly thought the word "iambic" had
some etymological origin with the word "foot" (as in the thing you take
steps with). when we discovered that it actually comes from greek "iambos"
(lampoon) from "iaptein" (to attack verbally), we rejoiced at this apropos
serendipity: iambic arguments can indeed seem like a verbal attack on the
method.

like the "shell" and "kernel" concepts in UNIX, the term "iambic" is
co-opted from an existing word with existing meaning in the universe,
but it has taken on a new meaning all its own, and is perhaps best to
get familiar with it as its own concept: our "iambics" resemble
Shakespearian verse about as much as OSX's mach kernel resembles a
kernel of corn, or the z-shell a sea shell.




## a brief introduction to the feeling of iambics

iambic arguments are typically "flat" and "freeform". unlike a
dictionary which is a structured pairing of keys and values, an iambic
is a straight sequence of mixed objects.

for example:

    write_to_path "some-file.dot",
      :is_dry_run, true,
      :be_verbose, true

on its surface, the above call is a method call being passed five
arguments. but hopefully by the way we have formatted the code you can
infer the semantics here: `is_dry_run` is an option has a `true` value,
as well as the `be_verbose` option has a value of `true` too.

in this imaginary syntax we parse the first argument (the filename) as a
positional argument rather than a named argument (that is, it does not
have a 'name tag' before it) because hopefully it is clear from the
method name that we have one required argument, and it is a path.

after the above call takes this one ("positional") required argument
(the filename), then it parses any remaining arguments "iambically".
note that while strictly speaking there are five actual arguments
being sent to this method call, but conceptually there are three.



a method that supports iambic arguments can look on the surface like the
"named arguments" of objective C, but iambics are a bit more powerful
(and dangerous) than those; because whereas the named arguments of
objective C are always key-value pairs, iambics are not necessarily so:

for example, if you implement 'flags' in your grammar (or use a library
that does this) the iambic call can be shorter without sacrificing
readability. compare:

    write_to_path "some-file.dot", :verbose, :dry_run

vs:

    write_to_path "some-file.dot", verbose: true, dry_run: true


if you implement your syntax to do so, and you prefer it, you could
support the shorter (more readable?) above form rather than the below.

but more often we go the other way: iambics are one answer to long
argument lists. as a rule of thumb, if your method takes more than one
or two arguments, we would like you take those arguments iambically.



## iambic features and their corollaries (advantages & disadvantages both)

• structurally, the surface form of iambics is "simpler" than
  dictionaries: a sequential list of things is one of the most
  universally available structures in programming langauges [citation
  needed]. it resembles written natural language a bit more, where we
  parse a sequence of tokens; rather than the caller structuring the
  argument into non-list structures herself.

  one possible corollary of this is that it encourages the caller to
  focus on what the argument data is rather than how it should be
  structured.

  another is that this may have benefits for exposing API's to sources
  of data outside the ruby runtime: passing lists of strings around is
  generally one of the easiest and most universally available transport
  techniques (e.g zeromq).


• as demonstrated with the examples in the previous section, whether shorter
  or longer, iambic calls can be arguably more readable than the presented
  alternatives. because they are flat with a freeform grammar, depending on
  the implementer (and the reader!) they can be more readable than more
  sturctured alternatives.

  compare:

    o :required, :editable, :property, :first_name

  to

    property :first_name, required: true, editable: true

  there is certainly room for debate as to which one is preferable, as
  dave thomas [explored] [DSL-vs-natural-language] a few years back.

  a general gotcha we try to keep in mind is that to read an iambic, the
  reader may need to have apriori knowledge of the domain, whereas with
  the more traditional approaches it can be obvious that you are looking
  at options as opposed to arguments. take this and your target readers
  into account as you design your grammar.



• hackishly, mutable iambics can be mutated by `unshift` or `push`

  iambic arguments are not meant to be mutated as much as they are to be
  parsed. but despite this, some mutating may happen in the field.

  unlike a hash which serves random access (you get a value by providing
  a key; you can change a value by providing a key and value); random
  access with iambics is at best ghastly (if the grammar is perfectly
  even), and at worst impossible (in a freeform grammar).

  so, unlike with a hash in this scenario where a sender could explicitly
  overwrite values in an argument hash that it is preparing, with an
  iambic in this scenario the sender should only prepend or append new
  name-value pairs on to the exiting iambic (if that).

  upon receiving such an iambic, it is the receiver that gets to decide
  whether these multiple values should be treated as parts of a list or
  if each subsequent value should effectively overwrite the previous value
  (and whether each new value should be subject to validation, or only
  the last one).

  because in practice iambics are typically parsed from "beginning" to
  "end", you can take this into account if you mutate a mutable iambic:
  if you `unshift` arguments on to the front of the iambic, they might
  get processed before the subsequent arguments. a `push` (or `concat`)
  and presumably your new arguments will be processed later than those
  that came before them.

  occasionally we may use this knowledge to pass in arguments in a
  particular order, when certain of those arguments will affect the
  behavior of parsing subsequent arguments. but it may be the case that
  such generally such scenarios should be avoided.

  [#br-049] is a particular case where we leverage a hard-coded
  positional hack in order to parse a depended-upon argument to affect
  the behavior of the subsequent parsing of the other arguments (and
  note we do this by appending it to the end).



## summary

iambics will not replace anything (yet), but as an experiment they have
proven fun and interesting enough to stay around for a while, in this
universe at least.



## references

   [DSL-vs-natural-language]: http://pragdave.me/blog/2008/03/10/the-language-in-domainspecific-language-doesnt-mean-english-or-french-or-japanese-or-/
