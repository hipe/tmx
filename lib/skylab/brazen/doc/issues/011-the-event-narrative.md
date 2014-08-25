# the event narrative :[#011]


## :#note-25

events should be thought of as immutable. if you want to change the
properties of an event for whatever weird reason, use this.

you cannot add new properties through this means, you can only determine
what the values will be in your new event of the properties that exist
in the first event. in order to add new propertes to a existing event,
you could perhaps use `to_iambic` and add new properties and value to
this array and build a new event from that.




## :#note-210

to determine a noun: if there is a custom noun, use that. otherwise, if
there is a parent node, use that (assuming the common convention).

otherwise, if there is custom inflection with a verb (and since we have
no parent), assume that the class name is a noun. use that.
