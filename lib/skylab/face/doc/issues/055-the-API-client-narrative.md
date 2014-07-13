# the API client narrative :[#055]

## intro

this document was created after the face API client implementation was several
generations old, so keep that in mind.


## :#original-intro

`API::Client` - experimental barebones implementation: a base class for
your API client. perhaps the only class you will need. the first last
attempt at this, and the last first one. the light. the way.

the enhancement method is a private experiment. #idempotent. this is the
experimental implementation of `Face::API#[]`. this (re-)affirms that you have
under your `anchor_mod`:

1) a module called `API` (maybe M-AARS-y).
2) a const `API::Client` that is M-AARS-y. (if you do not have such a
  const, one will be provided for you in the form of a subclass of
  Face::API::Client.)
3) an `invoke` method "on" your `API` module.
4) an `Actions` box moudule - M-AARS-y and B-oxxy

using `touch` for this attempts to load any releveant file first.





## :#storypoint-30 :#the-invocation-method-added-via-proc

this is the only method that is added by any means to the e.g 'API' module of
your application (hence we add it in this strange way rather than clutter your
ancetor chain).

in this sense this function is off the chain. (note too, an application may
want to manage its own version of the API client created below, rather than
call this; to leverage the several other options availble when creating API
executables not utilized here.) #raw-API

(incidentally this may be the first occurrence of what would later become
a [#hl-121] technique we rely on quite a bit in bundles.)


## #storypoint-100 the name error

we could keep it granulated but this is a hard error. you are not supposed to
recover from it. we articulate it like this just for dev courtesy



## :#storypoint-120

we have what we'll call "neighbor modules" whom we need to be able to access
at runtime to reflect on, make decisions, and load things to run. if you
really needed to you could change how these modules are accessed by either
overriding the generated method(s) below or setting the ivar but eew.



## :#storypoint-150 :[#017]

the API client is blissfully ignorant of events - the only thing you get from
a raw API call "out of the box" is its final result and whatever side-effects
it does. but if an event listener was passed in the field we simply hook back
to that. result undefined, raise on failure



## :#storypoint-185 the normalization method

we give the API action a chance to run normalization (read: validation,
internalization) hooks before executing. we want the specifics of this out of
the particular modality clients as much as possible.

if this gets called e.g from the method that gets the executable, and that
method has a unary/monadic/atomic whatever result shape we cannot express
arbitrary result values (e.g an exitstatus) from the particular API
executable's normalization failure.

this might be a good thing. it might be that if you need/want to have
arbitrary exit statii (or other strange results) from your normalization
failure, you should push that step down to your `execute` method, which was
designed from the ground-up to accomodate requirements like that.

given all of the above, and given that we are the last step in the API Action
lifecycle [#021], our result is then the result of our upstream caller -
false-ish or an executable.

currently writing to `y` just hooks back into the API action instance (by
sending it `normalization_failure_line_notify` with the selfsame arg that
`y#<<` received). this allows for evented handling of the message, e.g adding
meta-information about the action to the message.

(with the above said, please see [#019] for information about possible
future/possible current features of field-level normalization.)



## :#storypoint-210

some enhancements enhance your life by enhancing your entire API. the class
method(s?) in this section are created and exposed to be accessed by
enhancements such as these. That is, this is part of the API API [#022]

our API API is implemented via conceptualizing our API client as itself a
plugin host.



## :#storypoint-280

we want this to throw if set already - we want this to be write once because
we might cache things - otherwise it's clunky to check config for everything
