# About Tags in tmx code :[#011]

## prependix-A: semantics of particular tags

    #hook-in etc: for a library node to declare a method as a
        "hook in" node it is an explicit acknowledgement by that library
        that the method may be overridden by client nodes to customize
        the library's behavior. as such, such a tagging implies that the
        behavior (rougly), semantics, and most importantly *name* of the
        method are bound to the public API of the library.

        `:#hook-in`, `:+#hook-in`, and `:+#public-API #hook-in` are all
        variations on the same expression, that is a declaration of this
        classification.

        `#hook-in` (without the leading ":") is an indication that such
        a method is being overridden: this form is used by the client
        module, not the library module.


    #hook-out etc: a "hook *out*" is similar to a "hook-in" but the
        library itself does not supply a default implementation for this
        method. as such, the library will not work unless the client
        node implements this method, and so the client node must
        implement every such method itself.


    #hook-with: this is a method provided by a library as a courtesy, as
        a method that might be used as an implementation for a "hook-out"
        or "hook-in". the library iteslf does not call this method.


    #hook-over: this is a special kind of "hook-in" that itself does
        nothing (i.e results in nil). if a client overrrides such a
        method it may do so knowing that the library method itself has
        no side-effects.




## introduction

Tags are used to mark definitively a certain kind of thing (1) at a
certain particular place (2) in text-based documents.

Tags variously occur with a leading '@' or a leading '#'.
(EDIT: '@' is deprecated).

They occur variously in code and other version controlled text
documents.



## the structure of tags

currently (although this may change) tags look like hashtags alla
twitter, but they can contain dashes. the reason we added support for
dashes is that we feel they look better than the other conventions in
use for separating works within a hashtag (namely #camelCase,
#nothingatall).

a more rigid specification for tags is that they may consist only of
alpha-numeric characters (and dashes but more on this below). whether
or not they are case sensitive will depend partly on the client; but for
now we code around the assumption that we will most likely want to
employ case sensitivity at first unless we have some good reason not to
:[#043]

dashes may be used to separate for example words in such tags (so dashes
may *not* occur at the beginning, at the end, nor more than once
contiguously).

examples:

    #good-tag  good: dashes can be used to break up words
    #-bad-tag  bad: dashes at beginning not allowed
    #bad-tag-  bad: dashes at end not allowed
    #bad--tag  bad: multiple dashes not allowed

    #2014-ok   good: numbers can occur anywhere in the tag



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
