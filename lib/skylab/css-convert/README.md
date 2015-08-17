# readme

## synopsis

although not fully robust for parsing CSS, this is a "trailblazing"
"canary" project that is kept around because it gives real-world
coverage to important sidesystems.




## original project objective

this project started (perhaps as early as 2010) as a utilty to aid in
editing large amounts of CSS programmatically, for example to merge the
styling of one stylesheet into the styles of another stylesheet, through
for example some regular transformation "function" or thru a "cheatsheet"
of "directives" that would explain the specific mappings to use.

to approach this "robustly" ended up taking a lot longer than the
timeline of the project (months and months vs weeks, respectively), so
it was effectively abandoned for its original intent. (although we
consider it time well spent. it led to some fantastic journeys,
which involved submitting patches to w3c documents.)

incidentally, as a historical note we were attempting this
transformation to help out a PHP project style their python-generated
documentation for ther framework (we don't remember which one)). but the
actual reason was that parsing CSS was an itch we had long been wanting
to scratch.




## emergent project objective (and status by way of)

although this project was effectively "laid off" (or furloughed?) as
explained above, we have kept it "modern" (somewhat) over the years because
A) we thought that maybe one day we would in fact want to use it to do
something clever with CSS and B) it covers some corners of the "universe"
not covered by any other sidesystems"

specifically it is the only utility that actually uses the "isomorphic
methods client". because this facility was a game mechanic too fun to
abandon, we chalked this up as another reason to keep this thing going.




## today

it does not stand a recommonded way to parse CSS (yet). but on this front
it will be fun to see where the state of the art is (in this platform) for
doing so, and compare it to the approach we began here so long ago.
