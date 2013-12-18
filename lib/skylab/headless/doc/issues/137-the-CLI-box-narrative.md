# the CLI box narrative :[#137]


:#storypoint-5

the CLI box node is concerned with adding behavior to a class so that it can
act as a dispatcher and "representer" of child action nodes.

it may or may not be very useful alone because of how many #call-outs it
requires, (in fact not that many), but in any case it is typically used in
conjunction with the DSL node; but we have kept the two separate for modular
regressability, and because they are necessarily two different modules (the
DSL being implemented as module methods, plus a host of instance methods
that implement its strange form of dispatching).



:#storypoint-15

because of the magic of ruby's parameter reflection, these names of these
arguments are actually rendered (by default) in UI screens.

because our default action has been specified as our dispatch method, the
variable names and method signature that appear here is both designed that
way for mechanical reasons *and* appears in help screens with the same
meaning intact. wow



:#storypoint-30

currently box DSL relies on this method being private and being defined with
this name.
# #todo: fuzzy find



:#storypoint-80 (method)

a "porcelain-visible" toplevel entrypoint method/action for help of *box*
actions. the var name you use here appears in the always this is the action
we show the interface. just for fun we result in true instead of nil which
may have a strange effect..



# :#storypoint-90 (method)

in contrast to the similarly named method, once the user is already looking
at the full help screen it is redundant to again invite her to the same
screen



# :#storypoint-100

we wanted to support arguments other than the symbolic action name because
in some cases we may have already built a bound action object, and just want
to show help for that rather than redundantly build another bound action
again (then why not have one method that calls the other then?  #todo:during-merge)

proc and symbol are the only shapes supporte for arguments here becase :[#151]
we want to keep the number of supported shapes to a minimum, and 'callable'
is the most flexible shape there is, because it's effectively a dynamically
executed reference. wait, no, i mean it's a first order function.




:#storypoint-110 (method)

this hackishly results in the array *and* has side-effects (#todo). it is
here b.c it is called by an above method by the parent client. when we
collapse the descs we build the sections too.



:#storypoint-140 (method)

#hook-in to our own API. because we are a box we take action.



## :#storypoint-145 (method)

a convenience -h / --help handler to be used in an o.p block for the option.
the argument is typically the arg passed to your -h (you have to pass it
in the handler block to get here).

hackishly we also just straight up rob @argv of its next token if a) it
doesn't look like an option and b) if you didn't pass one in explicitly.
for better or worse what this gets you is 'foo -h' handled without "foo"
needing to know about it.



## :#storypoint-170 (method)

this method and its instream are private methods that are part of our
:#public-API. a 'create' typically choses what class to use and starts out
an object as a blank slate. 'build' puts any necessary business structure
into it. we need the special name 'box' because elsewhere one action may
have the responsibility of building several different kinds of o.p's.


