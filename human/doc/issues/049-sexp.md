# sexp :[#049]

## context

this is working towards an assimilation and/or repackaging of [#034] and
[#044], related to "expression frames" and "expression strategies"..




## catalyst, objective & scope

this was prompted because

  • we want a system that was easy to write expression "pre-articulations"
    for without having to think about API's -

  • we want the "intermediate representations" of our articulations to be
    plain old arrays and "atomic-esque" values.

  • we want a univeral syntax for such sexps so that different *expressing*
    agents all throughout the universe can express themselves with this
    "standard" (platform-native) format without having to know anything
    about the particular dependency of the ultimate *expression* agent.

    (rather, we will try to develop an API for the sexp syntax..)


if this succeeds we would probably want to drawn-in ("assimilate") other
sibling nodes in this library, perhaps making this node be en entrypoint
to the other facilities. (noted at the end of this document.)

so..

  • what occurs in conventional output as a "line" will correspond
    ideally to a sentence (except when what is being requested is at a
    sub-sentence level). (we will go ahead and add a newline to
    terminate each of these, because it's useful to have such a thing
    for some purposes. however, newlines (and whitespace) may occur at
    the sub-sentence level depending on the expression agent, for
    example to express a list as a bulleted list.)




## imaginary examples

whereas in the old way we might say,

    Common_::Oxford_and[ %w( foo bar baz ) ]  # => "foo, bar and baz"


in the new way we might say,

    Home_.say :list, %w( "foo", "bar", "baz" )  # => (same)


the old way and the new way take about about the same amount of code to
accomplish the same thing, but the new way has these advantages:

  • wheras in the old way the "data" was essentially ['foo', 'bar', 'baz'],
    in the new way we have added a tag to it: [ :list, ['foo', 'bar', 'baz']].

    there is now an element of "semantic tagging" as an intrinsic,
    explicit part of the data (rather than being an implicit par of the
    call we made in the first example).

    as the data travels around, this tagging (of `:list` in the example)
    travels with it, which will be useful to various expression agents.

  • this act of articulating forces us to go through the more general
    `say` method rather than using the ad-hoc `Oxford_and` method. if we
    cared to, we would see that `say` is a thin wrapper to facilities at
    `EN`. this way, we hopefully consider that every time we use `say`
    we expressing something in an un-international way.




## imaginary implementation

the "sexp expression agent" will be an at first massive, monolithic (and
later configurable) filesystem tree with one node for every part-of-
speech-type-thing we want to express.

_
