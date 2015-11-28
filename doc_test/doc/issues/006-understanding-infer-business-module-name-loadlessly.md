# understanding `infer_business_module_name_loadlessly` :[#027]

## introduction

over the *years* the solution to this problem has taken interesting twists
and turns. the problem is this: given a path to some arbitrary file, we
"need" to resolve one correct module name for it.

for example, a file named:

    /home/me/my-code/wizzie/wazlo-tango.rb

it might define a module named:

    ::Wizzie::WazloTango

as discussed obliquely in [#ca-029], #ismorphic-filenames are lossy
(hence it is a bit of a misnomer): this file may define any or all of
`Wazlo_Tango`, `WAZLO_TANGO`, `WazloTango`, and still be in accordance
with #isomorphic-filenames.

although going in one direction is painless, going in the other requires
hacking: do we load the file? do we read the file?

now, if we were normal people we would recognize immediately that it is
a false requirement to resolve the latter (correctly) from the former.
but we are not.




## brief history

the oldest way we solved this was with the earliest incarnation of our
"dark hack" which was and still is today the hackiest thing we have ever
done. but this hack has grown on us ..

somehow in the interim between then and now we decided that our shiny
new autoloader was better used for this: in the example path above we
somehow got past the `/home/me/my-code` part of the path, and were able
to walk along the path-parts tripping the autoloader to load the node at
each step (with its excellent fuzzy facilities and dynamic name
correction).

this was an impressive use of the autoloader (and indeed drove its
developement at one point). but:




## now

..with our superior rewrite of [#sy-007], and our newfound confidence
in it because it remarkably worked on 33 files in our manifest list on
the first try, we in fact feel that it is simpler to use this hack than
to autoload the node.




## the algorithm

our surprisingly robust-esque hack (while certainly fallible) produces a
tree given a file with some modules (e.g classes) in it:


    + MyAppModule
      + MySubModule
        + MyClass
      + MyOtherClass

the above tree has 4 nodes, 2 of which are leaf nodes. now, assume that
this file was named in accordance with #isomorphic-filenames and that
whatever subject node it contains will be reflected in the pathname.
we'll say the pathname is something like this:


    `/home/me/my-projects/deep-hax/my-app-module/my-other-class.rb`


what we do is we use the [#ca-026] `distill` function on each of the
"tail names" of the leaf nodes, and of the basename of the file:


        received name     ->      distilled name

              MyClass             myclass

         MyOtherClass             myotherclass

    my-other-class.rb             myotherclass


with the distilled name of the file's basename as the "target", we
compared each distilled name of the leaf nodes against it. we do the
usual error reporting on zero or many, and otherwise if we have one
match, that means we have resolved one leaf node in our tree.

with this leaf node we can crawl back up to the root node and resolve a
("probably correct") modoule name.




## advantages

we do this without having to load the file. loading the file might
trigger loading of nodes we don't want to load, because perhaps they are
under development and/or broken. alternately loading the file might
itself depend on other files beling loaded beforehand in a manner the
requires work.

the way we do it here, it resolves a "probably correct" name without us
having to indicate it manually.




## limitations

no matter what this will always be a hack: files with certain use of
indenting, comments, or other structures used in "unconventional" ways
will certainly break this hack.
