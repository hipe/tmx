# the strategy narrative :[#007]

## introduction

"strategies" (the subject node) is being abstracted from its frontier
client (the unified table) as we write this. [#096.G] describes
precisely how we arrived at this sort of solution (and name) for that
problem.




## issues

begin that this is being abstracted from an application under active
development whose requirements, behavior and architecture are a rapidly
moving target, all coverage for the subject node comes indirectly from
coverage for the frontier node.




## :#note-A

methods under this classification pertain specifically to our policy and
implementation for duping of a "strategies" object (that is, what happens
when you call the `dup` method on a "strategies" object). if this neither
describes your needs nor sounds interesting to you, you can probably
safely disregard this note.

the ingredients behind issue are this: within one "strategies", a single
dependency (instance) can fulfill multiple roles. furthermore, that same
dependency may be (at the moment) fulfilling roles of other "strategies"
structures as well. so the graph that strategies and dependencies make
is not a simple tree. at its essence it is:

              +-----------+           +--------------+
              | depedency | <>-----<> | "strategies" |
              +-----------+           +--------------+

    fig. 1) one dependency can fulfill roles in many strategies
    and one strategy has many dependencies (through its many roles
    each of which is fulfilled by any one dependency).

given the above, when you call `dup` on a "strategies", there is no easy
answer for what the behavior should be for duping each dependency.

so we expose this "initial assignment" facility as a way for the client
to model the answer to this question. when dependency is associated
with roles as an "initial assigment", it is a declaration that that
dependency "belongs to" the strategies object.

when a dup is made of the subject, it is responsible for duping the real
instances of each such dependency as well. the other associations and
associated dependencies, however, are considered "volatile" and are not
carried across the dup boundary.




### :[#.tactical-uptake]

  • we need our own mutable array of initial assignments
  • we need our own dup of each dependency referenced in same
  • we must not carry over any other dependencies or associations -
      it is the onus of the dependency to re-establish this association
      across a dup boundary. (more at next method)




### why?

we need to solve this problem if we want to use the subject objects in
the [#sl-023] "dup and mutate" pattern, which we do.
