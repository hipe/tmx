# argument arity thru singplur :[#026]

([#fi-014] "arity" is a prerequisite for understanding this document.)

## synopsis

we specify "argument arity" by specifying a "singplur pair".




## factors and consequences

towards the [#002]:DT4 conservatism, we don't want to evaluate the
association definitions if we don't have to. for a simple API call,
for example, it should not be necessary to load every declared component
(or parameter in some contexts) in order to know if a given symbol name
is a valid name for a component. rather, it should be possible to ask
"yes or no?" just for that component.

similar to the ER modeling concept of "cardinality", what we generally
call "argument arity" is expressed in an ACS definition only obliquely,
by use of these `singplur` specifiers.



### how this pertains to modeling:

  - the plural association will automatically given an argument arity of
    `one_or_more`. (:B and an :#API-point)

  - the singular side should be the one that specifies the "component model"
    (i.e the proc or class that does the normalization to result in an actual
    object or value for storage).

    this way "feels" more natural - if you're validating a list of N things,
    very frequently this is simply a matter of validating one such thing N
    times, for each item in the list.

  - the plural side *must* defer to singular side for definition of the
    component model. (see #here)

  - it is convention to specify the plural association immediately above
    the singular association (but it is not strictly necessary to do so.)



### how this manifests specifically in (volatile) storage:

if an association specifies that it `is_singular_of` another association,

  - with such an incoming ("atom") value from the client, the higher-level
    concerns may decide variously to employ "aggregating" semantics or
    "overwrite" semantics as appropriate for the modality. (:A)

  - the storage implementation (e.g ivars) should probably decide only
    ever to store the values in the "slot" corresponding to the *plural*
    counterpart, and never use the "singular" slot for storage.

    (since the thing could possibly be many things, the agent that is
    reading the slot should always assume it's a list (probably array),
    even if only thing was specified.)

likewise and conversely, if an association specifies that it `is_plural_of`
another association,

  - higher-level clients should only ever send down to such lower-level
    components array values for these. the onus should not be on the
    application to verify this.



### how this manifests in normalization:

  - when doing normalization and validation, we should assume that we
    are following (A) above, and that the plural slot is being used
    for storage, and in effect there is no singular slot. as such, for
    normalization we will check if the parameter is the singular side of
    a `singplur` pair, and skip it if it is.  (:#note-1)




# how this pertains to expression in interfaces:

(client expression is mostly outside the scope of concern of [ac], but since
it seems superflous and fragmented to have two documents about `singplur`,
we'll make some suggestions here):

  - we anticipate that generated API clients will want to support both
    the singular and plural counterparts. this makes the "iambic arguments"
    more readable, when they are utilizing variously the singular or plural
    form. (but note that any singluar form could always be re-written to
    use the pural form instead.)

  - we anticipate that generated non-interactive CLI's (niCLI's) will
    (when expressing the parameter as a switch) only want to use the singular
    form and do aggregation semantics. (like `ruby -r foo -r bar` - "bar"
    doesn't overwrite "foo"; rather, both are expressed.)

    if instead the parameter is expressed as a positional argument, it
    follows that it must be a glob argument, and will probably want to use
    the singular moniker -

        usage: my-app frob <file> [<file> [..]]

    but this is an interface design decision that is not up to [ac].

    (nontheless, to support this we have a special method at :#note-2)

  - as for iCLI and GUI's in general

      - iCLI has its own special thing for this




## asymmetry

this is why the [ac] has a `flag` macro but no `glob` macro - because
`flag` alone can degrade or upgrade up and down the various modalities,
however `glob` alone does not degrade down to a generated API client -
the "[ac] way" is for an API client to support both forms (singular or
plural), and for its ease of parsing implementation (and performance)
it is necessary that both associations are specified.




## edges and caveats

  - specifying one side of singplur pair without the other, this is
    undefined. it may fail silently or in strange ways.

  - specifying a component model on the plural side of the arrangement
    is undefined. (:#here)



## un-limitations

note that if you don't like any of this, you can still define a component
association
