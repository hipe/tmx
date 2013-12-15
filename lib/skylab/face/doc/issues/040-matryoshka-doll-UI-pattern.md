# the matryoska Doll UI / controller architecture pattern :[#040]

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

at its surface (pun intended) it sounds simple and straightforward, much like
the DOM event model in a web browser (you click on a thing, e.g, and it bubbles
from outside in until something intercepts it).

however when brass tacks are put down to where the rubber hits the road, it's
possible to cut off your nose on a grindstone to spite your face. er ..

the "mechanics" node is controller-y so it is tempting to have that be the
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

the above design was OK and served us well as the first rewrite of Face.
however it was not quite perfect given that we wanted to do the
"public methods as DSL" hack. all kinds of smells cropped up as we tried to
avoid having our implementation methods bump into our business action methods.


## the rearchitecting of [#037], illustrated

We like exploiting the isomorphicism of public methods as business actions
(it is not only an elegant and cute-sy hack, but it mirrors the deeper spirit
of the whole project); yet in practice the design can feel kludgy and does
not scale (a class with a restricted public method namespace makes objects
that are quite hard to design interactions with at levels lower than the one
of human interaction). To address this we further granulate our mother with
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
