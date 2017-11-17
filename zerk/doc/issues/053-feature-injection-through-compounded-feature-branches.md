# feature injection through compounded feature branches :[#053]


## brief statement of the problem

  - a same "option space" needs to be shared by multiple concerns
    that should not need to know about each other. for example, when
    generating a visualization that happens to target ASCII, there are
    options that define the visualization generally and options that are
    only a concern of the ASCII target.




## introduction to the components/pipeline  :[#here.2]

  - (the idea of "primaries" is lifted from the unix `find` utility,
    and maybe IEEE Std 1003.1-2001 (we have to look).)
    ([#052.B] says a tiny bit more about syntaxes like this.)

  - "argument scanner" adapters can be made for different modalities.

  - a client in its exposure of an operation can be implemented through
    a "primaries injections" structure, where each "primaries injection"
    might for example reflect features injected by the different
    stakeholders: modality client, operation. this structure then
    effects a parse of the argument scanner (adapter).

  - each "primaries injection" involves one "stakeholder" (which we might
    call the "injector") and for now one hash. the hash is always this
    structure: the keys are normal primary name symbols, and the values are
    methods. as each primary is *matched* (not parsed) at the head of the
    argument scanner (adapter), this method is send to the injector
    (which should have the argument scanner as member data). the injector
    is responsible for advancing the scanner on successful parse of the
    primary. the trueish-falish-ness of the result of this method call
    determines whether or not the parse continues or stops.

  - each injection can overwrite previous associations..





## original intro

this is an EXPERIMENT for helping to implement what is THE CENTRAL reason
for existence for both [tmx] and "slowie"..

it's premised on the assumption that there's two "operation" *instances*
that will be complicit in the merge..

  - it is assumed that each operation instance can produce a fixed list
    (stream) of normal symbols representing its fixed set of available
    primaries at this moment, the start of the post-operation-resolution
    parsing. (note, though, that at this one moment each operation can
    produce any list it wants).




## hash collisions between branches :#note-1

what if two or more of the feature branches share the same key for
their branch items?

there used to be define-time collision detection (tacitly) between
the sets of names among the member branches (because we flushed *all*
"primaries" into one box at define time); but this implementation
changed (at first #history entry of the code file) and so now there
is not.

now if there is a set intersect among any two of the N branches,
behavior is undefined (but can probably be anticipated by knowing
that we use simple, predictable list iteration and stream mapping
to accomplish lookup and reflection, with no attempt at detecting
collisions there).
