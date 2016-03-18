# synthesis dependencies :[#008]

## intro

we are breaking some rules with the introduction of this now because it
is largely (but not entirely) emerging from our imagination, as opposed
to having been abstracted from the real world. that is to say, it is
precisely experimental.

(*and* we would like to use it for [#ta-007] at least.)




## context & summary

this is now a third kind of dependency, giving us:

  1. plain old dependencies on tasks:

      depends_on :Task_A, :Task_B


  2. depedencies on "parameters":

      depends_on_parameters :param_1, :param_2


  3. this one:

      depends_on_call :Task_A


note that the names of tasks that we reference in (3) will be the same
names of tasks that we could use in (1). but here are the key points
about it:

  • this new kind of dependency has a DSL for fine-grained control of
    parameter procurement from the subject node to the dependend upon
    node.

  • this new kind of dependency allows for the same formal task to be
    "called" multiple times (perhaps with different parameters).

  • for now, this new evaluation happens in total isolation from the
    existing graph. (more on this).

  • this new kind of dependency is evaluated *after* any dependencies
    of kind (1) and (2) are.

  • like the others, this new kind of dependency is evaluated *before* the
    `execute` method of the subject task.

  • if multiple of such dependencies are specified, they are evaluated
    in the order they were defined. (for the other kinds of
    dependencies, definition order is supposed to be meaningless.)

  • like with the others, any failure to satisfy any single one of these
    dependencies will short-circuit and stop further processing of other
    nodes.




## objectives

we embarked on this because of the novelty and imagined power that could
stem from getting more fine-grained control over how tasks can depend on
other tasks. we wanted to overcome the limitation that tasks stand as
singleton nodes in a graph; rather we wanted the option to interface
with tasks in a manner that feels more like a function.

we forsee the possibility that this will allow the "glue" sort of tasks
to be written in a programming style that is more "declarative" rather
than "imperative".




## limitations & issues

we are going to sidestep entirely the issue of checking for circular
dependencies for now, both because:

  • we don't want to muck around with the existing system too much

  • our mind is too boggled to understand what tasks are when they are
    no longer singleton nodes in a graph but rather more like functions.
    (that one proof)

it may be that this whole facility chips away at the notion of what a
task library is and should do :[#009].

because this call is (or could be, after some more DSL) called with
arbitrary new parameters, it seems that it indeed it should be modeled
as an isolated graph (because a task with different parameters is indeed
a different task). but this must be used with some caution: know that
tasked depended on by a "call" will get executed redudantly from those
behind the task that makes the call.




## history

conceptually this feels sort of like a [#ba-047] function chain, but is
polar opposite in how it's defined (very declarative as opposed to very
inline-friendly).
