# API action formal parameters formal structure syntax :[#023]

## what's with the ridiculous name?

It's a mouthful but here's the justification for the long name of this doc
node ("api action formal parameters formal structure grammar"), broken into
pieces:

  `api action` - not to be confused with an action as modeled in a different
    modality. (and still we didn't say whether this means "formal" action
    or actual action (instance)).

  (for an explanation of `formal` vs. `actual` please see [#fi-025].
   familiarity is hereafter assumed.)

  `formal parameters` - the parameters we're talking about here are `formal`,
    not to be confused with `actual` parameters.

  `formal structure syntax` - if we just said `structure syntax` we could be
    talking about the structure syntax [#hu-003] of the formal
    parameters of the particular formal action!..

.. because we say `formal paramters formal structure syntax`, we are defining
the entire set of all allowable parameter signatures (lists of formal
parameters) for all formal actions (API actions, that is)!

if the above means nothing to you then you probably don't need to continue
reading ^_^, and consider yourself lucky.

## so what the heck is the general structure syntax for every API Action
  signature in the universe?

first off, below we will rely heavily on our informal calculus of
`the structure syntax` [#ba-006], a calculus that we are developing in tandem
with this; a calculus that was created with the primary purpose of bolstering
(allowing even) this structure syntax presented here.

(that document in turn spun off into "approaching a pattern language for
semantic structures" [#hu-003] which is also relevant reading.)

second off, let's be clear: there are at least two structure syntaxes we
care about here:

one: the relevant structure pattern of the request. (remember it is `logical`
structure that we are concerned with, not the `physical` one [#ba-009].)

two: the "formal structure syntax" of any API action's interface, which will
be the focus of this document.
