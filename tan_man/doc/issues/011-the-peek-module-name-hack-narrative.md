# the peek module name hack :[#011]

## foreward

something similar is going on over at [#dt-006]. it looks more
sophisticated there maybe.




## introduction

this is an intense hack. it is an intense hack. scan the first few lines
of a file with a hand-written parser looking for what is the first class
or module defined in the file is, skipping over any comments. if you're
thinking you could do it with a regex, you're thinking it wrong. also,
all of this is wrong.


this implementation is a shameless & deferential tribute which, if
not obvious at first glance, is intended to symbolize the triumph
of the recursive buck stopping somewhere even if it perhaps doesn't
need to.  (i.e.: yes i know, and i'm considering it.)


somehow, going back years [#sy-034] "hack guess module tree" has existed alongside this. that is
now better than this so as soon as this gives you any trouble, use that
instead of this.
