raise Exception('never loaded - is stowaway in __init__.py')

"""(placeholder for the deeper idea)

the idea here is that commands can emit "expressions" (and maybe one
day "events", known together with expressions as as "emissions") in a
modality-agnostic way and a listener can express them in a modality-
appropriate way.

you emit your expression by telling it a 'channel' in terms of
several strings:

    self._listener('info', 'expression', f)

(currently, the above pictured channel ('info', 'expression') is the
only channel supported.)

the function that is passed as the last argument (above `f`) is a
callback that will receive two things:

  - a function to receive strings
  - a "styler"

so the function might look like:
    def f(o, styler):
        o('hello ' + o.em('world') + '!')

this convoluted interface (HIGHLY EXERIMENTAL) allows the listener to
decide whether it wants the command to bother executing the emission
just based on seeing the channel alone. also it allows the listener
(modality client) to inject a modality-appropriate styler.

we want the interface to improve while not losing the above provisions.
"""

# #abstracted.
