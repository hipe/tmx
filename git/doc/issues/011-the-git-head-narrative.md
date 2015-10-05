# the git head narrative :[#011]

## synopsis

if you're editing "foo/bar.rb", this writes the HEAD version of that file
to "foo/bar.HEAD.rb". whines if the file is not versioned or if the file
has no changes.



## implementation

the above is accomplished simply by writing the output of a 'git diff' to
a temporary patch file, and then applying the patch to the subject file
while writing the output to an alternate location with the '-o' option.



## history

this guy used to live in with the other actions in the git subsystem. it
overwent a complete rewrite for two reasons:

1) we needed it to operate standalone because of how often it's used during
development. if the "bleeding" facility worked, we might keep it tightly
integrated with "tmx" and use a last working stable version while we
developed, but the bleeding facility is currently not stable and we need this
to be readily available now as we fix things like the bleeding facility.

hence we ripped the CLI and API actions out of the "git" subsystem and moved
everythiing into a standalone utility script under bin/.

2) the way we had implemented it was stupid. at the time we wrote it, we
didn't know how easy it was just to use patch with the '-o' option to
accomplish the same effect we were achieving by jumping through hoops too
convoluted to describe here.



## maybe issues

the temp patch file is intentionally not removed if something abnormal happens.



### possible future features ("wishlist")

we might add an option to check out versions other than HEAD.
