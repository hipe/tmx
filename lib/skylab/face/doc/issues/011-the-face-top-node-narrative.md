# the face top node narrative :[#011]



## #magic-touch :[#046]

local metaprogramming tightener for this pattern
(tracked as [#046])

:#magic-touch is an #experimental facility for lazy-loading libraries based
on when particular methods are called (EDIT: we don't like it any more).

how it works is given

  module [ :singleton ] ( :public | :private ) method [ method [..] ]

and given a function that loads a library that overrides those methods with
new definitions of them (yes, read that again); this makes stub definitions
for those methods that, when any such method is called it loads the library
(which hopefully re-defines this method), and then re-calls the "same" method
with the hopefully new definition.

i.e this allows us to lazy-load libraries catalyzed by when these particular
"magic methods" are called that "wake" the library up. failure of the library
to override these methods results in infinite recursion. this feels sketchy
but has several benefits to be discussed elsewhere.



## :#vertical-fields

general purpose application tree configuration API.

(EDIT: this has progency elsewhere. but is still kind of nifty, if obtuse)

you create one SET_ function at the top-ish of your library, after you've
declared some proxy classes or mechanical classes (the workhorses
of the matryoshka doll [#040] stack.) you create it by giving it an
ordered list of symbolic names representing your proxy classes, and then
a hash with the classes themselves keyed to those names:

    SET_ = Vertical_Fields_.new( [:hi, :mid, :lo], hi: App, mid: NS, lo: Cmd )

when you want to add a field to your stack, you call your SET_ function
with a symbolic name for the field, perhaps a default, and perhaps a
`highest` and `lowest` markers (using the symbolic names for the proxy
classes you set above), indicating the top and bottom of the call chain:

    SET_[ :timeout, :lowest, :mid, :default, 30 ]

the call to the SET_ function will then **add methods** to your proxy
classes to manage making them locally settable and globally accessible
to each other as appropriate. in the example above, the classes `App`
and `NS` are both given setters named `set_timeout_value( x )`. `Cmd`
is not touched because it was not within the range that was determined
at the bottom end by the `lowest` directive, which said `mid`, which is
`NS`.

`NS` is then given a getter method `get_timeout_value` which results
in the value of its ivar `@timeout_value` IFF one is defined. if such
an ivar does not exist, the `NS` will delegate the call upwards..

(#todo more on this..)

to quote that guy from Mackelmore, this is really quite awesome.
