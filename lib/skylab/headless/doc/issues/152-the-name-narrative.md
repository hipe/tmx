# the Name narrative :[#152]

## :#storypoint-5 introduction

a name "function" may be a bit of a misnomer, it is really several functions
in one, bound around (or curried to) an inner "normalized" name. abstracted
from existing application here, it comes in handy for doing name "inflection"
for the [#146] isomorphicisms, if it happes to work out that the name
function(s) you want are here.



## :#storypoint-10

the functions defined here may have sister variants found elsewhere in the
system but these are more specific and less general-purpose.



## :#storypoint-15

some applications annoyingly use slug-like strings as normals, in which case
to metholate them we need to run them through this.



## :#storypoint-30 lossful name conversions :[#083]

constant names can hold more information than others given our name
conventions, so converting from const to norm can be lossy, for example:
`NCSA_Spy` -> `ncsa_spy` - it is impossible to go in the reverse direction
deterministically :[#083]



## :#storypoint-35

so that this name function can look like a full name function, if you want
to future-proof your name function but for now only use a const and not a
deep graph.



## :#storypoint-55

a "compound name" made up of multiple monadic names. usually used to represent
a "fully qualified" name, which can then be turned into a variety of
derivatives.



## :#storypoint-105

centralize this hacky fun here
