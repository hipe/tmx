# NLP EN methods :[#086]


## introduction

things about NLP here: 1) we put our NLP-ish subclient instance methods
*first* in a struct-box and then distribute the definitions to this i.m
module so that a) they can be re-used elsewhere independent of s.c but
b) our ancester chain doesn't get annoyingly long. 2) for those NLP
functions that inflect based on number (most of them) what we do here
different from our downstream (dependees) is we memoize the last used
numeric expressers (for the 'number' grammatical category) so that they
don't need to be re-submitted as arguments for subsequent utterance
producers, for shorter, more readable utterance templates.



## how :#these-methods handle numbers differently than their constituent functions

multiple of these functions take a numerish as an argument. by "numerish"
we mean "something we construe a count from" e.g an array is construed
as numerish here because we construe a count from its length.

each such function is here wrapped as a method that memoizes each last
used numerish argument so that it doesn't need to be resubmitted to
subsequent calls that would otherwise take the same argument. this can
make articulation code more readable, depending of course the natural
language and the articulation. compare:

    "#{ both a }the following thing#{ s a } #{ s a, :was } missing:"

    "#{ both a }the following thing#{ s } #{ s :was } missing:"

the cost of this is that we store the numerish in an in ivar, which
means the expression agent now has state, which is why these are methods
and not functions. it is a trade-off: use with caution, because no
mechanism is yet provided to "clear the cache" to safeguard you from
unintentionally re-using a stale "numerish" in a syntactically
external articulation.

also a numerish might hold `nil` or `false` which variously may have
special meanings (e.g `nil` might tell a function "substitute some
default for `nil` whereas `false` might mean "substitute the default
iff this is is a terminal node in the callstack, otherwise propagate
the value `false`!).
