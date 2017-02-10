# :[#101]

## objectives

the emerging goal of this investigation is to find an acceptible way to
allow clients to customize their app's behavior by simply adding files
to the filesystem and/or setting a const under a particular module (e.g
by writing a class).

(in the old way, when a client wanted to customize a component class,
the client had to override an accessor method for that class to tell the
lib to effectively trigger autoloading for that node.)

the ugliest part of our emerging solution here is that we assume that
the [co] autoloader is being used on the participating modules (an
assumption that is however fair in this universe).




## about the code generally

  • if this isn't used on a client subclass of one of our pantheon
    classes (those in [#002]/figure-1), behavior is undefined.

  • we do *not* *ever* use the default value of `true` for the
    `inherit` parameter in the calls to `const_get`: this can cause
    nasty flickering behavior because it is vulnerable to the arbitrary
    and volatile state the *parent classes* are in with regard to
    whether or not something has been autoloaded yet. :gotcha-A

  • we use "known knowns" here so that the client can set explicitly
    a false-ish value for a const, and have that value float all the
    way up to be the value that is used for whatever the thing is.
    (we don't know if this is needed now but it has been in the past
    and may again be in the future.)

    for example, to set your 'Expression_Adapter' const to `nil`
    might be a way to say "i definitely don't want to use an expression
    adapter; neither my own nor the default one."




## pseudocode (maybe just an example)

if we have already cached a value for this const, use that.

otherwise we will cache whatever value we end up getting from the below:

if there is a const defined directly in the client class (and
it already loaded), use that.

otherwise, if it looks like there is a file that defines this const,
use that.

otherwise, as a default case assume that "CLI support" has an
appropriate value for this const.

  (true for: `Actions` ..)
_
