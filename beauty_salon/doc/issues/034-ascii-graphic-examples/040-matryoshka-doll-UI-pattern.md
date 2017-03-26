# the matryoska Doll UI / controller architecture pattern :[#040]

## edit

most of the thoughts expressed herein gave rise to and have been
obviated by the [#br-013] model; however this is maintained (for now) as
a historical document so that posterity remembers how different things
were before they were good. as well we are maintaining this node as the
one day home of the introduction to the concept of "modality".


## clients and sub-clients revisited at the most basic level

### where we came from: sub-clients

one of the primary Grand Visions of headless (a predecessor to this library,
and the first good one) was the idea of "sub-clients" -- everything was
thought of as a sub-client to anther client.

                     +--------+    +------------+
                     | client |---O| sub-client |
                     +--------+    +------------+

    fig 1. a given client might "have many" sub-clients. a sub-client
    then "has one" parent client, or "request client".

although we may avoid the term "root" now, we used to conceptualize what is
generally called an "application" as the "root client", and things under it
were called "sub-clients."

this design was fine and good, but the particular way it was implemented had
some issues. we frequently made a "SubClient::InstanceMethods" in our
application, a module that was composed mostly of delegators upwards. every
client, big or small within a "modality" (explained below) would typically
include that i.m module. this created for poor separation of concerns and
did not scale well (introduced and explored in [#030]).

  #todo triforce, etc


## in face CLI, where to put resources, what level? what "shell?"

specifically in reference to the grand refactor marked by [#037], and harkening
back to the sub-client pattern (which, as it has been implemented is falling
out of favor but which in its conceptual design is evolving into this); the
matryoshka doll UI pattern is one where in the interest of simplicity and
orthogonality of API's, all other things being equal, tree-like interface /
controller structures should pass relevant resources and information from
outside-in.

at its surface (pun intended) it sounds simple and straightforward.  it is
bit like the reverse of the DOM event model in a web brower, where a component
(like a button) receives an event (like a click), and may indicate a handler
("callback") make to handle such events, and if it does not handle the event
the event "bubbles up" out to larger and larger components until it finds
one (if any) that wants the event.

in our case (what we now call the [#pl-011] "model-centric operator branch), the event
is received by the outermost component and gets "bubbled in" to successive
layers of component whereby at each level, all the component needs to to
is either ignore the incoming event, respond to to the incoming event, or
dispatch it downwards (and the the the response is typically bubbled back
upwards in a similar manner).

this is illustrated in [#bs-035] "the stratified event production model".



## stratified event handling, production and distribution applied

when brass tacks are put down to where the rubber hits the road, it's
possible to cut off your nose on a grindstone to spite your face. er ..

to jump ahead for a second, the "mechanics" node (or "kernel" if you like)
has a domain of concern that is controller-y so it's tempting to have that be the
"source" of things like @y, for e.g. But we write this note here for ourselves
to remind ourselves that that's not how we want face CLI to work. the API user
should be able to customize the value of a relevant resource by setting it as
an ivar in the "outermost" ("surface") shell, (maybe between invocations even,
when relevant!) and then the 'mechanics' shell should then resolve its
resources from its surrounding shell.

remember that a) heavy lifting should be performed by the mechanics but b)
light lifting from the client-user's perspective should always be able to be
done with only the surface class, while remaining blissfully ignorant of the
underlying mechanics where possible. to design such a stack of abstraction
that is both leakproof and sublimely intuitive at whatever particular level is
arguably the goal of this whole project - this whole stack of turtles.

simple does not simply arrive as simple.

## architecture breakdown

at its most basic level we conceptualize a modality client as something that
"has" many actions ( in that it provides an interface for invoking them ):

             +---------------------+        +--------------+
             |   modality client   |-------O|    action    |
             +---------------------+        +--------------+

we like to have the ability to compartmentalize the actions using namespaces.
we like to implement this by conceptualizing the namespace as an action whose
service is delegating to and presenting reflection of other actions; actions
that themselves may be other namespaces. we can then conceptualize the
outermost client as a namespace itself:

             +-----------------+   +-----------+   +--------+
             | modality client |-->| namespace |-->| action |
             +-----------------+   +-----------+   +--------+
                                        |               O
                                        +---------------+

that is, the modality client is a special kind of namespace. a namespace is a
special kind of action. a namespace has many actions. (since a namespace is an
action, a namespace can have other namespaces inside of it.)

the above design was OK and served us well as the first rewrite of F-ace.
however it was not quite perfect given that we wanted to do the
"public methods as DSL" hack. all kinds of smells cropped up as we tried to
avoid having our implementation methods bump into our business action methods.


## the rearchitecting of [#037], illustrated

We like exploiting the isomorphism of public methods as business actions
(it is not only an elegant and cute-sy hack, but it mirrors the deeper spirit
of the whole project); yet in practice the design can feel kludgy and does
not scale: a class with a restricted public method namespace makes objects
that are quite hard to design interactions with at levels lower than the one
of human interaction.

to restate it in more formal (if not clear) terms, the issue with :[#037] is
this: you cannot both exploit the 'method_added' hack and have a class that is
useful and future-proof without reconciling the fact that your business
namespace will always be at odds with the API namespace if they are both
drawing from the same method namespace.

indeed this same problem is illustrated in the dynamic of using a ::Struct
class: look at every instance method that ::Struct defines. what if you want
to define a struct member with that same name? what should happend? what does
happen is that your member name trumps that instance method name, and you
simply can no longer access that method, with this being the only consequence.

in the case of facilities like ours that have exploited the 'method_added'
hook, to date we do not fail so gracefully. the simplest way to appreciate
this is to take this case: two methods that are a part of our public API
for CLI clients are the `initialize` method (it takes three arguments for
the three streams) and the invoke method.

but what if in your business box action you want to use the verb 'initialize'
or 'invoke' for your action names? you really can't with just the method
added hack alone. there are of course a number of ways around this..



## the matryoshka doll as one experimental solution to this.

To address this we further granulate our mother with
the idea that the DSL-ly nodes be broken into two parts, one "surface" and one
"mechanics":

       +--namespace ("surface")--+
       |                         |
       |  +----- mechanics ----+ |        +---- command ----+
       |  |                    |---------O|                 |
       |  |                    |--------->|                 |
       |  +--------------------+ |        +-----------------+
       +-------------------------+
                  ^
                  |
       +-------- CLI -------+
       |                    |              ( arrows indicate inheritance )
       +--------------------+

This works well because the interface designer expressing business actions
need only concern herself with adding public instance methods to and calling
DSL methods on the namespace classes; and to this end she has an open
namespace (now both public and non-public) of methods that she may create.
as for all of the services and behavior that the face CLI API provides, its
implementation is wrapped up inside of the 'mechanics', and may add and
remove methods and other support classes freely to this end, insulated from
any business action namespace or concerns. but then the question becomes:


## which parent?

because of this new dichotomy introduced by above, one where we have an
outer "surface" and an inner "mechanics" for any namespace, when we say
"parent" we have to ask "which parent? the mechanics or the surface?"

              +----------- CLI client (is a surface) ----+
              |                  |    ^                  |
              |                  v    |                  |
              |    +-------- CLI mechanics --------+     |
              |    |     | ^       | ^      | ^    |     |   ( v = request )
              |    |     v |       v |      v |    |     |   ( ^ = response )
              |    |  +-------+ +-------+ +------+ |     |
              |    |  |  ns1  | |  ns2  | |  c1  | |     |
              |    |  +-------+ +-------+ +------+ |     |
              |    +-------------------------------+     |
              +------------------------------------------+

(the CLI client has (at its immediate level) two namespaces ("ns1" and "ns2")
and one non-namespace command ("c1"); managed by a mechanics.)

There comes a time when any of these nodes may need to request resources
from its parent. the question again is, "which parent, mechanics or surface?"
In constraining ourselves to the simplicity of the matryoshka doll pattern,
the answer is always "mechanics". the only node that should ever be reaching
up to a surface is a mechanics. that is the answer.

~
