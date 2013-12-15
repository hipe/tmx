# what is the deal with expression agents? :[#052]

the expression agent is the context in which your UI strings will be
evaluated. it is an improvement on the (headless) pen [#084]. in fact it has
the exact same mission statement, but a different name.

we just went and obliterated pen, and here is all that remains of its once
vast empire: this one grain of sand: "Pen (at this level) is an experimental
attempt to generalize and unify a subset of the interface-level string
decorating functions so that the same utterances can be articulated aross
multiple modalities to whatever extent possible :[#hl-084]"

## thoughts on usage

as far as support libraries in this universe are concerned, the expression
agent is more of an idea than a facility. each application should decide if /
how it will leverage expression agents (the idea) and decided too if / how it
will leverage any existing facilities.

the reasoning for this is twofold: 1) both the methods of and inputs to
expression agents are domain specific. 2) the output (strings) from expression
agents are modality-specific and/or carry aesthetic design decisions in them,
decisions that should be made explicitly by the application rather than any
support library.

### it is different from pen

not in what it does but how it is used - the pen was integrated tightly
with the "sub-client" - for most if not all of pen's methods we would create
a corresponding delgator in the sub-client. not so with expression agents.

expression agents are not coupled as tightly with the parent agent (e.g
client, action). the conceptual break from pen to expression agent is that
we make utterances "inside" an expression agent whereas before we would make
utterances "with" a pen:

compare:

  @y << "this looks #{ em 'really' } good"
    # the `em` call above delegates to a pen (not seen).

to:

  @y << some_expression_agent.calculate { "this looks #{ em 'really' } good" }

more commonly wrapped as:

  @y << say{ "this looks #{ em 'really' } good" }

the client is not coupled as tightly to the 'pen'-ish, and likewise where
we make the utterances is not coupled as tightly to the client, which is
better SRP [#sl-129]:

in the first example the client must respond to the `em` message, usually
one of many methods written by hand as a simple wrapper that delegates to the
e.g pen (now called "expression services"). this is exactly the coupling that
causes headaches down the road for us, a kind of coupling that is severed in
the last two examples, where there is a strong line of demarcation separating
the concerns of utterance production from the other business concerns of
the client (not shown).

#### "this is why we can't have nice public business methods"

above we explained that we want to create a separation between the client
objects that produce expressions from the methods that help to decorate those
expressions. in this document we may refer to those methods as
"business methods" because their particular names and composition will
vary based on the particular business of the domain and modality.

as a matter of design and principle all business methods of an expression
agent are private. (this is the only differentiator between it and an
"expression servcies" object, what used to be called "pen" or "stylus".)
this may come as a surprise because after all, the only business of the
expression agent is to express so why are its methods of expression then
not public?

the reason is in how the expression agent is used: for readability we access
the business methods of the expression agent within a block that is executed
with the expression agent as the receiver. that is, we say:

  @y << say { "i #{ em 'love' } this" }

which is effectively:

  @y << expression_agent.calculate { .. }

because of the way it is used, the expression agent doesn't *need* its
business methods to be public. we therefor flip these methods private to
propagate this Good Design. if your application finds itself needing the
methods to be public in some cases, one option is to generate dynamcially a
sub-class of your expression agent class, with all of its business methods
made public (this can be done in only a few lines of dark hackery).


## facts on implementations so far

the above said, we so far have only developed expression agents for two
classes of application: those variously of the API and CLI variety. (of
course, there exist on the big board hopes to target other modalities.)

[..]

## integration approaches (fact and fancy) so far

### a purely headful API, for e.g

you could make a "purely headful" API, that is, your API cannot be used
unless it is attached to a ("modality") client. (hm this is a good idea,
we should reconceive things this way. it's a different way of saying what
we are currently doing..)

### one particularly granulated pipeline:

(this illustration starts from halfway though the end-to-end processing of
 a request. not shown is the beginning where the modality client receives
 the initial request and creates and routes the request to a modality action,
 which in turn creates and invokes its sister API action..)

                                            +-- 2) --- Modality Action -------+
 +- 1) ---- API Action --------+            | (note the API Client doesn't    |
 | your particular API action  |        +-> | participate from this point)    |
 | having been invoked could   |        |   | the particular modality act.    |
 | call 1 of any procs of its  |        |   | having exposed `emit_p` as a    |
 | parent svcs, sending it a   |-- msg -+   | service will receive the msg &  |
 | structured message (event)  |            | with its particular expression  |
 +-----------------------------+            | agent, collapse the message e.g |
                                            | to a string or some other mode- |
                                            | specific representation       ...>
                                            +---------------------------------+

                                              +-- 3) -the- Modality Client ----+
    +-- 2.2 --- Modality Action ----------+   |  .. having received the        |
..> |  having "flattened" the structured  |---> msg in a format not particualr |
    | message, the modality action now    |   | to the business of the part-   |
    | passes the message upwards to *its* |   | icular action now [collapses   |
    | parent node via calling an `emit_p` |   | it again maybe, using another  |
    | that it got from the services of    |   | expression agent] and sends it |
    | same..                              |   | upstream somehow to a (perhaps |
    +-------------------------------------+   | human) parent client.          |
                                              +--------------------------------+
                                                               |
                                                               V
                                                          [ ~ human ]


## the distinction between an expression agent and an expression services

the former has private methods. utterances are intended to be evaluated inside
of it. the latter reveals usually these same methods as public (this is the
general meaning of the term "services" here: an object with public methods
that can be called..).

the reason we made "expression services" separate from "expression agents" is..

## "expression services" are to help transition off of pen [#052:02]

but they should be considered deprectated. this is why our (at the time of
writing) headless expression services-related modules have two underscores
at the end of there name - as a reminder that they are deprecated.
