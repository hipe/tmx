# About Tags in tmx code


Tags are used to mark definitively a certain kind of thing (1) at a
certain particular place (2) in text-based documents.

Tags variously occur with a leading '@' or a leading '#'.

They occur variously in code and other version controlled text
documents.




## Comprehensive list of tags with descriptions and usage guideines

(presented without leading '#' to avoid a false match)



### The "todo" tag

It would seem that this most frequently used and most ostensibly
self-explanatory tag would need bear no further scrutiny.  Wrong!
The freewheeling days of willy-nilly "todos" ends now!

"todos" run the risk of becoming lingering open loops that don't
ever go anywhwere and go stale, sometimes hanging around for a year
or more; unless: we see them as an actionable item in an inbox
that needs to be processed and synergized "immediately!"

Their value is fourfold: they (1) indicate a call to action, that
further processing should be taken, (2) they stand as a physical
placeholder, associating an atomic point in the codebase with an
idea (3) they warn readers that something possibly strange or
significant is going on (4) they free the reader, if she sees it
at first for herself, of needing necessarily to worry about the
issue right then and there.

(1) is sort of an energy drain, ("should i deal with this now?")
where as (4) is great, it lets us roll past a possible code smell
without needing to drop what we're doing and deal with it right
then and there.

So, mitigating (1) and towards (4) is this: 

#### Turn "todos" into "pending" or "refactor" etc

[..]


So in conclusion, "todos" are a great step towards beautiful code,
but they are only a first step!


### Indicating dependencies in code with other issues

stating that one actionable thing should happen before or after
another thing **in code** should be done with extreme discretion.
these things are so volatile, they can easily go stale quickly, and/or
if they live in the code they can lay around for months or longer,
possibly causing confusion or mis-information in the future. The general
spirit of planning/contingency analysis has value, but consider instead
melting such a comment into a ticket and having the battle over
depencies and pre-requisites there instead. while code is a poor
fit for this kind of discussion, it is precisely what the
issue collection exists for.
