# the tmpdir narrative :[#160]



## introduction


a 'tmpdir' is a special kind of pathname. like pathname it is immutable.
in the spirit of pathname, it is a wrapper around other facilities.
tmpdir wraps facilities frequently used in tests but may also be useful
for other filesystem-related operations typically involving a temporary
directory.




## features (partial list)

• `prepare` - produce the tmpdir as existant and empty of all files.

• for the fu operations of pathname, this tmpdir holds as properties
  default values for the frequently available `verbose` and `noop`
  options.

• typically for the same above operations, the tmpdir has as a property
  an IO stream to receive the string messages for verbose output (what
  you might otherwise have to write an `fu_output_message` method for).

• see also [#011] 'fu'. when needed we will subsume its interface.

• `patch` - apply a patch to a (should be empty) directory to create an
  arbitrary filetree in it.





## history

note that most of the below notes are historic and were imported from
inline in the code. their original dates of authorship pre-date the
birth of this document and can be found in the history of the code-node.




## :#note-130

by this selfsame definition a "preapared" testing tmpdir
is one that is guaranteed to start out as empty (empty even of
dotfiles (i.e "hidden files")). to this end if the path of this tmpdir
object exists at the time this method is called it is asserted to be
a directory and if that directory has a nonzero number of entries
(including dotfiles)..  ** IT WILL BE `rm -rf`'d !! **
all of this is of course contingent on filesystem permissions of which this
facility is currently ignorant.




## :note-210

it is possible that `raise` could be overridden
(as ill-advised as that would be). to get "absolute certainty" in
ruby is perhaps impossible, for even constants can be re-defined at
runtime with only a warning (rendering this whole technique
vulnerable); however we use this proc in a constant as a magical
talisman aginst these concerns; because if we send a `raise` that
does not cause a return, consequences could be disastrous, e.g
doing an 'rm -rf' on the wrong directory.
::Kernel can even be overridden, meh so can this method :/
in case something is spectacularly wrong we check the result too
