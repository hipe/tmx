# the DSL narrative :[#003]



## introduction

at the time of this writing this code is very old. some of these
comments are from the original code and their commit date may not be
indicative of their original time of writing.

we consider this DSL node an :+#abstraction-candidate.




## :#the-shell-narrative

this class was originally called "Joystick" and later evolved into
[#hl-078] what we now know as the popular Shell/Kernel pattern. what
follows is the original text back from when it was called "Joystick" but
with the term search-and-replace'd.

A "Shell" is our cute moniker for the object that forms the
sole point of interface for a DSL. The entirety of the DSL
consists of messages that can be sent to the object.  (Conversely,
the interface of the Shell *is* the DSL.)

The developer would subclass this DSL::Shell class and use
(ahem) DSL of the parameter definer (e.g.) to define the desired DSL.

An instance of this Shell would then be passed to e.g. some
user-provided block, during which the Shell would "record" the
information from the user, which is then retrivable later by the
`__actual_parameters` method.

(In this implementation, the 'actual parameters' is an object
of a simple, custom-built struct built dynamically from the
elements of the DSL.)




## :#note-15

make a simple, custom actuals holder that is just a struct whose members
are determined by the names of the parameters of our DSL.




## :#the-minimal-DSL-client-narrative

(this used to be a struct subclass, but was too confusing w/ `[]=`)

You, the DSL Client, are the one that runs the client (user)'s block
around your shell, runs the validation etc, emits any errors, does any
normalization, and then comes out at the other end with an
`actual_parameters` structure that holds the client's (semi valid) request.
