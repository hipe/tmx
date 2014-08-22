# introduction

    Invocation__
      ^    ^
      |     \--------------- Action_Adapter__
      |                           \
    Branch_Invocation__            \
      ^            ^                \----->  Adapter_Methods__
      |             \                        ^
      |              \                      /
    Top_Invocation__  \----- Branch_Adapter__


This model grew out of literally years of rewrites.

the first node created is the top client. the main function of this node
is to resolve one of many child nodes to field the request. the top
client will dispatch the well-formed request to one of its children.
this child will be a leaf node or a branch node. when branch node this
process will be repeated recursively until a leaf ("terminal") node is
resolved.

the top node and the non-top branch nodes are similar but not the same.
the top node is like a non-top branch node with some added
responsibility and public API methods. likewise the non-top branch node
will have behavior that is differnt than the top node, namely that the
former has a parent and the latter does not.

leaf nodes always have parents and never have children hence they are
different from the other two kinds of nodes discussed so far. however
all three have behavior in common, namely that they all parse options
and output help screens, to naame a few.

hence, 'invocation' is the abstract base class to rule them all. 'branch
invocation' is yet another abstract base class childing off the first,
that implements the branch-specific behavior. the top client and the
non-top branch nodes each have their own class childing from that.

for the terminal (leaf) nodes, we have yet another concrete class
childing from the basest base class. since the "concrete" leaf and
branch nodes both have some behavior that is common to them but not the
top node, this behavior is put into a ("mixin") module.

it's that simple.





## :#note-575


experimental aesthetics - when there is nothing filling the
trailing optional arg "slot", let a would-be option fill this spot.


the general trend here is to try to get properties out of the options
and into the arguments if possible. it looks nicer and reads more
cleanly, and is a fun and silly challenge.

(a) if we mucked around with globbing arguments already, then don't
bother here. you can have multiple trailing or leading optionals (a structure
we will never produce here) but you can't have one 'many' argument in
conjunction with any other non-one-aritied arguments.

(b) when there are as yet no args at all, we have nothing to lose by
putting one of the opts into the last "slot" of the args.

(c) even if there are alreay args there, we assume that none of them are
already globbing or optional, because otherwise they would have been handled
by the "many" logic earlier, or not fallen into the arg list in the
first place because the qualifier for this list is that the property is
"actually required". in such cases EXPERIMENTALLY we go ahead
and make the transformation to put the last option in with the args as a
trailing optional.



## :#note-600

sadly we still have some cases to filter out. in the cases where
properties are actually "officious" options (things like --version and
--help, actually more like actions than options); we don't want these to
become arguments. this could stand to be improved.
