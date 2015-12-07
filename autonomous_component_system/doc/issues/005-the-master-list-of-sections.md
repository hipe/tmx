# the master list of sections :[#005]

## introduction

after having used this "system" for only a brief time, we can vouch to
ourselves unequivocably to its usefulness.

here we provide in some detail a "master list" that dictates *strictly*
how the "major sections" (those that have "--" before the title) are
allowed to appear in any and all code files for components, in terms of
these rules of usage:

  • their order with respect to each other
  • the superset of their wording (see more on this below)
  • their constituency (there can be no "major section" not listed here.)
  • note: empty sections can be listed/omitted at author's discretion.

we provide the list first and then in the following sections we will
explain the exact rationale behind its structure.




## the master list (12 count)

  • Construction methods  (often used to separate introduction & code)
  • Unserialization intermediaries
  • Initializers

  • Expressive event & Modality hook-ins/hook-outs
  • ACS hook-ins (not signal handling)

  • Operations / Human exposures
  • Components
  • ACS hook-outs (e.g primitive operations)

  • ACS signal handling

     (go from mechanical to informational,
      and within that from negative to positive.)

  • Project/Custom hook-ins/hook-outs/readers  (these often support the above)

  • Support  (anything used across sections)
_




## rationale for rules of usage


  • keeping these in the same order across files allows them to
    become landmarks for each other.

  • using these same, distinctive typographic conventions for all the
    section names from this master list (in concert with the last point)
    lets you find sections without having to read them.

  • using the same wording in the sections allows easier searching,
    to jump to the appropriate section quickly.
    you can remove words from the formal label.
    you can add words IFF they occur within the optional set of
    parenthesis that tails your label, which can be added for this purpose.

  • this won't work unless we're consistent with its application.
    hence if a major section wants to be added, it should be integrated
    in with this document.

    it will be fine to refine the names of sections: but we must apply
    the rename uniformly.





## ordering criteria

in order to reinforce the principles we'll offer here, in the above
depiction of the "master list" we have used whitespace to group together
visually each cluster of sections to suggest that they are somehow
semantically related.

we provide further detail here explaining their ordering
because knowing the underlying rationale behind the ordering can
act as a mnemonic for its correct application, and as a guide for
its improvement.

this "master list" represents the coalescence of several ordering
rationals listed here. these below "rules" are themselves perhaps
presented in a way that dictates their relative priority to one
another.

  1) (not part of the master list) support nodes larger than half
     a screen should come after the main flow, perhaps with a
     repetition of the relevant "master list" sections. those
     less than half a screen *can* appear "inline" at author's
     discretion.

  2) concerns about constructing, initializing, unserializing etc
     should come first.

  3) "support methods" should go below all methods that in the same
     file call them.

  4) generally "higher-level" concerns will come before "lower-level"
     concerns (to the extent that that has strong meaning.)

  5) methods with less "moving parts" go below those with more
    "moving parts". (partly this is to keep the interesting methods
     towards the top. sometimes this occurs as a side effect of
     (3) and/or (4).)




## the application of our ordering rational justified (where not obvious)

  • "modality" concerns are by definition "higher-level" than others.

  • "expressive event" is lumped in with the above
    because it's so similar

  • "ACS" hook-ins are otherwise similar to non-ACS hook-ins above.
    also, they often relate to what comes next.

  • "operations" are more "special" than components typically?
    so they are higher-level feeling.

  • although "human" exposures (namely The Edit Session) are "higher
    level", supporting this feels so much like supportion operations
    that we group them together.

  • operations and components "feel" simlilar b.c ACS DSL

  • signal handling (by definition) will occur only ever
    because of the section directly above

  • project hooks often support all of the above
_
