# all the letters of the alphabet :[#130]

a - array! used often as a variable suffix and standalone.
b - rarely used. not used for boolean or block, because of the confusion
    therebtwn. *occasionally* used when storing a generic pair, like
    `a, b = call_some_thing` but eew.
c - occasionally used to hold a "constant" - that is, a symbol that represents
    the local name-part for a constant, eg `:Bar` for the "Bar" in Foo::Bar
d - integer! `i` is already taken, as will be explained; so we borrow this
    meaning for 'd' from printf() - however the heck it arrived at that.
    sad but true. mnemonic: "[d]oh! why does this stand for integer?"
e - error, e.g exception. most often seen as `rescue ::RuntimeError => e` but
    often we see it also as a formal parameter in a error handling lambda.
f - if you have to use it, use it for "float", not for "function" (see `p`)
g - not used, unless it has business meaning
h - hash! often used as suffix or standalone for an object we interact with
    in a hash-exact manner.
i - symbol! with ruby 2.0's introduction of %i( .. ) we now make heavy use
    of this to stand for `intern` (Symbol). seen very often as a suffix,
    and standalone
j - nope. (this isn't C - we don't have nested for-loops)
k - *rarely* used, but sometimes it holds actual class object (from `klass`).
l - no way - never use this because it looks like a one.
m - sometimes used to hold a symbol method name, or an unbound or bound method.
n - rarely used to hold an integer count of something ("number")
o - as a standalone name, often used to look pretty for various DSL hacks.
    vary rarely used as a variable suffix to emphasize that something is
    an object, (e.g `method_o` probably has a bound method, not a symbol)
p - proc! as both standalone and as a varible suffix, we use this a lot to
    represent something that is callable - a block, bound method, etc.
q - nope.
r - often used to hold whatever final result will be the result of the method
    or proc you are currently int. (used to be `res` but we are unifying this)
s - occasionally used to mean "string", both as suffix and standalone. should
    be used when there is any doubt whether something is a string (e.g  the
    's' is redundant in `msg_s`, but it is not in `name_s`).
t - nope. i suppose maybe a ::Time
u - nope.
v - nope.
w - nope.
x - very often used as standalone or as a suffix to emphasize that the variable
    is tainted - that it, that it is some un-normalized mystery value that
    came in from some kind of "outside"; and we have no idea what class it
    is of (or there is some known unknown of which of several classes it
    must be)
y - used often as a standalone name for something (almost always an argument)
    that is interacted with in an ::Enumerator::Yielder-exact way, i.e the
    -ONLY- thing we do with it is send `yield` (alias `<<`) on it.
z - nope. (has very rarely been used to hold the index of the last item in
    an array, that is, length - 1).

the most important things in this list are `a`, `i`, `p`, `x` `y`

happy dark hacking
