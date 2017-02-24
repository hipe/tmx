# About Tags in tmx code :[#011]

## prependix-A: semantics of particular tags

   the members of the "hook" family of 5 tags described below are
   typically used in a parent-child sort of way, where one "declaration"
   tagging may have several corresponding "reference" taggings
   (explained below). as well, the members of this family of tags
   are typically used in cases where this parent-child association
   crosses some sort of library (usually sidesystem) boundary. if this
   doesn't make sense then it need not do so at this time.


    #hook-in etc: for a library node to declare a method as a
        "hook in" node it is an explicit acknowledgement by that library
        that the method may be overridden by client nodes to customize
        the library's behavior. as such, such a tagging implies that the
        behavior (rougly), semantics, and most importantly *name* of the
        method are bound to the public API of the library.

        `:#hook-in`, `:+#hook-in`, and `:+#public-API #hook-in` are all
        variations on the same expression, that is a declaration of this
        classification. (notation is described more below.)

        `#hook-in` (without the leading ":") is an indication that such
        a method is being overridden: this form is used by the client
        module, not the library module.

        a kneejerk response to this might be "well, duh: you can
        override any library method you want to anytime anywhere". but
        without an assurance that the library method name won't change,
        then it probably will change and will probably break your code
        in ways that are hard to track down.

        mnemonic: you can hook "in" to the library if you want.


    #hook-out etc: a "hook *out*" is similar to a "hook-in" but the
        library itself does not supply a default implementation for this
        method. as such, the library will not work unless the client
        node implements this method, and so the client node must
        implement every such method itself.

        when using the declaration from as opposed to the instance
        form of the tag, it is recommended to use the full formal form
        `:+#hook-out` (":" meaning "declaration" and "+" meaning
        "one of many). this is the most correct form to use, and for
        this tag expecially it will be useful to use consistent notation
        so that we can gather all such method names; becuase of how
        crucial it is to implement them.

        mnemonic: the library must reach "out" to your code to work.


    #hook-with: this is a method provided by a library as a courtesy, as
        a method that might be used as an implementation for a "hook-out"
        or "hook-in". the library iteslf does not call this method.

        mnemoic: implement your method "with" this one.


    #hook-over: this is a special kind of "hook-in" that itself does
        nothing (i.e results in nil). if a client overrrides such a
        method it may do so knowing that the library method itself has
        no side-effects.

        mnemonic: program flow just passes "over" this method.


    #hook-near: when used as declaration, indicatates that this method
        name should not change because other semantically similar
        methods use this name in order to reference this method.
        when used as a reference tagging, indicates that this method
        is named after one that does something similar.
        however and perhaps, this is done only for the purpose of
        self-documentation and consistency; because calls to these
        methods are sent from different structures to different
        structures in different places in the code.




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
melting such a comment into a reference and having the battle over
depencies and pre-requisites there instead. while code is a poor
fit for this kind of discussion, it is precisely what the
issue collection exists for.
