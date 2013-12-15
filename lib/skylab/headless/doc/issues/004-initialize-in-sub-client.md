## initializing in the sub-client? :[#004]

it's generally (probably) considered bad practice to have a module
that has an initialize method. SubClient thinks it is special:

experimentally, subclients are trying to be sorta strict and consistent.
when they are all written the same way, you don't have to write
initializers - it's to encourage you to get used to initializing
sub-clients with the request client and not thinking about it.

so there is that call to super() there at the end of initialize() -
there are 2 noteworthy things about it: 1) it never passes any
arguments up there. I hope that is not a problem. (Don't initialize
your objects with blocks unless they shoot fireworks from.. just don't it).

2) it happens at the end of the method, as opposed to the beginning.
this is actually to transfer control to the user: if you have class A
that does not sub-client, and class B that descends class A, but then
also decides it wants to be a sub-client, having the call to super() at
the end tries to ensure that if class A initialize() wants to overwrite
something (like `@error_count`) in its intialization, it won't get
overwritten ..

ick?
