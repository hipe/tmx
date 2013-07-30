# confessions of an ambiguous grammar

NOTE - it bears pointing out that the grammar for this utility is
ambiguous. it draws symbols from both the set of available action names
and the set of existing subproduct names, such that how your command is
interpreted will depend on both of these at the time it is run, with
tokens you intend as subproduct names possibly getting masked by (and
interpreted as) action names.

there is no solution yet implemented for this problem (for whenever there
exists as an input token a token that looks like an action name that
action will be popped off the input stream and added to the action queue
as long as such tokens exist at the front of the input stream), but at
present the problem is not a problem because there is no set union between
the exponents of the two namespaces, (that is, there is no name that is
shared by both action and subproduct name) hence the grammar is de-facto
unambiguous, but only by sheer dumb luck.

the solution (if ever needed) will likely be adding the one line of code
necessary to let "--" separate these two nonterminal symbols.
_
