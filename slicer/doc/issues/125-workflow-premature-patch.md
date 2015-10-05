# The Premature Patch Workflow :[#125]

(this is a stub of an article whose purpose is to have a place to put
the words down to see how they feel in our mouth)

It is normal in the course of development to get overzealous and
excitedly change a lot of code really quickly -- at the time, you think
you are doing yourself a favor by stoicly sloshing thru lots of legacy
code that now looks bad and "fixing" it.

Oftentimes this happens in part as means of understanding it: you see
something, you can't figure out how it works, this makes you angry,
and so you start re-arranging things, reducing redundancy, clarifying
confusing bits, etc.

The problem is that when you ran tests, they are borked. Possibly the
tests locked down behavior that now you think is undesireable, and you
would like to fix that with your newly refactored code. Possibly there
was some behavior you didn't at first notice or understand, and its
absense is now making itself known with borked tests  .. WAT DO!??

Well for one thing, it is possible that this whole mess should be
avoided by trying to give yourself a "red flag" when your changes get
overzealous, and realize that you are going off the trail a bit,
and just maybe *stop*, throw away everything, and start over but this
time follow along with the tests you are breaking so that you can
introduce your changes progressively and incrementally (yeah right).

But let's say for the sake of this article we don't want to do that.
Maybe there was some good work there in all the ruckus and we want
to salvage it while still keeping things green and sane.


(the below is **very** experimental and not even rough draft)

0. Ground Rules - have them.
   When you got here, all your tests were green, right? (before you
   started "fixing" things.)  If not, or if god forbid you don't *have*
   tests then just stop here because you have far bigger problems than
   this document can help you with :P

1. Don't Panic - Stash it!
   Make a patch out of all your changes and put them into one file
   (this is exactly like `git stash` but we can throw it around more
   easily)

   Now you are in a pristine state, and all your tests are green,
   right!?  (don't do anything else until you have a baseline of green
   test to "proove" your refactorings from!)

2. Make additional "Lockdown" tests, if any
   If you noticed your changes breaking things, and you didn't like
   the coverage, or you want to centralize the "story" of some tests
   to make a point or make them more aestheticly or taxonomically
   arranged, refactor them now or make new tests (don't get overzealous
   *here* though, try to limit this to a few hours tops.)

   Now you should have *even more* green, tests, lock them down with
   a commit as 'proof' of what we are about to do.

3. Wash, Rinse, Repeat
   I like to think of the patch as a big bar of soap that you now want
   to use up progressively and iteratively: you aren't quite sure how or
   where you yet want to use it, because the soap itself is not yet
   fully formed, or perhaps it has dirty bits of debris in it (ok weird
   analogy).. but you intend to, with each bit of the soap, either use
   it up or discard it until it is a tiny sliver and then all gone!


   3.1 Break the patchball up into little files with `splitdiff`

   3.2 in your mind, and with tools like `gitx`, make a little dependency
   graph of the changes: are any of them ready to go now? are any
   of them dependant on other changes in that changeset in order to
   work?

   if possible, apply a subset of those changes, make sure *all* tests
   pass (while enjoying using the new 'proof' tests you added above).
   and when the patch is applied, discard the corresponding file.

   3.3 Use 'opendiff' / 'FileMerge' to apply selectively parts of
   the patch. (#todo expand on this)
