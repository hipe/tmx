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

# == BEGIN [#008.12] function reflection
#    At #history-A.3 this became stowaway here & sunsetted anemic other file.
#    There are lots of holes here that would be straightforward to fill,
#    but we haven't done so because we don't use this system in production.
#    At #history-B.4 we begin using it again.


class parameter_index_via_mixed:

    def __init__(self, function_or_method, do_crazy_hack=False):

        if do_crazy_hack:
            self.desc_lines, pool = _crazy_hack(function_or_method.__doc__)

        starts_with_underscore, does_not_start_with_underscore = [], []

        fparam_args_via = _formal_parameter_argumentser()

        from inspect import signature
        _items = signature(function_or_method).parameters.items()
        for name, param in _items:

            if '_' == name[0]:
                starts_with_underscore.append(name)
                continue

            kw = {k: v for k, v in fparam_args_via(param)}

            if do_crazy_hack:
                desc_lines = pool.pop(name, None)
                if desc_lines:
                    kw['description'] = desc_lines

            fparam = _FormalParameter(**kw)
            does_not_start_with_underscore.append((name, fparam))

        if do_crazy_hack and pool:
            xx(f"oops, in docstring but not in params: {tuple(pool.keys())!r}")

        self.parameters_that_start_with_underscores = tuple(starts_with_underscore)  # noqa: E501
        self.parameters_that_do_not_start_with_underscores = tuple(does_not_start_with_underscore)  # noqa: E501


def _crazy_hack(doc):  # #testpoint
    itr = _do_crazy_hack(doc)
    these_lines = next(itr)
    pool = {k: v for k, v in itr}
    return these_lines, pool


def _do_crazy_hack(doc):
    from text_lib.magnetics.scanner_via import scanner_via_iterator as func
    scn = func(normal_lines_via_docstring(doc))

    # Cache up lines that don't look like this one line
    these_lines = []
    while 'Args:\n' != scn.peek:  # (doing it dirty for now
        these_lines.append(scn.next())
    scn.advance()

    yield tuple(these_lines)

    # Parse every item of the Args section
    import re
    da = re.DOTALL
    rx_one = re.compile('^[ ]{4}([a-zA-Z][a-zA-Z_0-9]*):[ ]+([^ ].*)', da)
    rx_two = re.compile('^[ ]{5}[ ]*(?P<rest>[^ ].*)', da)

    md = rx_one.match(scn.peek)
    if not md:
        xx(f"Item line? {scn.peek!r}")
    scn.advance()

    # Parse each arg while dealing with its any multiple descrciption lines
    while True:
        param_identifier, desc_line_1 = md.groups()
        desc_lines = [desc_line_1]
        while scn.more and (md := rx_two.match(scn.peek)):
            desc_lines.append(md['rest'])
            scn.advance()
        yield param_identifier, tuple(desc_lines)
        if scn.empty:
            break
        if (md := rx_one.match(scn.peek)):
            scn.advance()
            continue
        break

    while scn.more and '\n' == scn.peek:
        scn.advance()

    if scn.more:
        xx(f"never thought about this. is it result? {scn.peek!r}")


def normal_lines_via_docstring(doc):
    import re
    raw_lines = (md[0] for md in re.finditer(r'[^\n]*\n', doc))  # #[#610]

    exactly_four_lines_of_indent_rx = re.compile('^[ ]{4}(.+)', re.DOTALL)

    yield next(raw_lines)  # Following google convention, assume `"""Foo ..`
    for line in raw_lines:
        if '\n' == line:
            yield line
            continue
        # For now we're gonna assume etc
        md = exactly_four_lines_of_indent_rx.match(line)
        assert md
        yield md[1]


def _formal_parameter_argumentser():
    from inspect import Parameter as o
    POSITIONAL_OR_KEYWORD = o.POSITIONAL_OR_KEYWORD
    KEYWORD_ONLY, POSITIONAL_ONLY = o.KEYWORD_ONLY, o.POSITIONAL_ONLY
    VAR_KEYWORD, VAR_POSITIONAL = o.VAR_KEYWORD, o.VAR_POSITIONAL
    from inspect import _empty as empty  # there has to be a better way

    def via(param):
        kind, default, annot = param.kind, param.default, param.annotation

        if POSITIONAL_OR_KEYWORD == kind:
            if empty == default:
                yield 'argument_arity', arities.REQUIRED_FIELD
                return

            if empty == annot:
                yield 'argument_arity', arities.OPTIONAL_FIELD
                yield 'default_value', default
                return

            if bool == annot:
                assert default is False  # ..
                yield 'argument_arity', arities.FLAG
                yield 'default_value', default
                return
            xx()

        if KEYWORD_ONLY == kind:
            xx()

        if POSITIONAL_ONLY == kind:
            xx()

        if VAR_KEYWORD == kind:
            xx()

        assert VAR_POSITIONAL == kind
        xx()

    return via


# == END


class _FormalParameter:

    def __init__(
            self,
            description=None,
            default_value=None,
            argument_arity=None,
    ):
        if argument_arity is None:
            argument_arity = arities.REQUIRED_FIELD
        elif isinstance(argument_arity, str):
            # #NOT_COVERED #history-A.2
            argument_arity = getattr(arities, argument_arity)

        self.argument_arity_range = argument_arity

        self.description = description
        self.default_value = default_value

    @property
    def is_flag(self):  # this is a CLI term, just shorthand here
        rang = self.argument_arity_range
        return 0 == rang.start and 0 == rang.stop

    @property
    def is_required(self):
        return (False, True)[self.argument_arity_range.start]


define = _FormalParameter


def lazy_property(orig_f):  # #[#510.6] custom memoizy decorator
    def use_f(self):
        if not hasattr(self, attr):
            setattr(self, attr, orig_f(self))
        return getattr(self, attr)
    attr = ''.join(('_', orig_f.__name__))
    return property(use_f)


class _CommonArityKinds:
    """(per the list in [#502])"""

    @lazy_property
    def REQUIRED_LIST(self):
        """(category 5)"""
        return _MyArity(1, None)

    @lazy_property
    def REQUIRED_FIELD(self):
        """(category 4)"""
        return range(1, 1)

    @lazy_property
    def OPTIONAL_LIST(self):
        """(category 3)"""
        return _MyArity(0, None)

    @lazy_property
    def OPTIONAL_FIELD(self):
        """(category 2)"""
        return range(0, 1)

    @lazy_property
    def FLAG(self):
        """(category 1)"""
        return range(0, 0)


arities = _CommonArityKinds()


class _MyArity:
    """(so that we can use None to signify unbound ranges)"""

    def __init__(self, start, stop):
        self.start = start
        self.stop = stop


def xx(msg=None):
    raise RuntimeError(''.join(('ohai', *((': ', msg) if msg else ()))))

# #history-B.4
# #history-A.3
# #history-A.2: (can be temporary) for not covered
# #history-A.1: large doc spike of parameter modeling theory
# #born.
