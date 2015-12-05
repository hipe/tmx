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
the [ca] autoloader is being used on the participating modules (an
assumption that is however fair in this universe).




## line-by-line

we do *not* use the default `inherit` value of `true` here - to do so
would expose us to the possibility of flickering failure based on
whether or not a parent class has loaded its own (any) custom item or
not yet. (this has certainly happened.)

if that is what you actually did want, set the const in your node
explicitly.

if the const was not defined immediately inside of us, then peek into
the filesystem, assumes [ca] autoloading. (note this peek is performed
on a cached directory listing that is typically created earlier.)

the last-ditch fallback is to load an item with this same name from the
"CLI support" node..
