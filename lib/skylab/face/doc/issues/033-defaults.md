# all about entity-level default fields

it is a meta-field, you must pass a function. it gets exacted iff its nil.

making it always must be a function is the great equalizer - this way you
could for e.g have your default value itself be a function ( by having
a function inside of a function : two levels ). doing it any other way
(with only one meta-field) always leaves holes.

also, note that the default function will be `instance_exec`'d on the action
object becuase it is generally much more powerful that way.
