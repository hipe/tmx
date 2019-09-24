"""
This #anemic module has only a function for loading a function from a string

(In fact this function could be used to load any public value in module.)

Given "function identifier" (string) that looks like this:

    my_module.my_submodule.my_function

…the function attempts to load the function suggested by it
in a manner equivalent to this:

    from my_module.my_submodule import my_function

Here's a pseudo-grammar suggesting the syntax for these identifiers
(but code and unit tests are the authoritative reference):

    identifier ::= path_esque '.' function_name

    path_esque ::= path_part ( '.' path_part )*

    path_part ::= /^[a-z][a-z0-9_]*$/

    function_name ::= /^[a-zA-Z][a-zA-Z0-9_]*$/

.#history-A.2 sunsets a long thought experiment that conceived of
"sync keysers" (which ultimately obviated this module). Furthermore it
foreshadows the "no more sync-side item mapping".
"""


from importlib import import_module
import re
import sys


def function_via_function_identifier(identifier, listener):
    # (Case0160DP)

    md = _rx.search(identifier)  # ..

    path_esque, function_name = md.groups()

    mod = import_module(path_esque)  # #cover-me - when no module

    return getattr(mod, function_name)  # #cover-me - when no such attr


_word = '[a-zA-Z][a-zA-Z0-9_]*'  # was all lowercase until #history-A.1
_rx = re.compile(r'^(%s(?:\.%s)*)\.([a-zA-Z][a-zA-Z0-9_]*)$' % (_word, _word))


sys.modules[__name__] = function_via_function_identifier

# #history-A.2
# #history-A.1
# #born.
