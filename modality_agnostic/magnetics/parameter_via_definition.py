"""let's think about parameter modeling theory

as something of an overly reductive mnemonic, our modeling of
parameters can employ a two-component tuple (a couple) of integer-ishes:

we can model any formal parameter (in part) in terms of its
*minimum* and *maximum* number of allowable arguments, a concept we
hereafter refer to as "argument arity" (or sometimes just "arity").

under this model, these are something of required fields *for* modeling
parameters. (that is, they are required meta-parameters.)

what we mean by this is simply that for every formal parameter, the designer
must express (either tacitly or implicitly) a *minimum* and *maxium* *number*
of allowable arguments for the parameter.

if there's a central thesis to this module, it's that there exist 5
or so interesting sets that we can model in this notation, each of which
manifests as different kinds of interface element across the different
modalities in consistent ways.

let's consider different categories of formal parameters in terms of
what is their minimum and maxium sensical/allowable numbers of arguments:

    min  max     description

      0    0     a "flag" in CLI, a checkbox or radio button in GUI [1]
      0    1     optional field. in CLI, option that requires an argument [2]
      0    ∞     a list that can be as short as 0 (an optional list)
      1    1     required field. (usu.) a positional argument in CLI
      1    ∞     like (0, ∞) but at least one item is required [5]

briefly let's consider terms we've introduced: a "flag" is something that is
significant by its presence alone; it does not "take" a argument. a "field",
on the other hand, does. a "list" takes a plural number of arguments (i.e
possibly 2 or more).

note that our notation employs the three values 0, 1, and ∞ for the two
components in the range. this makes for a hypothetical (3x3) nine possible
permuations of these values. here we'll consider permuatations that we've
omitted above, (but you can probably skip this):

    min  max     description

      1    0     as a stretch, consider certain command-line utilities that
                 require you to provide a `--force` flag because what they
                 do is especially destructive. in this notation we might
                 model such a parameter in this way; but keep in mind to do
                 so would be misleading b.c we are overloading the meaning
                 of `min` to mean not "how many arguments" but "whether or
                 not required." this is enough of an edge case we give it
                 no further formal treatment.

      ∞    *     infinity in the maxium column is a useful shorthand to
                 represent "a range with no upper bounds". because the lowest
                 possible count integer is 0, saying "no lower bounds" is
                 equivalent to say "a lower bounds of zero". it would not be
                 meaningful to express a range with a minium of infinity -
                 no count integer satisfies this would-be requirement. [7]


## other modeling systems

it bears mentioning that this is not the only modeling system possible
to achieve the same effect. the lexicon we offer below "isomorphs" with our
number-based tuple system:

    - `is_required`        T/F indicating whether it's a required parameter
    - `is_flag`|`is_list`  mutually exclusive (F,F), (F,T), or (T,F)

let's echo our main table using this lexicon:

        -    flag     our category 1 above
        -     -       our category 2 above
        -    list     our category 3 above
    required flag     our nonsensical category 6 above
    required  -       our category 4 above
    required list     our category 5 above

we said this is "isomorphic" with the other system. by that we mean that
you could use either system for "deep representation" and the other system
in surface representation. you can get from one to the other losslessly.

somewhat arbitrarily we have decided to go with a number-based system
(perhaps out of an assumed familiarity platform developers with have
with python's `range` construct and the close kinship argument arity has
there).


## footnotes

1: to get a radio button as opposed to checkbox, we would want to use the
`argparse` concept of "groups"; however note too that such a surface
representation also isomorphs with an "enum" type. this whole topic is
interesting, but one we'll avoid here.

2: the "optional field" in CLI can also manifest as an optional positional
argument, under certain circumstances which we'll cover there.

5: one could see the `diff` command as taking a list of exactly 2 filenames
(so (2, 2)) but we prefer to model an operation like that as two required
fields.

7: if you wanted to be awful you could use ∞ as a minimum component too
mean "this represents a blacklisted parameter" (or even an unrecognized
parameter); but don't do that.

:[#502]
"""

from modality_agnostic.memoization import (
        dangerous_memoize,
        )


class _SELF:

    def __init__(
            self,
            description=None,
            default_value=None,
            argument_arity=None,
    ):
        if argument_arity is None:
            argument_arity = _arities.REQUIRED_FIELD
        elif type(argument_arity) is str:
            # #NOT_COVERED #history-A.2
            argument_arity = getattr(_arities, argument_arity)

        self.argument_arity_range = argument_arity

        self.description = description
        self.default_value = default_value

    @property
    def generic_universal_type(self):  # contact-point for the idea #todo
        pass


class _CommonArityKinds:
    """(per the list in [#502])"""

    @property
    @dangerous_memoize
    def REQUIRED_LIST(self):
        """(category 5)"""
        return _MyArity(1, None)

    @property
    @dangerous_memoize
    def REQUIRED_FIELD(self):
        """(category 4)"""
        return range(1, 1)

    @property
    @dangerous_memoize
    def OPTIONAL_LIST(self):
        """(category 3)"""
        return _MyArity(0, None)

    @property
    @dangerous_memoize
    def OPTIONAL_FIELD(self):
        """(category 2)"""
        return range(0, 1)

    @property
    @dangerous_memoize
    def FLAG(self):
        """(category 1)"""
        return range(0, 0)


_arities = _CommonArityKinds()


class _MyArity:
    """(so that we can use None to signify unbound ranges)"""

    def __init__(self, start, stop):
        self.start = start
        self.stop = stop


_SELF.arities = _arities
import sys  # noqa E402
sys.modules[__name__] = _SELF  # #[#008.G] so module is callable

# #history-A.2: (can be temporary) for not covered
# #history-A.1: large doc spike of parameter modeling theory
# #born.
