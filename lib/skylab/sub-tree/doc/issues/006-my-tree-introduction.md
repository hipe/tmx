# My Tree

Some reasons for this:

  + We wanted to see if we can make a full canonical CLI with H-eadless (1.1)
  + We want trees with linecounts etc like we were doing before manually


Some Facets of this:

  + We could have built it under cov-tree
  + We could have built it under file-metrics


Reasons we didn't build it as part of existing products are:

  + the usual "fresh-start" motivation, dovetailing with 1.1 above
  + emotionally, we were especially in need of some "fresh-start" feeling




## :#collection-operations ("in-pass" vs. "post-pass")

every extension expresses whether or not it is a "collection operation".
any extension of this category will get notified "post-pass" with the entire
collection of mutable data items, so that an operation can be performed that
takes all the items as an argument and with the result may mutate each of
them.

currently this classification is binary: any extension that is not for
post-pass is for "in-pass". an in-pass extension is one that can complete
its processing of the item as soon as the item is encountered - the
extension does not need the whole collection.

IFF all zero or more active extensions are in-pass only, we may output
the result tree progressively; otherwise we must memoize the collection
so that it can be processed by the post-passers before it is flushed.

in-pass vs. post-pass has ramifications for performance in both
directions: if you had a hypothetical zero-time operation, performing it
in-pass will allow you to flush the tree progressively, which may have a
perceptible positive impact on performance.

however, some extension operations may be *significantly* more efficient
to do post-pass than in-pass. consider the 'word count' operation: to do
word count (in our way) requires a trip to the system to execute a
separate process. however, we may pass many files at once to `wc`. if we
pass N files to word pass all at once, we only have to take one trip to
the system rather than N. `wc` processing 100 files at once is presumably
signifcantly faster than taking 100 trips to the system for `wc` to
process one file each trip.

in such cases, the savings of taking this post-pass step may outweigh
considerably those incurred by losing our progressive output of the
tree (and yes, there may even be a cutoff point where some chunking is
in order but that's getting too crazy)..
