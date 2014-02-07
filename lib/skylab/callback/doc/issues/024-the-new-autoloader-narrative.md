# the new autoloader narrative :[#024]

• gleaning from what we've learned from [mh] a.l, new a.l has most of the
  features of old but in a fraction of the space & complexity

• employment features ('boxxy', explicit specification of dir pathname) are
  implemented each as a singleton methods on the autoloader module (currently
  there is only one but this is desiged to be amenable to rearrangement such
  that it makes a stack of modules each "extending" the former, in terms of
  features explained below).

• these "feature functions" are implemented as methods but float around in
  space as if they are procs, which is win-win: we get the narrative
  extensibiltiy of methods but the "first-class-object" nature of procs.

• each such method is passed the x_a and if the feature decides it matches the
  x_a it mutates it accordingly (or perhaps not, in theory) and results in a
  proc that might eventually be passsed the "employer" module as its one
  argument.

• (any such method must result in either a false-ish or a proc-ish. and any
  such proc-ish must accept exactly one argument).

• the only possible outward signal that an error occurred parsing the iambic
  arguments is if there is any remainder to the x_a array after all the
  features have attempted to parse something out of it.


## when such a parse error occurs, argument error message generation is novel:

• one of the things we gain by dealing with methods that are treated as procs
  is that they know their own name

• if the feature method name follows the name convention (which it doesn't
  need to), we can infer that it is either a "'keyword'" or an "<argument>"
  and decorate it accordingly

• we will report that there was an unepected 'W', and that we exepected
  'X', 'Y' or 'Z'; but the "X, Y or Z" will be inferred from those features
  that were not engaged (yet) from the set of all features during this
  parse.

• a more overblown way than this was considered: that each feature be
  implemented as a proper structure in its own right (a class, etc) to effect
  all this "metadata" but this was seen as too overblown at this stage.

• the strategy we have adopted here is seen as neither overblown nor
  underblown, but perfectly blown.


## provided there are no parsing errors with the iambic employment arguments

• atomically and in a pre-determined order, each proc from all the features
  that matched the x_a is reified on the employer module in an order
  determined by the "macro bundle" module.

• whatever the feature actually does to the employer module is of course
  totally up to the scope and domain of that feature.


## in conclusion,

• this perhaps the beginnins of a clever, extensible bundle implementation
  in its own right but for reasons of both bootstrapping and freshenss we
  don't worry now about whether this logic belongs somewhere else (yet)
