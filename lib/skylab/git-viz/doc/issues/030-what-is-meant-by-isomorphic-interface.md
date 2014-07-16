# :#what-is-meant-by-isomorphic-interface? :[#030]

this node here intends for itself to be a small but powerful re-imagining
of a now ancient effort started at [#fa-006] (currently undocumented) that
was never fully realized.

a compliment to that effort (in all of its incarnations) is a parameter
library. the parameter library introduced here is part of a [#mh-053] long thread
of such efforts, in fact it is (at least) the sixth such reboot. (granted,
with the later re-takes we started to shy away from a silver-bullet style
super-library, and started just hand-rolling each new one from scratch ad-hoc
as we have done here. still we hope one day to unify all of them.)

this parameter library is [#mh-053] compared and contrasted to its cousins
in terms of the kinds of features they offer and the different techniques
often employed in their implementation. because it is the sole focus of that
document, discussions of the particulars of our parameter library here occur
there.


## no, really, what is meant by "isomorphic interface"?

Douglass Hoffstadter pretty much gained ownership of the term "isomorphic"
with his _Goedel, Escher, Bach_. as it pertains to interface development,
we use the term simply to refer to the phenomenon whereby you can reconceive
the same underlying interface in regular ways for different target modalities.

what interests us generally is ways in which we may faithfully represent
these deep structures so that they readily translate well to the different
modalities, and ways in which this abstraction leaks when attempting to do
so.

this will make no sense to the uninitiated without examples but those may
be currently hiding in branches at the moment, tucked away like fermat's
last theorem.
