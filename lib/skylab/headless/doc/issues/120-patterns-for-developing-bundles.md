# patterns for developing bundles :[#120]

(the content here may get merged into the parent node after a futre branch merge)


## :[#121] bundle as methods definitions macro


### criteria

the bundle itself *is* a proc (as opposed to a module proto-fitted to look
like a proc), and that proc defines one or more public, protected or private
methods directly, in-line. typically these method defintions occur as if they
were being written oridarily inside of a module e.g class as opposed to using
'define_method' (or else the mechanics described here may not hold).


### properties and behavior / pro's and con's

its simplicity is also its crutch: this pattern is exactly the same as if
you had defined those methods on to your client module directly rather than
by employing the bundle. they are two different ways of doing the exact
same thing. the discussion below explores the ramifications.

• the pro
the reason we typically employ this pattern is because we don't want to
and don't need to clutter needlessly the ancestor chain of either/both the
client module and the client module's singleton class (with e.g a module
called "*_IMs" or "*_MMs" resepectively).

(as a historical side-note, this was in fact more or less the inspiration
behind bundles in the first place, was to provide a facility like this,
as should be mentioned in [#090] the introduction to bundles.)


• the con
the client class should not define its own methods for those methods created
by the bundle: for one thing it will generate warnings, for another thing it
means you are using bundles incorrectly.

if your client class will re-define the behavior of a method from one such
bundle, and that method is the only method in that bundle, then don't employ
the bundle at all, because there is no reason to. (note however child classes
of your client class will be free and unencumbered to re-define such methods.)

if your client class would re-define one of the methods of one such bundle
that has multiple methods, then we have a problem with a solution:


### scale-path: such bundles must scale regularly to modules.

as soon as the time comes that we had a regular old module in an ancestor
chain instead of this "bundle" nonsense, such a bundle must be written so
that it upgrades in a regular (i.e trivial) manner into a module. we lose
the advantes of such bundles as described under "pro's" above, but those
advantages in such cases have become now become liabilities when you get
to this point, and the bundle has now matured into its next phase.
