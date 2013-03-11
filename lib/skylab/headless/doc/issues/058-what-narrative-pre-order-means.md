# what "narrative pre-order" means ("outside-in")

              ~ what "narrative pre-order" means ~

To a large extent the methods and functions (hereafter referred to
as "functions") are presented below in what is called "narrative pre-order"
which means they were each added one by one (and placed one after another
in the order they were added) as needed as the tests were written
one by one (which themselves are generally written in an order of
increasing complexity). This is done solely for ease of comprehension
and human scanning, specifically for ease of refactoring.

(we used to go strictly alphabeticaly within public and protected
sections, but this proved sub-optimal because of both a) a spaghetti
effect when reading and b) it was prohibitive to refactoring, during
which method frequently get renamed.)

Public functions call auxiliary functions which themselves call other
auxiliary functions and so on. The first call to the first function
you don't recognize in a given function, you will generally find its
definition immediately after the function you are reading.
That function itself will often call other functions you don't
recognize and so-on. The dependency graph of calls often forms a tree,
and the order below follows rougly a pre-order traversal of that tree.

(Because programs are not yet presented in 3-D, it may still be several
pages you have to scroll to jump to the definition of a function after
the first time you see it, depending on the width of the tree; because
we go depth-first down to the function that calls no more functions before
we get to other yet-undefined functions that a given function called.)

We do not close and re-open modules just hold to the pre-order guideline,
but the order the modules occur (within a section) is generally determined
by this guideline. Modules *are* re-opened as necessary to a) fit into
the appropriate section and b) you will see modules re-opened as necessary
to create the right hierarchy because their hierarchical ordering is often
the *reverse* of a narrative pre-order ordering.

(an exception to this are constructors (`initialize`) which as a rule
will always occur as the last method definition in the first opening
of the class. This is done for reasons.)
