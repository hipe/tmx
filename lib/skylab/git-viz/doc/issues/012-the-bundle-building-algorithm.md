# the bundle building algorithm :[#012]

(EDIT: this document has much older content that is not yet assimilated,
halfway down, demarcated by many dashes. what follows immediate is "current")


## introduction

a "bundle" contains all the information needed to build a "hist-tree".
we can think of it as a matrix of "filechanges", with time one one axis and
files on another; where a "filechange" is the changes to one file in one
commit.

below is a pseudocode description of the algorithm we use to build a
bundle, along with descriptions of the datastructures it is built
around.




## in pseudocode

below, a specialized structure or concept will appear as a hashtag the
first time it is used, and then will *not* appear as a hashtag each
subseqent time it is used. the hashtagged terms are defined in the
next section.

(note the hashtags are also used inline in the code so don't change the
constituency here without renaming there. in the code they will always
appear with the form "[#012]:#hashtag-name" (without the quotes).)

  • determine the list of #path's in our #path-of-interest with
    #the-git-ls-files-command.

  • for each above path,

    • start a #trail with this path as its #current-path

    • perform a #git-log-follow-command.
      with each resultant #SHA of this command
      *in order from most recent to oldest*,

      • if a #commit with this SHA already exists in #the-commit-cache,
        we will use this commit in the bullet after next at this level.

      • otherwise, we will create the commit (reflection) object:
        perform a #git-show-command. with the resultant output of this,

        • for each #line-item of the output
          • create a #filechange with which:
            • populate all of its fields
            • add it to #the-filechange-dictionary, keyed to its
              #current-path

      • with the commit object produced by one of the above two bullets,

        fetch the filechange by using the current-path of the trail.

          • add this filechange to the trail.
          • if the filechange is a rename, change the current-path of
            the trail

    • with this complete trail, add it to the #list-of-trails.

  • sort the-commit-cache by datetime (MAYBE (see [#037[)), putting the results
    into #the-commit-box. the-commit-box plus the list-of-trails is
    #the-bundle.



## definition of terms (in order of first appearance in the algorithm)

when a term uses another term in its definition, that other term will
appear with a hashtag IFF it hasn't been defined yet.

• a #path is a fileystem path relative to the root directory of the
  repository. this the internal, univerally normal way we represent
  filesystem locations, which themselves are transient data,
  as opposed to existing one-to-one with a #trail.

• the #path-of-interest is a path given as an argument that indicates
  an existant filesystem tree that has one or more tracked files.

• the #git-ls-files-command will show the paths of all the files under
  the path-of-interest at the HEAD of the repository.

• a #trail is a list of #filechanges AND a #current-path

• the #current-path of above is a path that gets mutated the further we
  go back in time, corresponding to the file in its current location at
  that state.

• the #git-log-follow-command will give us the #SHA of every commit in
  which the file was changed, including renames.

• a #SHA is as per git. we would like to represent it with a large
  number if we figure out the right way to do this, else we will use
  strings.

• a #commit is a structure with a SHA, a platform
  datetime, and PEHAPS [..]

• #the-commit-cache is a simple hash of commits, keyed by SHA. we used
  to call it "the commit dictionary" but we want to emphasize that
  because the repo itself is volatile, cacheing commits should be the
  exception and not the rule.

• the #git-show-command..

• #line-item's are the constituent itmes of the output of a
  #git-show-command. each one will transform into a #filechange.

• a #filechange has any one, two or all of:
    • a #rename
    • a number of lines removed
    • a number of line added

• #the-filechange-dictionary is a simple hash of filechanges, keyed to
  the current path.. REALLY

• the #list-of-trails is a simple array of trails.

• #the-commit-box, #the-bundle are described by the algortihm.




## impotant notes

during the first major rewrite of [gv], we tried a simplified algorithm
that used only `git log` on the path of interest, and a special `git
show` on each resultant SHA. this did not have the necessary effect of
tracking changes to files when they were outside of the path of
interest, as can be seeing by trying the first command manually on the
real repo created by building story-03.

if the above algortihm seems more convoluted than it need be, keep this
in mind.



--------------------------- much older: -------------------------------

# datamodel and algorithm narratives :[#012]


## understanding the :#sparse-matrix of filediffs

the core "VALUE PROPOSITION" of gv is the representation and visual
manipulation of this as-yet-to-be-defined sparse matrix. please read the
definition of "commitpoint" in [#010] the git commit pool narrative and come
back here.

the main point here is that at its core the datamodel is a matrix (or
something like a "table", "grid", 2-dimensional array, etc.)

the nodes on this matrix are what we call "filediffs", which is that part
of a diff (or "commit") limited only to the changes in one file. a column
of filediffs we refer to sometimes as a "commitpoint".

visually we will like to normalize the commitpoints to a linear scale of time
as an option, perhaps as the default behavior. also we would like to amuse
ourselves with adaptive, dynamic ways to represent various characteristics
of the filediffs with the changing amount of screen real-estate (and of course
presentational modality) they have.



## :#the-two-pass-algorithm

(EDIT: #the-algorithm-steps may be the most useful section here, and these
other sections leading up to it may eventually be dissolved into it.)

in one pass we visit every file in the list of files and for each file
determine the list of commits that touch that file (perahps only within
some criteria, like a daterange).

we are about to make the second pass, but before doing so it is important to
appreciate this moment: we are about to make the sparse matrix, but before
doing so we have to know that we are not adding any more commits to the pool,
because it will be annoying to re-index them. (not impossible, but annoying).

so we actually remove the pool. then we go through each commit (in any order)
and do something like a "git show" to show the stats for each touched file
in each commit, and store this parsed structure in memory (for now).

either before or after we do the above step, we also make a "commitpoint
index", which is simply a sorting of the list of SHA's by some (almost
certainly chronological) criteria, (for example, maybe by author commit date).
the significance of closing the pool is here: any time more commits are added
to the pool, the commitpoint indexes must be re-calculated.

(as this visualizer matures the "commitpoint index" may become superfluous,
but at present it is a necessary joist.)

now that we have calculated these two metrics for all the commits in our
in-progress matrix, we may commence with the second pass.

in this pass we iterate over each "trail" (in any order) and, for that trail
for each file-diff in that trail, we tell that file-diff what its metrics
are (for now, simply the number of insertion and number of deletions). each
filediff may be frozen at this point.

when we reach the end of the list of trails, we may also freeze that.
the sparse matrix is complete and ready for manipulation.


### reasons for the two pass.

typically there are more filediffs than there are commits. (necessarily there
are at least as many.) commits go along one axis and files go alone another,
and filediffs exist at the intersection. the data for each filediff is
derived from something like a call to "git show". one "git show" provides the
data for many filediffs. we are certainly not going to do the same system call
multiple times to get the different metrics for the different filediffs in one
commit.

yes the parsed structure of the "git show" can be resolved lazily "on-demand"
and memoized instead of doing the two-pass alrogithm, but we know we are going
to need all of them so it requires less thinkidng, less moving parts and
exposes us to less room for error to calculate them cleanly in two complete
passes.



### :#the-algorithm-steps

#### step-1: git ls-files

this produces a list of paths relative to the root directory of the repo.


#### step-2: git log --follow

for each file ("path", more accurately) that is output from step 1, we perform
a "git log --follow" on it. watching out for the [#035] gotcha wherein we get
what amounts to false-positives, we now have a list of SHA's that point to
each commit (not in any particular order, as far as we care about) that
affects the file whose "final" location is indicated by that path.


#### step-3: git show --numstat, divided

either when the commit was first announced as a thing to the repo, or now
once we have gathered every commit in this "hist-tree", we go through and to
a 'git show --numstat' on each commit. this will show for each file affected
by that commit the number of lines inserted and number of lines deleted to
that file.

this having been done, we can iterate thru every "trail" of the "bunch", and
of every trail iterate through every "filediff", and for each filediff we
can lookup the corresponding number of insertions and deletions for that file
at that commit.


#### after these 3 steps are done..

.. we then have one bundle that consists of many trails, each trail of which
consists of many filediffs, each filediff of which has the number of
insertions and number of deletions for that file at that commit. this is
is the source data for a hist-tree visualization.
