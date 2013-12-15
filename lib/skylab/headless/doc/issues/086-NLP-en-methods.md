# NLP EN methods :[#086]

multiple above functions take a numerish as an argument. by "numerish"
we mean "something we construe a count from" e.g an array is construed
as numerish here because we construe a count from its length.

each such function is here wrapped as a method that memoizes each last
used numerish argument so that it doesn't need to be resubmitted to
subsequent calls that would otherwise take the same argument. this can
make articulation code more readable, depending of course the natural
language and the articulation. compare:

  "#{ both a }the following thing#{ s a } #{ s a, :was } missing:"

  "#{ both a }the following thing#{ s } #{ s :was } missing:"

the cost of this is storing the numerish in an in ivar, which is why
these are methods and not functions. use with caution: no mechanism is
here provided to "clear the cache" to safeguard you from
unintentionally re-using a stale "numerish" in a syntactically
external articulation.

also a numerish might hold `nil` or `false` which variously may have
special meanings (e.g `nil` might tell a function "substitute some
default for `nil` whereas `false` might mean "substitute the default
iff this is is a terminal node in the callstack, otherwise propagate
the value `false`!).
