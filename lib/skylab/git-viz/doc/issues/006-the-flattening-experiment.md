# the flattening experiment :[#006]

we suspect it is the case that there is no rigid relationship between the
datetime that is stamped on a commit and its relation to the datetimes
of other commits before or after this commit.

given that this is probably the case (and we should nonetheless be
prepared for it to be), this presents some interesting problems for us;
problems that challenge the very assumptions we presupposed when we
began this project.

(this was not a consideration that had occurred to us until during the big
rewrite (which is probably a good time to deal with it).)

given any given "bundle" (and we know exactly what this is because
[#012]), we *can* certainly line up the commits in chronological order
(that is, by their various datestamps and render the table that way.

HOWEVER, given the axiom at the top, this will then have the effect of the
commits being rendered in the wrong order with respect to each other, which
may or may not be what we want.

if it is not what we want, we will have much more fun rendering the
table; a broad problem we will subdivide into two corollary problems:

  1) how do we determine the order of the commits?

  2) if their sequence of datetimes is not coherent, what kind of labels
     (and one day spacing) do we render




## towards a solution for problem #1

problem one "sounds easy" but is not necessarily so for some imaginary
bundles. imagine this imaginary bundle (where capital letters are
commits):

                        +--> B --> C --+
                       /                \
                      A                  +-> Z
                       \                /
                        +--> C --> B --+

(note: the horizontal runs are not branch timelines but file timelines.)

the above imaginary bundle consists of two "trails", each trail having
two commits, and point "A" and "Z" are the imaginary points we use to
indicate that these trails have a shared origin state and shared
current state (that either will or won't have visual representation in
the front client).

the above graph is impossible for "hist-tree" to render. hopefully it is
impossible for hist-tree to produce such a bundle from a git repository,
becaue hopefully git will never produce such a graph.

but imagine a more natural graph:


                      +--> 2 --> 3 --> 5 --+
                     /                      \
                    A----> 2 --> 4 --> 5 ----+--> Z
                     \                      /
                      +--> 1 --> 4 --------+


we want the table to look this:


                              1  2  3  4  5

                      file1      X  X     X
                      file2      X     X  X
                      file3   X        X

### our algorithm, in pseudocode:

of nodes 1-5 (all known nodes), find the "oldest" and "newest" (in terms of
the graph, not of the datetimes) nodes.

we can reduce the search space: the oldest node will be one of the three
first nodes of the three trails. likewise the newest node will be one
of the three that end the three trails.

we can reduce the search space further: trails may share beginning and
ending nodes. so:


  #### :#step-one:

     find the set of all unique first nodes (SHA's) of the trails ("F").
     also, find the set of all unique last nodes of the trails ("L").


  #### :#step-two:

     on set F apply a reduce operation, finding the oldest node: we
     assume (BUT DON'T KNOW YET) that this can be done with
     `git-cherry` ("vendor command"), although there is probably a
     less convoluted way..

     (in this same manner find the newest node in set L):

     we assume that vendor command will produce either more than one
     SHA's or none when done in one direction, and conversely
     none or more than one SHA's when done in the other.

     (that is, no two nodes that we arrive at here will ever produce
     no SHA's in both directions, or more than one SHA in both
     directions. i.e, each pair of nodes (we ASSUME) will have more than
     one in one direction and zero in the other.)

     with this result of the vendor command, we can determine which of
     any two nodes is older (or newer as apprpriate); and implement the
     reduce operation in this manner.


  #### :#step-three:

     now that we have THE 'oldest' and THE 'newest' (in terms of the
     directed graph, not in terms of datetimes) nodes:

     we can do a `git-log` from oldest to newest to give us a (possibly
     "long") list of SHA's. we ASSUME this list will contain all the
     nodes in our bundle.

     now, at this point we could simply invert such an array of SHAs
     to become a hash that maps each SHA to its ordinal integer. but
     that's too easy:

     take the set of all SHA's in our bundle (it is a data member of
     the box which is a data member of the bundle).

     make a "diminishing pool" hash of these SHA's. iterate the pool
     from first SHA in the list of all SHA's. as the current SHA is
     found to be within the diminshing pool, increment a counter and
     associate this SHA with that value of the counter, and remove that
     SHA from the diminishing pool. when the diminishing pool gets down
     to zero, we are done.

     this may or may not be optimal over the simpler approach, which is
     simply to invert the array of all SHA's into a hash that produces
     ordinal integers. (and which is optimal may depend on [#012]
     whether or not we represent SHA's as numbers.)

     we will say that the above produces an "order-box" of SHA's.

     with this order-box in conjunction with a bundle you can render the
     table.


## as for problem #2

 .. meh for now ..


:#twinkle-in-the-eye: The Big O Problem
