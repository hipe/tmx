def _CLI(sin, sout, serr, argv):
    """tooling for recfiles adaptation development"""

    def usage_lines():
        yield "usage: {{prog_name}} ad-hoc-function [-model MODULE] [-recfile FILE] FENT_NAME FUNC_NAME\n"
        yield "usage: {{prog_name}} model [-model MODULE] [-recfile FILE] [FENT_NAME]\n"
        yield "usage: {{prog_name}} save -model MODEL_MODULE -recfile RECFILE\n"

    usage_lines = tuple(usage_lines())

    def docstring_for_help(invo):
        for line in invo.description_lines_via_docstring(_CLI.__doc__):
            yield line

        # massive hack
        import re
        for usage_line in usage_lines:
            k = re.match(r'^usage: \{\{prog_name\}\} ([-a-z_]+) ', usage_line)[1]
            s = _subcommands[k].__doc__
            itr = invo.description_lines_via_docstring(s)
            assert '\n' == next(itr)
            yield '\n'
            yield '\n'
            yield f'# Subcommand {k!r}:\n'
            for line in itr:
                yield line
        yield '\n'
        yield "Option:\n"
        yield "  -x    pretend option\n"

    from script_lib.via_usage_line import build_invocation
    invo = build_invocation(
            sin, sout, serr, argv, usage_lines=usage_lines,
            docstring_for_help_description=docstring_for_help)
    rc, pt = invo.returncode_or_parse_tree()
    if rc is not None:
        return rc

    subcommand_name, = pt.subcommands
    try:
        return _subcommands[subcommand_name](sin, sout, serr, **pt.values)
    except _Stop as stop:
        return stop.returncode


def subcommand(subcommand_name):
    def decorator(func):
        _subcommands[subcommand_name] = func
    return decorator


_subcommands = {}


@subcommand('ad-hoc-function')
def _(sin, sout, serr, fent_name, func_name, model=None, recfile=None):
    """experimental"""

    listener = _listener_via_outstream(serr)
    model, recfile = _resolve((
        ('-model', model, 'required'),
        ('-recfile', recfile, 'required')), listener)
    colz = _collectioner_via(model, recfile, listener)
    coll = colz[fent_name]  # raises KeyError
    func = getattr(coll.dataclass, func_name)
    res = func()  # used to pass listener before #history-C.1
    w = sout.write

    if not hasattr(res, '__next__'):  # meh w/e, modify as needed
        if hasattr(res, '__getitem__'):
            w(repr(res))
        else:
            w(type(res))
        w('\n')
        return 3

    first = next(res, None)
    if first is None:
        serr.write('(none.)\n')
        return 0
    curr = first
    def lines_via_entity(ent):
        for func in baked:
            for line in func(ent):
                yield line
    def bake(k):
        def func(ent):
            rhs = val_func(getattr(ent, k))
            yield f"{k}: {rhs}\n"

        def val_func(x):
            if x is None:
                return '(none.)'
            if isinstance(x, str):
                return x
            return repr(x)

        return func

    baked = tuple(bake(k) for k in first.__class__.__dataclass_fields__.keys())
    count = 1
    while True:
        if 1 < count:
            w('\n')
        for line in lines_via_entity(curr):
            w(line)
        curr = next(res, None)
        if not curr:
            break
        count += 1
    serr.write(f"({count} total)\n")
    return 0


@subcommand('model')
def _(sin, sout, serr, model=None, recfile=None, fent_name=None):
    """Various reflections on the datamodel:

    With no FENT_NAME (formal entity name), just list the dataclasses
    defined in the datamodel module.

    With formal entity name and no -recfile, output the abstract schema
    (as a s-expression) derived only from the dataclass.

    If a -recfile was passed, output the abstract schema as hybridized
    from the two sources
    """

    listener = _listener_via_outstream(serr)

    model, recfile = _resolve((
        ('-model', model, 'required'),
        ('-recfile', recfile, 'optional')), listener)

    colz = _collectioner_via(model, recfile, listener)

    if not fent_name:
        return _list_model_class_names(sout, serr, colz)

    coll = colz[fent_name]  # raises KeyError

    if recfile:
        fe = coll.EXPERIMENTAL_HYBRIDIZED_FORMAL_ENTITY_(listener)
    else:
        fe = coll.abstract_entity_derived_from_dataclass

    if not fe:
        return listener.returncode or 124

    w = sout.write
    for line in fe.to_sexp_lines():
        w(line)
    return 0


