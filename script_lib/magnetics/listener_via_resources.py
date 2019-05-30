raise Exception('never loaded - is stowaway in __init__.py')

"""(placeholder for the deeper idea)

the idea here is that commands can emit "expressions" (and maybe one
day "events", known together with expressions as as "emissions") in a
modality-agnostic way and a listener can express them in a modality-
appropriate way.

you emit your expression by telling it a 'channel' in terms of
several strings:

    self._listener('info', 'expression', f)

Here, the "channel" is the tuple `('info', 'expression')`.

(We will offer what `f` is below.)

The channel component where `'info'` is is typically one of
`{'info' | 'error'}` but if you were willing to make clients for it, you
could support any allowable set of values you wanted, for example:

    {'trace' | 'debug' | 'verbose' | 'info' | 'notice' | 'waring' | 'error' }

etc.

(We don't have a formal name for this emission channel component yet.
Maybe we'll call it something like "severity" or "mood".)

The second component is what we call the "shape" of the emission. In this
case it is `'expression'`.

At the moment (#history-A.1) we are trending away from using this shape
in favor of using `'structure'`. But for posterity we'll cover it:

The `'expression'` shape is for something like writing lines to for
example STDOUT or STDERR on a terminal (but we imagine it might be writing
HTML instead, or any other arbitrary unknown "modality substrate").

`f` will be passed:

  - a "styler"

and is expected to yield one or more *strings* styled with the styler.

so the function might look like:
    def f(styler):
        yield f"hello {styler.em('world')}!"
        yield "see you later!"

As for the first component of the channel,
this convoluted interface (HIGHLY EXERIMENTAL) allows the listener to
decide whether it wants the command to bother executing the emission
just based on seeing the channel alone. also it allows the listener
(modality client) to inject a modality-appropriate styler.

we want the interface to improve while not losing the above provisions.


.## more commonly..

..nowadays we do more like

    def payloader():
        return {
            'reason': 'aa',
            'lineno': 23,
            'line': 'xx',
        }

    self._listener('info', 'structure', payloader)

This gives the client a "stucture" (just a dictionary) which is usually
more useful for the client (and also easier to test).
"""

# #history-A.1: introduce the 'structure' shape
# #abstracted.
