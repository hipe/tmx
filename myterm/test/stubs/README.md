# readme

the two stubs with numbers "01" are older. they use the experimental
"mess with" test support library.

coming back to this 6-ish plus months later, we find this confusing and
extraneous. now we build a stubbed system and assign it directly into
the kernel that we build, rather than access the kernel's s.c and modify
it..

this is reflected hopefully in the change in amount of API there is to
understand when you compare on the one hand the two "01" files, and
on the other hand the first "02" file: the latter builds one object of
one class, and calls (repeatedly) one method on that class to populate
it with fixtures.
