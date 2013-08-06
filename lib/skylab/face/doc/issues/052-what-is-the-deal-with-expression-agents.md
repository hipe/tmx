# what is the deal with expression agents?

the expression agent is the context in which your UI strings will be
evaluated. it is an improvement on the (headless) pen [#084]. in fact it has
the exact same mission statement, but a different name.

## thoughts on usage

the expression agent is intented to be more of an idea than a facility.
each application should decide if / how it will leverage expression agents
(the idea) and decided too if / how it will leverage any existing facilities.

the reasoning for this is twofold: 1) the inputs to and methods of expression
may be domain-specific. 2) the output (strings) from expression agents are
modality-specific and/or carry aesthetic design decisions in them, decisions
that should be made explicitly by the application.

### it is different from pen

not in what it does but how it is used - the pen was integrated tightly
with the "sub-client" - for most if not all of pen's methods we would create
a corresponding delgator in the sub-client. not so with expression agents.

expression agents are not coupled as tightly with the parent agent (e.g
client, action). the conceptual break from pen to expression agent is that
we make utterances "inside" an expression agent whereas before we would make
utterances "with" a pen:

compare:

  @y << "this looks #{ em 'really' } good"  # the `em` call delegates to pen

to:

  @y << some_expression_agent.calculate { "this looks #{ em 'really' } good" }

the client is not coupled as tightly to the 'pen'-ish, and likewise where
we make the utterances is not coupled as tightly to the client, which is
better SRP [#sl-129].


## facts on implementations so far

the above said, we so far have only developed expression agents for two
classes of application: those variously of the API and CLI variety. (of
course, there exist on the big board hopes to target other modalities.)

[..]
