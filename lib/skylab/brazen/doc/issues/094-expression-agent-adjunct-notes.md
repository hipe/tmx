# the real deal with expression agents :[#141]


(the central document node for expression agents is [#br-093]. this
documnt is part of a related narrative, and is largely historical).

..picking up from where we left off in [#064] the CLI action core instance
methods narrative:

`say` (and the underlying expression agent facility) is arguably among the
most important contributions we have made thus far with headless.

it represents an intermediate evolutionary phase in development, a step
away from the problems of the sub-client implementation and towards what
we are really after.

OK, that's all a bit bombastic. but any software that makes us feel this way
deserves to have tons and tons of words thrown at it. but first, where we
came from:


## what was sub-client (the i.m) good for?

from the very start we knew we had to avoid monolithic god-objects. this is
why we had parent "actions" that dispatched to child actions.

these child objects (what we now refer to generally as "agents") would
be smaller in their scope of responsibility, but they would still need things
from their parent: they would need services (like a stdin to read from),
or they would need methods to support option parsing, or they would need the
ability to decorate text following some kind of prescribed style.

we got happy with ourselves when we realized that for a lot of these services
and behaviors, we could delegate calls upwards ad-nauseum to each 'parent
client' at that level (hence we called children "sub-clients"), until we hit
some "#topper-stopper" as we are now calling it, or we would blow the roof
off and throw those exceptions with those amusing error messages ("could
not resolve a request client because request client is human"). yes, we were
very pleased with ourselves.

this was fine for the short term but like many brilliant ideaa, it did not
scale. we then found ourselves [#fa-030] trending away from the sub-client
pattern.


## so what are we all excited about again?

so, back to `say`: what this method does is it rips out that whole scope of
responsibilty from the client. no longer does she need the six or 8 or 12
methods she might need to (in this case) render and decorate strings.


all kinds of really cool mechanics are made possible by this: the child
can speak into its expression agent like some little word baloon (or better
yet, autotune device). that request for the expression agent may bubble
up and stop at significant points.


              ( human )                 fig. 1  for example, the human
           [ not pictured ]             client submits a request for
               ^    |                   processing (maybe it's just a
               |    v                   tap of a screen).
           +---------------+
           | "top" client  |            the top client resolves some action
           +---------------+            to execute and then dispathces to it
               ^      |
               |      v
           +-----------------+          this action at this level does basic
           | modality ("UI") |          set validation (inner / outer)
           |  action         |          on the request, and can whine of
           +-----------------+          extra or missing parameters, e.g.
               ^       |
               |       v
           +-----------------+          this is where the true validation
           |  API action     |          might happen
           +-----------------+
               ^       |
               |       v
          +--------------------+        but then what if down here, this
          | some random helper |        agent wants to say something
          | verb-like agent    |        (render something) about the request?
          +--------------------+
               ^        |
               |        v
          _______________________
         (   ?  ?  ?   ?  ?  ?   )
         (  the inner cloud       )
         ( life's great mysteries )
         \  ? ?  ?    ?   ?  ? ?  )
          ------------------------

now, sadly we have to interject here and say that at the API level and
below, agents should *not* be concerned with rending themselves (e.g calling
`say`) to this point is a bit moot. but the capability still holds that the
agent down at the bottom could be "speaking into" a "word ballon" that is in
fact getting evaluated by an expression agent that is a façade for services
that the modality action has, namely that of rendering parameters in a
modality specific way.

we hacked our way through architecting this same behavior with the sub-client
model before and boy howdy did it suck. the uptake of all of that was:
sub-client was and continues to be a useful pattern, but it itself *NEVER*
belongs as an instance methods module in a library.