def _list_model_class_names(sout, serr, colz):
    serr.write("# Model classes:\n")
    count = 0
    for fent_name in colz.model_class_names():
        count += 1
        sout.write(f"{fent_name}\n")
    if 0 == count:
        serr.write("# (none)\n")
    else:
        serr.write(f"# ({count} total)\n")
    return 0


@subcommand('save')
def _(sin, sout, serr, model_module, recfile):
    """Redirect this output to a file called 'tmp.recfile-tooling.rec'.

    It will be used on subsequent invocations to "fill in the blanks"
    of parameters not provided.

    (This is provided as a convenience so we can avoid re-typing
    (or re-copy-pasting) these oft-repeated parameters. Convenient
    also to avoid the "visual cruft" of them.)
    """

    for line in _lines_for_save(model_module, recfile):
        sout.write(line)

    return 0


def _lines_for_save(model_module, recfile):

    import re
    if not re.match(r'^[a-zA-Z0-9_\.]+$', model_module):
        xx()

    if not re.match(r'^[-a-zA-Z0-9\._/]+$', recfile):
        xx()

    yield f"# this file was generated by the 'save' command of {__file__}\n"
    yield '\n'
    yield f'ModelModule: {model_module}\n'
    yield f'MainRecfile: {recfile}\n'


def _collectioner_via(model, recfile, listener):

    from importlib import import_module as func
    mod = func(model)  # ..
    func = mod.collections_via_recfile_

    if not recfile:
        def lines():
            yield "notice: gonna see what happens with no recfile.."
        listener('info', 'expression', 'defaulter_hmm', lines)

    return func(recfile)


def _resolve(terms, listener):
    def defaulterer():
        memo = defaulterer
        if memo.value is None:
            memo.value = _build_defaulter(listener)
        return memo.value
    defaulterer.value = None
    return (_resolve_term(*rec, defaulterer, listener) for rec in terms)


def _resolve_term(switch, passed_value, optional_or_required, defaulterer, listener):

    if passed_value is not None:
        if 0 == len(passed_value):
            # Allow that by passing the empty string as a value on the command
            # line, # it overrides any value in the any config file.
            # (The command line parser hasn't covered this yet but one day)
            return None
        return passed_value

    defaulter = defaulterer()
    res = getattr(defaulter, optional_or_required)(switch)

    if defaulter.did_fail:
        raise _Stop(defaulter.returncode)

    if res is not None:
        def lines():
            yield f"(using {switch} {res!r} from {defaulter.path})"
        listener('info', 'expression', 'defaulter_employed', lines)

    return res


class _build_defaulter:

    def __init__(self, listener):
        self.did_fail = False
        self.returncode = 0
        self._cached_parsed_file = None
        self._listener = listener

    def required(self, term):
        if not (pf := self._parsed_file):
            return self._fail(f"{term!r} required (no {self.path})\n")
        lhs = _defaulter_thing_via_thing[term]
        if (v := pf.get(lhs)) is None:
            self._fail(f"No {term!r} and no {lhs!r} in {self.path}\n")
            return self._fail("One is required.\n")
        return v

    def optional(self, term):
        if not (pf := self._parsed_file):
            return
        return pf.get(_defaulter_thing_via_thing[term])

    def _fail(self, reason):
        self._listener('error', 'expression', 'defaulting_error', lambda: (reason,))
        self.returncode = 125

    @property
    def _parsed_file(self):
        if self._cached_parsed_file is None:
            self._cached_parsed_file = _parse_saved_file(self.path, self._listener)
        return self._cached_parsed_file

    path = 'tmp.recfile-tooling.rec'


_defaulter_thing_via_thing = {
    '-model': 'ModelModule',
    '-recfile': 'MainRecfile',
}


def _parse_saved_file(recfile, listener):

    from kiss_rdb.storage_adapters_.rec \
        import native_records_via_recsel_ as func

    these = tuple(func(recfile, (), listener))
    dct, = these  # ..

    def denativize(lines, lhs):
        line, = lines  # ..
        assert '\n' == line[-1]
        return line[0:-1]

    return {k: denativize(v, k) for k, v in dct.items()}


def _listener_via_outstream(serr):
    def listener(*emi):
        assert 'expression' == emi[1]
        if 'error' == emi[0]:
            listener.returncode = 123
        for line in emi[-1]():
            serr.write(line)
            if not (len(line) and line[-1] == '\n'):
                serr.write('\n')
    listener.returncode = 0
    return listener


class _Stop(RuntimeError):
    def __init__(self, returncode):
        self.returncode = returncode


if True:  # ..
    from sys import stdin, stdout, stderr, argv
    exit(_CLI(stdin, stdout, stderr, argv))

# #history-C.1
# #born
