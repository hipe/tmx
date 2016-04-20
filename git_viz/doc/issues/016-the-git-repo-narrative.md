# the git repo narrative :[#016]

## :#as-for-grit

### historic original paragraph from the 'repo' node, before removing 'grit':

preston-werner, wanstrath, tomayko et al did all the hard work already with
grit so we keep it thin here. the purpose of this abstraction layer is for us
to give some thought about what our requirements are, if we ever decide to
target other VCS's like hg; and to insulate ourselves from implementations in
general.


### but then we were like:

at first it seemed flat-out ill-founded not to use existing solutions for
integration with `git`. but the ones we've seen did not meet our requirements.
furthermore grit's fundamental philosophy seems at odds with ours.

in the prototyping stages of this project we projected that we needed to
use three git commands (ls-files, log, diff) each particular options. grit
does not appear to implement a `ls-files`, and does not support the options
we need for `diff`. we didn't bother looking into `log`. also it triggered
several warnings of unused variables, also the "posix-spawn" library has
circular dependencies. we opted to do this "by hand" with system calls for
now, and then explore other alternatives in the future.


### snippet from the gemfile to integrate grit (here for reference):

    # gem "posix-spawn", "0.3.8"  # avoid circular, or not
    # gem 'grit'




## #what-is-the-deal-with-SHA's?

there is hypotheticaly "wasted" memory in storing a SHA as a string as
opposed to its number: a 40-character long SHA string takes up 40 "bytes",
but has a valuespace of only 20 bytes:

each character of a SHA string has 16 possible values (0-9, a-f).
two characters of a SHA string then have 16 x 16 possible values, or
256. a byte also has 256 possible values (2^8). so every two
characters in a SHA can be represented by (or represent) a byte.

so "2" is the exchange rate: 2 characters in a SHA can represent (or
be represented by) 1 byte. so a typical SHA that is 40 characters wide
can represent the valuespace in 20 bytes, or ~1.15E18 different
values (that is, about a trillion trillion).

so when we use a string that is 40 bytes long to represent a 20-byte
long value, we are taking of twice as much memory as we need to..

if our current typical usage of SHA's involves taking trips back to
the system with the same SHA to get different information about it (and
when we talk to the system we pass SHA's a strings); and we consider the
perspective that a 40-byte SHA is still only about as much storage as half
a typical "line" of text, it may be not worth the processing and code
overhead to bother converting SHA's back and forth to numbers.

here's a summary of the PRO's of keeping SHA's as strings:

  + keeping SHA's as strings is easier for the human to debug

  + keeping SHA's as strings means a smaller code footprint:

    + keeping SHA's as strings means we don't have to convert when
      feeding SHA's back to the system


this is an implementation detail anyway! if we force ourselves to stick
with working with SHA's only thru the class, we should be somewhat
protected if we change our mind on this.
