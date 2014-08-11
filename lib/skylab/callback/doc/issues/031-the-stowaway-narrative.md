## on the imperfection of #isomorphic-file-locations

(EDIT: This node is a modification of a historical document, here for posterity)

### it is not a perfect isomorphicism

it bears mentioning that this is not a perfect isomoprhicism: given our name
convention, constant names may `LookLikeThis` or `LOOK_LIKE_THIS` or
`Look_Like_This`, and they all belong in the same filename. a file called
"nsa-spy.rb" might hold `NsaSpy`, `NSA_Spy`, or `Nsa_Spy`. (and believe it or not,
in one dark corner we actually open the file to take a peek at the correct
casing of the name before the file is even loaded into the ruby runtime,
which is necessary to do for some deep, narrow tress and this autoloading
algorithm.)

we `use-dashes-in-filenames` and `not_underscores` because of the fact that
it looks unequivocably better. (but still we use _spec.rb in our test
because it is the default, and although this makes everything look horrible
we stubbornly stick it out because of how strongly we feel for the dashes.)
we could bend the autoloading behavior to anticipate the possibility of
filenames with underscores but we are not going to, again because of how
strong our passion is for filenames with dashes.


### when file was not there

consider:

    my-app
    ├── core.rb
    └── foo
        └── bar.rb

it used to be that
when you were in "core.rb" (which defines MyApp), you could then load
MyApp::Foo::Bar even though there is no "foo.rb" to load. the autovivifying
autoloader assumed that any directory immediately under it for which there is
no corresponding file, that it was OK to go ahead and create a module with
a name based off that directory name. (here you can even pick your naming
convention: "biff-baz" can become BiffBaz or Biff_Baz. #todo:explain-how)

this "autovivification" was problematic for certain structures and
certain operations and so was removed, having been deemed a mis-feature.



## the stowaway narrative :[#031]

the `stowaway` facility facilitates the dubious behavior of specifying
that a given module (if needed) is to be loaded by loading a file other that
the file you would expect to find the module in, given the name of the module.

while this is tautologically in violation of #isomorphic-file-locations,
we do this sometimes anyway, because we feel more strongly about avoiding tiny
orphan files than we do about isomorphic file locations.

but of course all of this is :+#experimental.

for now this facility is shoehorned into whatever particular extension
suite it is shoehorned into.
