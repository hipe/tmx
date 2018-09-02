"""
.:[#410.W]: custom keyers for syncing (#coverpoint1.6)

in pure theory, the human keys of the near and far collections are "normal"
(meaning two keys represent the same thing IFF they have the same value)
and syncing just works.

if normalcy were a requirement for human keys, then that would be the end
of it and we could go home. BUT:

for our typical use cases, a convenient convention is to use as human keys
labels plus URL's:

    [Some Thing](http://xyx.eg/foo)

but what happens when the URL changes?

    [Some Thing](gopher://ohai.edu/foo)

or the label changes?

    [SomeThing](http://xyx.eg/foo)

without taking extra measures, such an arrangement leads to (what amounts
to) duplication; that is, a new record is added to the near collection when
what we wanted was the new record to be used to update an existing record.

this might reveal something of a "smell" of human keys, or at least a gotcha.
probaby the "right" way to address this is to add more fields, where you
would split the formerly one column up into three, and make sure that you
store some sort of normalized identifier ("human key" if you like) separate
from the label and separate from the URL; so that the label and URL can
change independently of a human key that stays permanent for the lifetime
of the entity.

but experimentally, we're seeing if we like this way instead:

a "sync keyerser" is a function specified by the far collection to be used
to create simple map functions for the human keys of the near and far
collections (separately). huh?

user-provided functions can be specified to be used to map *unsanitized*
human keys to *normal* human keys. (we won't "see" the normal keys, they'll
just be used internally. in fact, we might even drop the qualifier "human".)
there will be one function for near keys and one for far.
(#open [#410.F] will change this.)

the thing we're trying to get is a key (one key for one record). we may
name a function that makes keys (from unsanitized keys) a "keyer". but
there's two of those: one for near and one for far; hence "keyers". the way
these two keyers are specified by the user is in the form of *one* function
that will return a tuple representing the *two* of them (near and far, in
that order). *this* function is called the "keyerser". (meh)

remember there is a blood-brain barrier for far collections: they must be
expressible using only simple primitives and structures, so they are
transmitable as straightforward JSON without any magic unserialization.

this means we cannot just pass a user-defined python function (reference)
from the far to near. rather, the far collection specifies the (any)
keyerser as a plain old string. this string indicates the name of the user-
defined python module to load and the name of the function within that module.

such a keyerser identifier must have one period in it and look something like:

    my_module.my_submodule.my_function

which will be loaded something like:

    from my_module.my_submodule import my_function

pseudo-formally here's the grammar for these identifiers:

    identifier ::= path_esque '.' function_name

    path_esque ::= path_part ( '.' path_part )*

    path_part ::= /^[a-z][a-z0-9_]*$/

    function_name ::= /^[a-zA-Z][a-zA-Z0-9_]*$/
"""


from sakin_agac import (
        cover_me,
        )
from importlib import import_module
import re
import sys


def function_via_function_identifier(identifier, listener):

    md = _rx.search(identifier)
    if md is None:
        cover_me('no: %s' % identifier)

    path_esque, function_name = md.groups()

    mod = import_module(path_esque)  # #cover-me - when no module

    return getattr(mod, function_name)  # #cover-me - when no such attr


_word = '[a-z][a-z0-9_]*'
_rx = re.compile(r'^(%s(?:\.%s)*)\.([a-zA-Z][a-zA-Z0-9_]*)$' % (_word, _word))


sys.modules[__name__] = function_via_function_identifier

# #born.
