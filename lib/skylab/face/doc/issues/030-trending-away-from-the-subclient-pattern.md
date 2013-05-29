# trending away from the sub-client pattern?

we may be. sub-client was a huge jump forward when we created it for
headless. conceiving the application stack as a huge tree with nodes that
delegate behavior upwards was an elegant, simple and powerful model, one
that we plan to continue to use (conceptually at least) into the future.

but it is beginning to show signs of strain: we have to add ad-hoc methods
to the universal SubClient__InstanceMethods when we are doing topic-specific
changes. it is poor separation of concerns.
when we want to use a node somewhere else, we don't know which
of the above methods we must implement in the parent.

the next big "revolution" after headless was "plugin". what "plugin" has over
headless's subclients is that each individual node may declare (or not declare)
those `services` that it expects from the parent. it can remain ignorant of the
parent's particular shape, other than the parent have a plugin host interface.

this way makes our code more modular reusable blah blah - something that is
should be evident in this commit.
