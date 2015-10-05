## introduction


"git log --follow" casts a wider net that we had assumed in two regards:

1) rather than following a direct, sequential line of renames from
present backwards, this appears *maybe* to do that *plus* picking up the
same such trails for any other file that ever had the subject name.

so, if you had possible file names A, B, and C during monday thru
thurdsday:

              mon      tues      wed       thurs

                  A -+
                      \
                       +-> B ------------->+
                                            \
                                +-> C ->+    +-> C
                               /         \
                  D ----------+           \
                                           \
                                            +--> F

In the above example, on monday we had a file named 'A'. on tuesday we
renamed it to 'B', and on thursday we renamed it to 'C'. likewise the
file that started out being called 'D' went through a series of renames.
note that at different times, the two different files used one same
name ('C').

Now, we *expected* that if we did `git log --follow C`, we would only
get the top line's commits in as a result. but in fact what we get back
*appears* to include the second trail as well (because it at one time
occupied the subject name).

anyway, this is only what appears to be the case. we need to turn the
above into a story and see if our *new* assumptions are correct. but in
any case we think that they are closer to the truth because of our
observations below from the current `tmx` repository (of which this
document and [gv] is a part) which can be found in the last section of
this document.




2) because "git tracks changes in *content*", it appears that the
subject command picks up what it *sees* as renames but that we don't.
(the last example in the last section manifests this pattern.)

however, we don't understand the output we are getting from the vendor
command here because we have `--find-renames` on and it isn't indicating
that the line item in question is a rename. so this is an open issue
with no theories yet attached.




if our new assumptions (to the limited extent that we have them) are
correct, our fix for this is that at each jump we track what the current
name is according any renames reported in the vendor output. any commit
screen that does not have a line item corresponding to the "current"
name we skip over, assuming that it is a reflection of one of the cases
above.

again, further tests must be written to confirm that this is now working
as we exect it to be working.




## real life examples from this repo


    [follow command] bin/git-stash-untracked:

    8b58 2013 jul 15 05:52 added three lines
    3eba 2013 jul 15 04:11 renamed *frm* subjet *to* version wall
    af75 2012 dec 15       created orig subject




    [follow command] bin/tmx-test-support:

    6da1 2015 mar 15 edited
    562a 2015 feb 28 rename tmx-regret => tmx-test-support
    456a 2013 dec 22 tmx-regret *created* (goes from zero to 6 lines)
    599b 2013 jul 29 ??? ( tmx-quickie-recursive => tmx-quickie )
    5f0c 2013 jul 15 ??? ( quickie-recursive => tmx-quickie )
    b815 2013 jul 12 ??? ( quickie-recusrive *created* )
