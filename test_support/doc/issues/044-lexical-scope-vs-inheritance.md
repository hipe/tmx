# lexical scope vs. inheritance :[#044]

this issue is used to track how we inject constants into test "sandbox"
modules.

explanation: when you create a lexical scope of module B inside module A
and you reference a const from inside module B: the platform looks for a
const *assignment* in module B first. then (if not found) it looks for a
const assignment in the 0 or more modules in the ancestor chain of module
B. (that is, if you had said `include C` in B, the module `C` would be in
the ancestor chain of `B`.)

*then* if the const still isn't found through any of these means, the
platform will look in the const *assignments* of module A. but here, if it
does not find the const this way, it will *not* go ahead and look further
thru the ancestor chain of module A.
