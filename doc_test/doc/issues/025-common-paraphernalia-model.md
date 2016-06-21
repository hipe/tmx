# a common paraphernalia model

## synopsis

"common" paraphernalia is paraphernalia likely to be found in most test
suite solutions. they are phenomena like "examples", "tests" (see), or
"setup" (methods). because we *always* implement these as models (or
if you prefer, plain old classes) we house these under "models" for now.

the reason we distinguish "common" from "particular" is so that we can
re-use facilities across output adapters while allowing each particular
output adapter its own freedom to work with whatever paraphernalia is
appropriate for that solution (to the extent that etc).




## spec-ish

  • the subject instance *MUST* implement one of the methods from the
    as is appropriate to produce its output; i.e. it is somewhat like an
    autonomous rendering component, but for now the caller must know
    which method is appropriate. experimental.
        • `to_line`
        • `to_line_stream`

  • the subject class *SHOULD* have ad-hoc custom constructor methods,
    tailored to the particular shape of its input data.

  • the subject class *CAN* take a "choices" object in its constrution.

  • the subject *WILL TYPICALLY* provide a collection of "services"
    (methods) for an implementing "particular paraphernalia" to draw
    on in its implementation.
