# test numberspace convention

## convention

the tests are given unique numbers that draw from the pool of integers
0-99, representing a totally "gut" estimate of how complex the
implementation of the corresponding asset node "feels"
(1 being the least complex-seeming).



## rationale

having the more complex nodes towards the end can generally reduce
debugging time ([#ts-001]); although in this node the effect may be less
pronounced because all of these nodes are fully interdependent of each
other. but even here the mechanic may be useful because compatibility
issues of a more "fundamental" nature will hopefully gain precedence of
smaller issues.

if none of this makes sense, image the numbers as a "recommended order"
in which to approach the tests if you were to try to apply them to a
"totally alien" system.



## emergence

some non-designed boundaries have emerged:

    00 to 09 - not really relying on the system per se.
               maybe just adjunct or support or taxonomically near.

    10 to 19 - platform recognition exists for these facilities
               in the stdlib.

    20 to 29 - a unix shell builtin for which we are hacking our
               own adapter to (and no platform stdlib recognition).

    30 to 99 - a unix utility that (same)
               (73 is reserved for `diff`)
