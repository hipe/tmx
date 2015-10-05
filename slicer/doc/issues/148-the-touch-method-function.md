# the "touch method" function :[#148]

## description

define this method with this visibility on this client if possible,
without clobbering an existing method of the same name you mean not
to clobber (for our definition of "mean" defined below), where
"if possible" is determined by what is already defined, where it is
defined, and what flags you passed:

when method is already defined and the method owner is the selfsame
client, no action is ever taken. (for, to redefine existing methods
on the same module is never the intended behavior.)

when method is already defined by some module in the ancestor chain,
behavior depends on whether or not the overriding flag was passed: in
the absensce of this flag, no action is taken. otherwise,
the toucher will redefine the method setting its visibility to private
if indicated, else public (which may be indicated explicitly but is
also the default).

to understand the utility of the above, consider the case of the
`initialize` method, defined by ruby as a private instance method of
BasicObject: to (re) defined such a method with the toucher you must
pass the overriding flag. (and the visiblity of the newly defined
version will be determined by the visibility you do (or don't)
indicate).

the syntax is such that an infinite number of flags can be provided
and (in the case of visiblity) only the last one "wins". the allows
for methods that touch to take in arguments from the "outside" that
may potentially override defaults provided in the "inside"; so that
for e.g. some code may touch a method to be private unless the client
(caller) wants it to be public.
