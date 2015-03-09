# the VCS adapter actor narrative :[#008]


## :#storypoint-5 introduction

(EDIT: this exact idea or one very much like it is what morphed into
[#cb-042] actors. to reduce code duplication we use that for this. in
this document we have replaced occurrences of "agent" with "actor" to
emphasize the lineage.)




### :#defining-actors-in-this-context

"actor" is our working title for this common thing: an "actor" in this context
is a low-level, smallish ad-hoc class that does something as part of a larger
effort. generally an "actor" (again in this context) is the smallest object
that still *does* something (as oppose to a pure data structure). they are
often shortlived, created just to resolve one value or one side-effect.


often "actors" are named after verbs and can be thought of as glorified
functions. (we might even start calling them "method classes"). often but not
always an actor at this level corresponds to one particular system command
executed against the VCS.

for example, our flagship action (called "hist-tree" currently) may leverage
three different `git` commands: `git-ls-files`, `git-log`, and `git-diff`. we
will probably create one actor for each of these steps; a class that will
both wrap the command and process its result into some structure that is
relevant for that particular "super actor" ("clent").




### quick note on scope

also, it bears mentioning that these actor classes will not be for general
use of these commands, but just for the specific uses as they are needed for
that particular action.

this is in contrast to something like 'grit', which was apparently about
begin a general-use library. for now, our work is specifically to the end
of this one application; with the thinking that to attempt otherwise at this
stage would become a casualty of early abstraction.




### actors in flux

we may generalize the particular actor class to be re-usable for different
applications of the same system command (for example the next time we need to
work with a `git-diff`). actors can even have sub-actors arbitrarily deeply,
it is up to them.

because these different actors for this VCS have so much in common (they often
correspond one-to-one with a single system command) we have gone ahead and
made base class for them, which is the topic of this document.

we have not however taken the extra step and made this a general base class
(or otherwise) that is for general VCS's (that is, a #VCS-agnostic actor
base class).  because we are far away from such an effort currently, it would
be an abstraction too early.

however, keep this in mind as we write it. we have made nothing `git`-specific
in this class and we intend to continue as long as it is reasonable.




# ::#storypoint-45

we must use `chomp!` and not `chop!` because git does not have a newline character
at the end of the final line in for e.g a 'git-log' with a custom one-line
output.
