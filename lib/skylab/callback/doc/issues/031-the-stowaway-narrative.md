# the stowaway narrative :[#031]

EDIT: large parts of this are legacy and will be removed.

## #introduction

the functionality in this node rarely sees use separate from [#031] the
MAARS node (which is recommended reading to accompany this document); but
we developed these nodes both in tandem and separately, and continue to
keep them separate because they are two distinct behaviors:

autoloading with autovivification simply refers to this one useful hack
(useful to us, anyway): if you refer to a constant that is not there under
a module that is an autoloader, the module will turn that constant name into
an :#isomorphic-filename -- that is, a file whose name is derived from the
constant name, but inflected to look appropriate as a filename:


### how is filename formed

it bears mentioning that this is not a perfect isomoprhicism: given our name
convention, constant names may LookLikeThis or LOOK_LIKE_THIS or
Look_Like_This, and they all belong in the same filename. a file called
"nsa-spy.rb" might hold NsaSpy, NSA_Spy, or Nsa_Spy. (and believe it or not,
in one dark corner we actually open the file to take a peek at the correct
casing of the name before the file is even loaded into the ruby runtime,
which is necessary to do for some deep, narrow tress and this autoloading
algorithm.)

we use-dashes-in-filenames and not_underscores because of the fact that
it looks unequivocably better. (but still we use _spec.rb in our test
because it is the default, and although this makes everything look horrible
we stubbornly stick it out because of how strongly we feel for the dashes.)
we could bend the autoloading behavior to anticipate the possibility of
filenames with underscores but we are not going to, again because of how
strong our passion is for filenames with dashes.


### when file is not there

what we've described so far is just plain vanilla autoloading. what makes it
"autovifying" autoloading is what happens when the file is not there but
the directory is there:

    my-app
    ├── core.rb
    └── foo
        └── bar.rb

if you are in "core.rb" (which defines MyApp), you could then load
MyApp::Foo::Bar even though there is no "foo.rb" to load. the autovivifying
autoloader assumes that any directory immediately under it for which there is
no corresponding file, that it is OK to go ahead and create a module with
a name based off that directory name. (here you can even pick your naming
convention: "biff-baz" can become BiffBaz or Biff_Baz. #todo:explain-how)

note that with this form of autovivification that is not the recursive
variety, the module that is created is itself an autolaoder, but it does not
then propagate this magic downwards to the child nodes it loads ("bar.rb"
above). that is what [#031] MAARS is for.



## :#the-stowaway-experiment

the `stowaway` facility :[#030] facilitates the dubious behavior of specifying
that a given module (if needed) is to be loaded by loading a file other that
the file you would expect to find the module in, given the name of the module.

while this is tautologically in violation of [#029]:#isomorphic-file-location,
we do this sometimes anyway, because we feel more strongly about avoiding tiny
orphan files than we do about isomorphic file locations.

but of course all of this is :+#experimental.

for now this facility is shoehorned into the autovivifying autoloader
facility, so that it comes "for free" to nodes that opt-in to playing the
autoloading game to this degree. (in fact the writer method for all of this
is defined as high up as skylab.rb, but we needn't concern ourselves with
that.)

here is how it works: (the module that will "do" the loading we will call
the "loader", and the module that gets loaded (the "stowaway") we will
call the "loadee".) the participating loader module has a `stowaway` DSL-ish
private writer method.

when she calls this, a "record" is created in her "stowaway manifest". each
record is a tuple of the form (*guest_a, loc_x) where `loc_x` represents a
mixed loading spec and `guest_a` is a list of symbols representing constants
defined immediately under the loader mod but but residing in `loc_x`:

    [ :Foo, :Bar, :Baz ]  # =>
                          # to get @mod::Foo or @mod::Bar load @mod::Baz
    [ :Biff, 'luhrman' ]  # => to get @mod::Biff, do
                          # `require "#{ dirpn }/luhrman"`
