# what is the deal with expression agents? :[#093]

(EDIT: parts of this document are very old..)

in simplest terms the expression agent is the context in which your UI
strings are evaluated to be rendered for your particular modality.

it is also a placeholder for a much bigger idea that we don't fully
develop here (yet).

the expression agent as a concept is an improvement on [#hl-984] the
headless pen. in fact, although under a different name it has the exact same
mission statement:

we just went and obliterated pen, and here is all that remains of its once
vast empire: this one grain of sand: "Pen (at this level) is an experimental
attempt to generalize and unify a subset of the interface-level string
decorating functions so that the same utterances can be articulated across
multiple modalities to whatever extent possible :[#br-092]"



## :#the-semantic-markup-guideliness

before going into anything deeper, for reference we here offer our list
of commonly used tags (method names) provided by expression agents. this
list is not prescriptive: implement only those tags that you want/need
for your business concerns.

(we sometimes look for good fits from
  [html tags]:(http://www.w3schools.com/tags/tag_phrase_elements.asp) )

+ `and_` - render a list (i.e "union") with positive, inclusive inflection.

         frequently for EN we employ an "oxford comma"-style approach
         here, by saying "X, Y and Z". (although note that our surface
         expression here does not actually *employ* the oxford comma,
         which any educated person will tell you looks dumb and is never
         necessary -- we use the name because it's a cute reference to
         that one song)

         this is not the place for mapping:
         the elements of the enumerable-ish argument should be already
         rendered strings, or values ready to be coerced into strings.
         just like `or_`, which is the same kind of thing but has a "one"
         arity to it as opposed to "all" (i.e. "X, Y or Z" in EN).
         the trailing underscore in the name `and_` (and `or_`) is
         because `and` and `or` are keywords in the host programming
         language.

+ `em` - style for emphasis, alla "*foo*" in markdown, or the eponymous
         tag in HTML. less commonly used. frequently delegated to from
         `hdr`.

+ `h2` - less commonly used. equivalent to the eponymous HTML tag. when a
         header is desired that is less prominent than `hdr`.

+ `hdr` - alla HTML `<h1>`, for e.g. frequently will delegate to `em`.

+ `highlight` - highlight something emphatically, more than `em`. we may
         assimilate this into `em`.

+ `human_escape` - legacy. "smart quotes" as described in `val`.
          basically use quotes IFF necessary (né smart_quotes).

+ `ick` - render an invalid value (for your business definition of invalid).
          `x` is any value. distant ancestor of [#ba-019] the `strange`
          family of renderers, which is a a sane choice of implementation
          for this semantic tag in a black & white string-ish modality.
          compare to `val`, in depicting `x` we frequently like to see
          quotes around the string (when string) to make it look clinical,
          like we are referring to some foreign other object.

+ `kbd` - style e.g keyboard input or code. use only when appropriate -
          avoid use when issuing invitations to actions, instead opt for
          a modality-agnostic means of doing this.

+ `lbl` - render a label for the property field of a business entity.
          this tag will probably be subsumed by `par`.

+ `omg` - very legacy. "style an error with excessive & exuberant emphasis"
          like `ick` but more emphatic, e.g renderd in red in CLI. eew.

+ `or_` - described at `and_`


+ `par` - render a parameter name given a symbol. allows you to
          reference it by symbolic name without needing to know what its
          surface manifestation is in the particular modality.  for e.g.,
          when in a command-line modality, we frequently do the fun hack of
          rendering command line parameters either as options or as
          arguments (or as environment variables!) appropriately.
          this tag will probably subsume `lbl`.
          the (somewhat demanding) logic for this is tracked by [#hl-036].

+ `pth` - for security-ish reasons as well as aesthetics: when rendering
          to many more porcelain-y contexts it looks too detailed to
          render full filesystem paths; so with this tag we frequently
          employ a variety of strategies to shorten them (usually using
          the shorthand notations for current directory and home
          directory ("." and "~" respectively)).
          the legacy (and more formal) name for this is `escape_path`.

+ `s`   - passed a value that be resolved as a count-ish, hack the
          letter `s` to hack-pluralize a singular into a plural for EN.
          this same method, being one of [#hu-002]:#these-methods,
          may be used to do much more, i.e inflecting other semantic
          categories as well.

+ `val` - render a business value. if `lbl` (or `par`) represents one
          side of a key-value pair, this is for the other. compare to
          `ick`, here for strings we might do "smart quotes", i.e
          quoting the string only if it has a space in it. for black and
          whites, rendering `x` as-is is a common choice too, which
          looks good nexted to a styled `lbl` (or `par`) tag, but can look
          cluttered with styling of its own.


    def em s ; pen.em s end       # style for emphasis

    def human_escape s ; pen.human_escape s end  # usu. add quotes conditonally

    def hdr s ; pen.hdr s end     # style as a header

    def h2  s ; pen.h2  s end     # style as a smaller header

    def ick s ; pen.ick s end     # style a usu. user-entered x that is invalid

    def kbd s ; pen.kbd s end     # style e.g keyboard input or code

    def omg s ; pen.omg s end     # style an error emphatically





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

sometimes wrapped as:

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
vary based on the particular business of the domain and modality
(although we frequently draw from a frequent pool of "tags" that have
emerged, see #the-semantic-markup-guidelines above).

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
course, there exist on the big board hopes to target other modalities,
an effort that require a fundamental reworking of some of the above
assumptions, but will hopefully allow us to retain its same spirit.)

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



## case studies & notes

### :#note-br-10, :#point-10

using the expression agent singleton is for hacks and one-offs. the
expression agent has a long-running NLP agent holds state of the speech
situation. when using the expression agent singleton, it just as likely
as not that it is holding state from a speech situation prior to yours;
resulting in behavior that may appear non-deterministic and may cause
to fail flickeringly and in a manner hard to track down.

we intentionally do not offer any cache clearing facilities: this would
be a step in the wrong direction. in a mature application each action will
create its own expression agent instance.




### :#case-study-st-2: when to subclass expression agents

the more important questions is "when *not* to?" and the answer is
"usually.": the expression agent is the one component that we have no
qualms about "duplication" efforts over across applications: the kinds
of styles the application will need to express stem from the semantic
categories it expresses itself through, and these semantics categories
stem from the business concerns of the particular application.

the subject expag is a :+#frontier node pushing forward the expag as a
gateway into the broader possibilites of per-model modality adapters,
which itself should be thought of as a gateway to not doing this..

we want our business actions written for The Common Modality to be able
to express its events as data divorced from presentation.

the semi-generated target modality application adapter should be able to
render this data (received as "line-items") in a form appropriate for
the modality, for example a table.

although we (for now) encourage the duplication of efforts of writing
expags *across* applications, we don't want to duplicate efforts within
them. however, it is a smell in the other direction to make monolithic
spaghetti expags that serve all purposes for all actions of all models
within the application. for this reason we have made this per-model
expag subclass.

disjoint thoughts:

  + the procedurally generated action modality adapter should ultimately
    query the constant graph for customized expags.
