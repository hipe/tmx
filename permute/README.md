# the skylab "permute" utility

## objective & scope

"permute" is a cute, simple, pure little utility: given one or more
values each of which belongs to one category (where categories are created
by user and are typically re-used). for example:

    permute --cone waffle --cone sugar --scoop chocolate --scoop vanilla

would emit one item for each of the four permutations.

this utility in its own right is used to test framework and interface
generators. as well it is used by [ts] to produce templates for test
cases.
_
