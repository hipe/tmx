# "private fold method" defined :[#012]

(this is somewhat informed by the hazy notion at [#007].)

a "private fold method" means: a private method that is all of:
  + only called from one other "place" (i.e line of code in the codebase)
  + exists only for one of more ("and/or") of:
    + to be overriden
    + to make code more readable (by reducing would-be method length of the
      caller).

if you are confident that a "private fold method" has not yet been overridden
anywhere *and* that its caller method has not been overridden yet anywhere,
you can change its signature with impunity.

# future directions..

interestingly we could determine the location of private fold methods
lexically and semantically, and do something cool with them, like expand
or collapse their logical scope dynamically ..
