# the collection controller narrative :[#026]


## introduction

for now this is low-level API documentation, that stands as a reminder
and central hub of what the conventions are for the the collection
controller in terms of the names, name patterns, and general patters of
its interface.




## general conventions

• arguments are passed in volatility order, with most volatile (likely to
  change from call to call) towards the beginning (done for two reasons
  explained elsewhere) with one exception:

  an event receiver (if any) must always go at the end.




## thoughts on HTTP "rest"


we will try to make our "holes in the wall" (see below) correspond to the
HTTP verbs as much as is useful. (see below)
