# the perfect agent interaction model

at long last we have found it. the problem is it only exists in our heads.
we will have to wait until we come full circle and bring four huge branches
together. i hope it won't be 2014 by then but it probably will be.

anyway when something is perfect you must not lose it, you must make
ASCII drawings of it.


## 1. the client can operate independent of available bundles.

                +----------+     +----------+
                | bundle 1 |     | bundle B |
                +----------+     +----------+
                     +------------------+
                     | its parent class |
                     +------------------+
                       ^
                       |
                +-------------+  <--  to
                | your client |            [ the outside world ]
                +-------------+  --> fro

                 fig 1. bundles are just chillen

your client descends from an imaginary client base class and somehow gets
instantiated. note how there are bundles up there, but they are just chillen.


## 2. when the client employs a bundle, the bundle somehow gets what it
needs

                       +---------------+
                       |  your client  |
                       +---------------+
                             ^   |
                             |   |
                      [ "client services" ]
                             |   |
                             |   V
                          +---------+
                          | bundl 1 |
                          +---------+

              fig 2.A. the client services façade

the client services façade is a popuar choice to manage providing *basic*
services to the sub-agent, but it is not the only way. other equally suitable
mechanisms include:


• ### be funcy
  pass simple arguments in, get one result value back, "function"-like.
  maybe the agent even *is* a function. you don't know, which is the point.
  (MetaHell::Funcy in all its 3 lines of glory facilitates this.)

• ### huge iambic parameter lists
  if you need more than one or two arguments you might consider using an
  iambic parameter lists. they are both more readable an more flexible.

• ### schlurp
  a nearby upcoming commit will explain and mark this #todo:before-merge

• ### pass yourself in
  just pass yourself in and you (the child agent) just hack out what you
  need from it. don't do this. this is what we used to do and it was bad.

• ### act like java
  we almost never do this because it never looks idiomatic, but you can
  just make plain old classes and set their values as setters or arguments
  to the constructor.


## but none of this is the point

all of the above is actually the boring part (can you believe it?). it is
concerned with how we get information in *to* the agent, but that isn't the
sexy part. the sexy part is how we get information back from the agent.

the participating agent will define staticly a set of one or more semantic
channels. the agent can have only one, but it must have a least one.

        +--------+    =--------------------=    +-------+
        | client |  <--  semantic channel  <--  | agent |
        +--------+    =--------------------=    +-------+

             fig 3. an agent with one semantic channel

it is not supposed to look like a pipe from mario world but if that's what
you're seeing then we are on the same page.


a  "semantic channel" is a bit of an abstraction: at our first go of this,
it won't be defined in a formal sense or even in a code sense, but the
way it works out, such trappings of this mortal coil will not be necessary
here on the mountaintop.

i'm so excited i almost can't wait to tell you about the rest, but it may
have to wait, it's 3pm and i'm tired.


## the partipating bundle will define zero or one IM's module with
     default callback behavior

by employing the bundle, the client could automatically get this IM's
module included. she may then of course override methods as necessary.


## the client will use namespaced semantic handler methods to receive
  callback events

an event could be an arbitrary ruby value, but it is recommended to use
event structures like [#089] the magical, multipurpose Event base class
(but this brings us outside of our scope finally).

when we get back to the "namespaced semantic handler methods" we will pick
back up with this, but we honestly can't remember what branch those are in.
