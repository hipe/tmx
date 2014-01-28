# the first plugin library :[#077]

see [#070] the plugin libraries narrative for a high-level view of all the
plugin solution in this universe and how this one compares to and contrasts
with them.



## original introduction to the post _Clean Code_ rewrite

(note that this content was moved here from the code node, for those seeking
its history.)

chatty historical note: this is the first node in the skylab universe ever to
be [re-] written using the Three Laws of TDD. we couldn't resist engaging in
the exercize in light of both the growing scope of responsibility for this
node and the fact that we had just read martin's _Clean Code_ [#sl-129].
falling under the spell of its dogma has another side-effect: we (again) cut
back down on method-level comments, limiting them only to those methods that
are part of the node's public API, if that (something we used to do until the
"functional period" whose start roughly coincides with the birth of metahell).
excessive effort has been expended to make the corresponding spec for this
node serve as comprehensive API documentation (or at least, a source for it).)

here we use "contained DSL's" [#mh-033] implemented using coduits et. al
[#078], API-private modules [#079]. we write in narrative pre-order [#058],
broken into facets [#080].




## the `initialize` method in plugin clients

it makes life much easier for the plugin implementor to know that there
is no hidden magic specifically with the `initialize` method of her
plugin client class.

although there may or may not be magic with regards to including
automatcally our plugin client instance methods module to the given
client class, we hereby promise not to add an `initialize` to your
ancestor chain, neither in the plugin client instance methods nor
in any plugin client base class if we ever use one.
