# the architecture :[#002]

## design objectives

in effort to create an architecture that is as fun as possible to work
with while not chaining ourselves to any one image producing backend
we experiment with a new sort of implementation for our [ac] "reactive
model".

(EDIT: the below hasn't been updated to fit with [ac]/[ze] and is still
in a [br] frame of mind. by #milestone-8 let's rework the language. the
underlying ideas will probably still hold.)

in a typical a [br] application the "models" node is simply a ruby
module constant with different "reactive nodes" in it as other
constants. in this application the reactive tree will be highly dynamic
somehow.

in this way we will achieve a dynamic interface that changes based on
what the selected adapter is.




## key points about adapters

  • in order to get this application to produce an image through some
    image-producing "backend", someone will have to implement an "adapter"
    for it with code. today we implement an adapter for ImageMagick.
    tomorrow we may make one for TeK somehow.

  • we use this "adapter pattern" so that our application code is not
    tightly coupled to our backend choices.

  • there will only ever be zero or one active adapter at a time. we
    may refer to the active adapter (if any) as being "selected". to say
    "selected" is the same thing as saying it is active.

  • an adapter is effectively a list of components that get injected
    into the application. the adapter then attempts to build and set
    the background image whenever all the data changes and all the
    required components are present (see [#004]).




## detailed points about adapters

  • we want the user to be able to switch adapters without losing
    adapter-specific data. (that is, we want the user to be able to
    switch from adapter A to adapter B, then back to A. when the user
    is back to A the same data should be there as before.)

  • we could either do this thru persisting one structure per adapter,
    (probably all in the same file) or by doing the below. we chose the
    below because it is more novel.

  • we say that [..] "adapter agnostic".




## the "installation"

here we have a dedicated "model node" (experimentally) *as* a sort of
singleton that wraps low-level access to system-related things, like
what fonts as installed and what paths to use for files for persistence.
this is very hacked and non-configurable for now.

(later this choice would prove fruitful for some stubbing during tests.)
_
