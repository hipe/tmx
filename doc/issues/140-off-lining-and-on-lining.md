# off-lining and on-lining :[#140]

## :#off-lining

off-lining happens when too many mutually-interdependent changes are happening
in different sub-systems at once. the story typically goes something like this:

1) let "frobulate" be the subsystem we are working on. we set out to add some
   features to "frobulate" or parhaps refactor ("re-architect") it in some
   non-trivial way.

2) in so doing, we realize we want to refactor the subsystems that
   "frobulate" depends on in conjunction with this effort (or more accurately
   as a pre-cursor to it).

3) because we had made progress with "frobulate" but it is not yet green, we
   "offline" it while we stabilze the changes in the rest of the universe.
   :#offline simply means that we officially (and temporarily!) remove the
   subsystem from the list of green subsystems, in the interest of progress.

this is a move that typically only gets done on sub-systems of the
"sub-product" variety.



## :#on-lining

that magic moment after sometimes many months of toil is this: now that we
have gotten the rest of the universe green with the changes we were inspired
to make that lead to the off-lining, we then :#on-line the sub-system, which
refers to the act of re-integrating it with the changes that happened while
it was off-line:


### :#un-factor :[#139]

an "un-factor" may describe the first commit of a series of commits where we
attempt to "on-line" an "off-lined" subsystem. during the course of a
subsystem being "off-line" two things probably happened:

1) the subystem missed out on the bulk of changes in the universe that
occurred while it was offline (which is sort of the point of being offline.)

2) because as a rule we keep a "keepalive" signal with the subystem even when
it is offline by keeping its 'ping' facility up-to-date, some small amount of
changes probably occurred (over perhaps a "long" period of time) to the
system, even while it was offline.

the "un-factor" commit, then, is this experimental thing we do where we reverse
all the changes we did to the off-lined subsystem while it was offline, so that
we may cleanly rebase (or merge) its offline branch into the new master.

the only reason to do this in its own isolated commit rather than resolving
the conflicts in the traditional way is a) if you think it will be easier
or b) if you want to preserve the sanctity of your original commit(s) from
the offlined branch.

it's worth metioning that the changes made to the offline subystem are almost
never worth keeping because they are rarely applicable to the offlined version
of the sub-system, which was typically off-lined because of how radical the
changes were in the first place.

rather, the #un-factor patch you make can serve as a narrative guide, showing
the developer all of the changes she will need to re-apply manually to the
on on-lined system.
