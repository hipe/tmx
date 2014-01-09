# datamodel and algorithm narratives :[#012]


## understanding the sparse matrix of filediffs

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
of the filediffs with the changing amount of screen real-estate (and even
presentational modality) they have.



## understanding the two-pass algorithm

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
index", which is simply a sorting of the list of SHA's by some time (almost
certainly chronological) criteria, (for example, maybe by author commit date).
the significance of closing the pool is here: any time more commits are added
to the pool, the commitpoint indexes must be re-calculated.

(as this visualizer matures the "commitpoint index" may become superfluous,
but at present it is a necessary joist.)

now that we have calculated these two metrics for all the commits in our
in-progress matrix, we may commence with the second pass.

in this pass we iterate over each file node (in any order) and, for that node,
for each file-diff of that filenode, we tell that file diff what its metrics
are (for now, simply the number of insertion and number of deletions). each
filediff may be frozen at this point. and when we reach the each of the list
of filediffs for a given file node, we may freeze that node too.

when we reach the end of the list of file nodes, we may also freeze that.
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
to need all of them so it requires less thinkging, less moving parts and
exposes us to less room for error to calculate them cleanly in two complete
passes.
