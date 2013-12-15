# extension nodes? :[#046]

experimentally an "extension node" is a module that, when loaded, adds
constants to its surrounding ("parent") module!

although this flies in the face of tradition - and perhaps better judgement -
we are attempting it here because constnames are too damn deep and it muddies
the code's readability.

with the simple adding of a `touch` line at the beginning of a participating
file we can forgo one level of jagged-ness in the names, WITH THE PROVISO that
now there is tight coupling between the anchor node and the extension node!
they both need knowledge of each other's namespace!

for this reason, *all* consts added by an extension node *MUST* be API
private (and hence end in an underscore).

#experimental
