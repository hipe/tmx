# the scanners narratives :[#022]

## introdocution

the scanning metaphor has become favorite way to implement "producers" (or
even just to represent lists abstractly) in a general way.

we like the scanner construction because it lets us distill a huge swath of
data-structures and iteration operations down to one RISC-like minimal
standard on top of which we build back up our tools, making an even huger
variety of permuations of these operations both possible and easy.



### defined

our formal definition for "scanner" is intentionally spare, and takes its
"look and feel" from how we may get each line from an open filehandle:

• a scanner is an object that produces each next element with a call to `gets`
• a scanner indicates that it has no more objects left to yield by resulting
  in a false-ish from a call to `gets`

the fact that we use `gets` and not some other name is of course arbitrary.
(`call` and `next` were considered.) we borrow the name from ::IO because the
metaphor is such a precise fit, but bear in mind a scanner is not limited to
producing strings (the 's' in "gets"), however:

a corollary of the second point above forms one of the scanner's most
defining limitations: a scanner cannont be used to produce elements whose
valid state may include `nil` or `false`.



### scanning vs. enumerating

#### scanners are like enumerators made portable mid-iteration

in the last year or so the scanner metaphor has overtaken the comparable
Enumerator construct as the generally prefered "universal interface" for
production operations for a few reasons:

whereas the Enumerator's big value prop is that it is a list iteration made
portable, a scanner is a list iteration made portable along with its
"scan state" (that is, index of the current element if you are scanning an
array). so one part of your code can build the scanner, another part of the
code can advance it to a certain state, and a third part of the code may
do something with the rest, and so on.

with an enumerator all of this is possible, but it is not the kind of
interaction the enumerator was made for: an enumerator is like a wind-up toy:
it likes to unwind all at once, it doesn't easily stop in the middle. in order
to get only one element at a time from an enuemrator you have to call `next`
while catching a ::StopIteration, which is a show-stopping level of ugliness.

a scanner is more like a PEZ® dispenser: it was engineered to issue preciesly
one element at a time on-demand, rather than spit them out all at once.
like a PEZ dispenser it can be passed to one "person", that person can keep
taking PEZ until she is satisfied (i.e she reaches the quanitity she was
looking for, she finds the particular one she was looking for, or all the
PEZ run out); and then she can pass the dispenser on to the next appropriate
person and so on.

(to stretch the metaphor even further, the person she decides to pass the
dispenser to may itself be determined by what particular PEZ were that the
dispenser dispensed! but that's crazy talk.)



#### a scanner may be more efficient

this is not the primary reason we use them when we do, but [#bm-011] scanning
is more efficient than enumeraing for some operations, operations that often
describe our use case.

this is probably just because of the way we typically use them: an iteration
over an enumerator is usually done with something like `each`, a method that
creates one call frame for each iteration. whereas, iteration over a scanner
is usally done with sommething like `while`, which does not create its own
call frame.



#### a scanner is not a general replacement for an enumerator.

as sugested above, the set of all lists that a scanner may represent is a
subset of the set of all lists that an enumerator may represent because of the
semantic overloading we apply to the result value of `gets` (namely, when it
is false-ish it is a control-flow boolean, when it is true-ish it is both a
control-flow boolean and a business value).

although the reverse is not necessarily true, any scanner may be translated
to an enumerator regularly (simply: your body of the enumerator is a while
loop iterating over your scanner, and pass each element to the yeilder).

enumerators are still good for all the things that they are good for, so
don't use a scanner when an enumerator is a better fit. our point in this
article is just to say that the scanner is a better choice for a universal
way to model iteration, for the kinds of iterating we generally do.



## :[#023] the array scanner narrative

in theory the array can be mutated mid-scan, but this is not tested so assume
it will not work right off the bat. internally this just maintains two
indexes, one from the begnining and one from the end; and checks current array
length against these two at every `gets` or `rgets`.

(leave this line intact, this is when we flipped it back - as soon as the
number of functions outnumbered the number of [i]vars it started to feel
silly. however we might one day go back and compare the one vs.  the other
with [#bm-001])



## :[#004] the list scanner for read

### implementation

just for fun we implement our own double-buffering. yes, OS IO is better at
this generally, but we do it ourselves just as an excercize, and in case we
ever want to have arbitrarily complex critera for what constitues a record
and record separator.

also as an excercize, this is written in functional soup: the only instance
variables that we employ are either procs that operate within a closure, or
they are auxiliary service accessors (i.e not part of the core algorithm or
operation). all of our public methods simply wrap these procs (or again are
auxiliary).



### usage

just like when calling `gets` on an IO, each call to `gets` result in each
next line from the IO, without ever adding or removing its own newlines, but
the resultant line will end in a newline sequence if one existed in the file.

`count` will tell you how many lines have been read by gets (0 when the object
is first created, 1 after you have successfully `gets`'ed one line, etc).

`gets` will result in `nil` (possibly at the first call) when the IO has no
more bytes left to give. `gets` can be called any number of subsequent times
and will continue to be `nil`.


** NOTE **

the filehandle is closed by this scanner at any first such occurence of the
end of the file being reached, but NOTE it will not be closed otherwise.



## :[#024] the string scanner narrative

minimal abstract enumeration and scanning of the lines of a string.
+ quacks like a simple scanner
+ better than plain old ::Enumerator b.c you can call `next` (gets)
    without catching the ::StopIteration.
+ future-proof: maybe it uses ::S-tringScanner internally, maybe not.


### the 'reverse' scannner

it is just a clever way of building a yielder that expects to be given with
`yield` or `<<` a sequence of zero or more lines that do not contain
newlines.
