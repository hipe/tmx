# the CLI box narrative :[#137]


:#storypoint-1

the CLI box node is concerned with adding behavior to a class so that it
can act as a dispatcher and "representer" of child action nodes.



:#storypoint-2

because our default action has been specified as `dispatch`, the variable
names and method signature that appear here is both designed that way
for mechanical reasons *and* appears in help screens with the same meaning
intact. wow



:#storypoint-3

# #todo: fuzzy find



:#storypoint-7 (method)

a convenience -h / --help handler to be used in an o.p block for the option.
the argument is typically the arg passed to your -h (you have to pass it
in the handler block to get here).

hackishly we also just straight up rob @argv of its next token if a) it
doesn't look like an option and b) if you didn't pass one in explicitly.
for better or worse what this gets you is 'foo -h' handled without "foo"
needing to know about it.



:#storypoint-9 (method)

a "porcelain-visible" toplevel entrypoint method/action for help of *box*
actions. the var name you use here appears in the always this is the action
we show the interface. just for fun we result in true instead of nil which
may have a strange effect..




:#storypoint-11 (method)

this hackishly results in the array *and* has side-effects (#todo). it is
here b.c it is called by an above method by the parent client. when we
collapse the descs we build the sections too.



:#storypoint-12 (method)

#hook-in to our own API. because we are a box we take action.



# :#storypoint-99 (method)

in contrast to the similarly named method, once the user is already looking
at the full help screen it is redundant to again invite her to the same
screen
