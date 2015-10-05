# the F-UN narrative :[#026]

(even when there is no F-UN, this is still a place to document the functions
of the public API of [cb])


## :#the-distill-function

different than the (currently 2) normalizing inflectors, this is a lossy
operation that produces an internal distillation of a name for use in e.g
fuzzy (case-insensitive) matching, while preserving meaningful trailing dashes
or underscores from e.g a filename or constant.

its result is not always suitable as a const name.

this has historical significance because it is the first thing we stole
from metahell
