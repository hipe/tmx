# Unobtrusive Lexical-esque Insertion :[#011]

(this ancient but still relevant "algorithm" moved here from [#tm-067].)


The idea is this:

When you have a thing that you are going to insert into a list of
things, it would be nice to put in the list in the right place
alphabetically. However, if the list isn't sorted to begin with,
then you don't want to go and resort the list -- that would be rude.
In such cases, try and make it look like you were trying to do the
right thing and insert the item above the first item that you find
that was lexically greater ("should come after") the new item.



## examples with pseudocode:

consider a list '1', '2', '3' and you want to insert a '2' into it.
for each item in the list (while holding on to each previous item
too) ask, "is it greater?".

when we get to item '3' (and we are still holding on to item '2'),
we can say "yes, it is greater". in such cases you insert the new item
between the two items you are holding.

imagine the list '3' and you are inserting '4' into it: we get to the
end of the list before we ever found one that was greater. in such
cases insert the new item after the final item in the list (or if there
are no items in the list, insert the new item as the first item.)

imagine the list '3' and you are inserting a '2' into it: the first item
is greater, but we have no previous item. in such cases you are
inserting the new item at the beginning of the list.

BUT imaine the list '4', '2', '1' and you are inserting a '3' in it.
in such cases the '3' would get inserted into the beginnng of the list,
becuse '4' is greater. i.e the algorithm always short-circuits at the
first found item that is greater, regardless of whatever other ordering
is going on in the list.
