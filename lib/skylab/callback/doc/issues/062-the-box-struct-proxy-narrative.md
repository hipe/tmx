# the box struct proxy narrative

## introduction & purpose

if your box is done changing (typically by run time) you might want to
"freeze it down" into a struct-like, so you can use the familiar struct
interface of accessing members with methods etc.




## scope

note this is not (yet) a proxy to the original box that created it. it
is a dumb copy with the values as they were at the time of creation. we
call it a "proxy" because it is a thing that presents a box-like facade
that is a proxy (in its way) back to a struct.




## originally

this node was much more complex and did a lot more. during the move from
[mh] to [cb] we simplified out much of what was here.

if ever we needed more than just a few box-like methods we would
re-architect simple box into its readers and writers and re-establish
that old architecture again. but we don't.
