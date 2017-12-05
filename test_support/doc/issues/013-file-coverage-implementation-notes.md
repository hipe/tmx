# file coverage implementation notes :[#013]

## :[#here.B]

the "big tree" is what we start with in the main algorithm of our
core operation. it is meant to contain every "file of interest"
under the given directory where the "f of i"'s are the full
aggregate of every asset file and every code file in that tree (and
no other files).

in the interest of reducing the number of parameters we have to
worry about, we (for now) assume as widely-held certain conventions.
so, CRUDELY but probably sufficiently for the forseeable future, we
will derive the "big tree" by doing a `find` command on a given
directory finding all files that match one or more of the "big tree
filename patterns."

for now (again, crudely) we derive this set of filename patterns
from the set of argument filename patterns. the latter are supposed
to match test files only, but we viciously apply the assumption
that test files will have the same extensions as asset files.

edges cases that will make things break downstream are

  - if the test filename patterns don't have extensions

  - if all the extensions that the t.fn.p's do have *look like*
    they contain special search glob characters. (we might loosen.)

