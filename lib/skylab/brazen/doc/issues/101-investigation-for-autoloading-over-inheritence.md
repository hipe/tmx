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
the [cb] autoloader is being used on the participating modules (an
assumption that is however fair in this universe).




## :[#.A]

do NOT inherit here - to do so would lead to the client's custom expag in
file not loading IFF the fallback expag has already loaded!

(when things first start up, [br] doesn't know that an expag class will
exist under its "CLI" because it hasn't asked for it yet so the file
hasn't been loaded. however, once anything in the system has loaded this
node, that const will be set under [br]'s CLI module, and so to inherit
the const resoution here will do one thing or another based on whether
this or any other application has loaded the fallback expag class.
nasty.)

a few lines down, we effect inheritence-like behavior "manually" (but
only along the class sub-chain, not the full ancestor chain).

_
