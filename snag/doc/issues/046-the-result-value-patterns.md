# the result value patterns :[#046]

(EDIT: ancient!)


## introduction

this is along the lines of both the spirit and form of [#br-114] the
common triad of result value meanings, but is concerned especially with
result values as they pertain to the result values of callbacks.

in particular we like the idea of *some* callbacks being able to
determine the final result when it might be useful to do so. (this is a
bit like [#ca-040] the callback pattern.)

but as another side of the same coin, we must be sure that the results
of callbacks don't affect our logic when we don't want them to.



## the conventions

### a callback's error result may be resulted as-is  :[#049]

it may be convenient for callers to determine their own set of possible
results via the delegates they pass in to the call.



### a true-ish from an error handler may be ignored and become false :[#017]

sometimes with the result of error callbacks, if the callback did not
result in false-ish we result in false. so:

    when the callback results in: |  we result in:
                              nil |           nil
                            false |         false
                  [anything else] |         false

this is because per [#br-114] we may sometimes use false-vs.-nil to
determine whether or not an "apology" for the error (or invite or the
like) has yet to be issued. (typically, when it is false it means that
the UI has not yet emitted anything acknoweldging this as having been a
failure to fulfill the request; such that any caller at any point along
the stack may "intercept" this false and turn it into a nil by issuing
the appropriate UI signalling.)

because of the above, in certain places we do not want the error handler
to make what we perceive as being a failure appear as anything other
than a failure. ultimately, though, this is a design question as to
whether or not a method will employ this convention.




### a false-ish from a success handler may be upgraded to true-ish :[#062]

for a delegate to produce a value as a result of delivering an event;
this can be convenient but is not reliable.

because its ability to do this depends on things like whether or not the
delegate is synchronous (on a given channel) and whether its downstream is
one or multiple other delegates; i.e "the event model".

since at the time of this writing our delegate may either be of the
"ordered dictionary" variety or it is an adapter from a digraph-style
callback tree, we can't be sure that the result is meaningful.

so what we do in such cases is that iff true-ish we assume the
delegate-produced result is meaninful, otherwise we "upgrade" the result
to be meaninful (i.e the success value).




### a callback's error result may be ignored entirely :[#048]

sometimes it may be necessary for internal logic to be correct that the
result value from an error callback be ignored entirely, because for
example we have meaningful distinctions between nil and false that must
be kept for internal caller logic to stay intact.

in places marked with this tag, if ever it is desired to employ a
different pattern, it is strongly encouraged that you write tests to
cover error callbacks with results in all three [#br-114] categories to
be sure that our logic isn't exposed to getting broken by the callbacks.




### result values from "info" channel callbacks must be ignored :[#047]

the "info" event channel is intented for auxiliary events that add
supplemental information, as opposed to events with any make-or-break
finality. as such it doesn't "feel right" to allow this channel to
determine logic flow. we posit this as a rule here and now that the
information channel can never be used to deliver meaningful result
values of any kind ever.
