from os.path import splitext as _splitext


def via_path(path, use_environ, listener):
    from os.path import  sep
    base, ext = _splitext(path)
    assert '.py' == ext
    mname = base.replace(sep, '.')
    from importlib import import_module
    config_mod = import_module(mname)
    cdef = tuple(config_mod.generation_service_config(use_environ, listener))
    if 0 == len(cdef):
        return
    return generation_config_via_definition(cdef, filesystem=None)


def generation_config_via_definition(config_defn, filesystem=None):

    _ = _components_via(config_defn, filesystem=filesystem)
    comps = {k: v for k, v in _}

    from modality_agnostic.magnetics.resolve_forward_references import \
        plan_via_dependency_graph as func

    plan = func(comps.items())
    assert len(comps) == len(plan)

    resolved = {}

    for typ, k in plan:
        if 'no_dependencies' == typ:
            use = None
        else:
            assert 'resolve' == typ
            use = resolved
        resolved[k] = comps[k].finish_via_resolved_forward_references(use)

    final = {k: resolved[k] for k in comps.keys()}
    return _Config(final)


func = generation_config_via_definition


class _Config:

    def __init__(self, comps):
        self._components = comps  # #testpoint

    def EXECUTE_COMMAND(self, cmd, listener, stylesheet=None):
        from pho.config_component_ import execute_command_ as func
        return func(self, cmd, listener, stylesheet)

    def to_additional_commands_(self):
        yield 'FILESYSTEM_CHANGED', lambda kw: self._FS_changed_command(**kw)

    def _FS_changed_command(self, command_name, rest, listener, stylesheet):
        # For convenience of development (and for now) we allow this to be
        # invoked using our super-dense command notation
        #
        # This notation was created primarily to reach simple commands on
        # deeply-nested config components from the command line without
        # needing to write extra CLI code for every command
        #
        # This novelty justified itself as a feature for simple cases (like
        # querying the status of a directory in the config)
        #
        # But as we're about to find out, for cases requiring multiple
        # parameters or arbitrary string parameters, the novelty breaks down.
        # It seems unlikely we will want to push this up. Rather, this is
        # probably going to serve as proof-of-smell:
        #
        # Our super-dense notation for parameters that is a smell:
        #
        #     foo(aa, bb cc)     =>     foo("aa", "bb cc")
        #
        # That is, the values cannot contain commas, parens or quotes. They
        # can contain spaces but only internally, not at outer boundaries.

        argrxs = '[^ \'",](?:[^\'",]*[^ \'",])?'
        rsx = f'^(?:{argrxs}(?:[ ]*,[ ]*{argrxs})*)?\\Z'
        import re
        if not re.match(rsx, rest):
            xx(f"failed to parse parameter(s): {rest!r}")

        args = re.split('[ ]*,[ ]*', rest)
        from pho.cli import parse_positionals_ as func
        if (itr := func(args, ('CHANGE_TYPE', 'PATH'), 'FILESYSTEM_CHANGED')):
            rc = next(itr)
            listener('error', 'expression', 'dun_dun', lambda: itr)  # ..
            return rc

        return self.FILESYSTEM_CHANGED(*args, listener)

    def FILESYSTEM_CHANGED(self, change_type, path, listener):
        # One of the more NOT clear-cut decisions is deciding where the
        # boundary should be on the pipeline between here and SSG adapter:
        # What work should we be responsible for doing vs that of the adapter?
        # Assume this boundary will be in flux at first

        rc, filesystem_change_event = _filesystem_change_event_via(
            change_type, path, listener)
        if filesystem_change_event is None:
            return rc

        # #todo the whole point of daemonizing a server was that we could
        # in-memory cache some kind of state worth holding on to during a
        # typical use case "edit session". Doing this below complicated lookup
        # on every file save is kind of nasty to do at run time except that
        # in practice so far, the target thing is the first hit

        needle_method_name = 'RECEIVE_FILESYSTEM_CHANGED'
        use_comp = None
        for comp in self._components.values():
            if hasattr(comp, needle_method_name):
                use_comp = comp
                break
        func = getattr(use_comp, needle_method_name)
        return func(filesystem_change_event, listener)

    def get_component_(self, k):
        return self._components.get(k)

    def to_component_keys_(self):
        return self._components.keys()

    def to_component_keys_and_values_(self):
        return self._components.items()

    has_components_ = True

    label_for_show_ = 'config for generation'


def _filesystem_change_event_via(change_type, path, listener):

    if change_type not in ('file_created', 'file_saved'):
        def lines():
            yield f"Ignoring this change type for now: {change_type!r}"
        listener('info', 'expression', 'ignoring_change_type', lines)
        return 0, None

    # discussed in [#409.3], somewhere in the stack there's either a vendor
    # or an OS weirdness where the above two get conflated sometimes, so this
    # is the point at which we munge them into one type.

    # (there are certainly other change types we could act on, like delete,
    # but those comprise a tiny fraction of our real-life use case FS events)

    _, ext = _splitext(path)
    if '.md' == ext:
        return None, _DocumentCreatedOrSaved(path)

    if '.eno' == ext:
        return None, _NotecardCreatedOrSaved(path)

    def lines():
        yield f"expected '.md' or '.eno' had {ext!r}"
    listener('error', 'expression', 'unexpected_file_extension', lines)
    return 123, None


_same_change_type = 'file_created_or_saved'


class _NotecardCreatedOrSaved:

    def __init__(self, path):
        self.path = path

    def TO_ABSTRACT_DOCUMENT(self, listener):
        xx("rough sketch. never been run")  # #todo
        from pho.notecards_.abstract_document_via_file_with_changes \
            import func
        return func(self.path, listener)

    change_type = _same_change_type


class _DocumentCreatedOrSaved:

    def __init__(self, path):
        self.path = path

    def TO_ABSTRACT_DOCUMENT(self, listener):
        from pho.magnetics_.abstract_document_via_native_markdown_lines \
            import func
        with open(self.path) as lines:
            return func(lines, path=self.path)

    change_type = _same_change_type


def _components_via(config_defn, filesystem=None):  # might push up later

    direcs = iter(config_defn)
    del config_defn

    for direc in direcs:
        leng = len(direc)
        if 2 == leng:
            component_name, ctype = direc
            defnf = next(direcs)
        else:
            component_name, ctype, defnf = direc  # eek experimental

        comper = _func_via_ctype[ctype]
        comp = comper(defnf, filesystem=filesystem)
        yield component_name, comp


def _ctype(ctype):
    def decorator(orig_f):
        _func_via_ctype[ctype] = orig_f
        return orig_f
    return decorator


_func_via_ctype = {}


@_ctype('SSG_controller')
def _(defnf, filesystem=None):
    itr = defnf()
    ada = _first_line_of_defn_should_be_adapter_name(itr)
    return ada.SSG_controller_via_defn(itr)


# == Config component type: Intermediate directory

@_ctype('SSG_intermediate_directory')
def _(defnf, filesystem=None):
    itr = defnf()
    ada = _first_line_of_defn_should_be_adapter_name(itr)
    return ada.intermediate_directory_via_defn(itr, filesystem=filesystem)


def _first_line_of_defn_should_be_adapter_name(itr):
    direc = next(itr)
    ctype = direc[0]
    if 'SSG_adapter' != ctype:
        xx(f"{ctype!r}")
    adapter_name, = direc[1:]
    return _SSG_adapter_module_via_name(adapter_name)


def _SSG_adapter_module_via_name(adapter_name):
    import re
    assert re.match('[a-z_]+$', adapter_name)
    if 'peloogan' == adapter_name:  # for now make this name easily searchable
        adapter_name = 'pelican'

    mname = f"pho.SSG_adapters_.{adapter_name}"
    from importlib import import_module as func
    return func(mname)


# == Config component type: filesystem path

@_ctype('filesystem_path')
def _(x, filesystem=None):
    from pho.config_component_ import filesystem_path_ as func
    return func(x)


# == Support

def _whine(listener, reason):
    listener('error', 'expression', 'error', lambda: (reason,))


def xx(msg=None):
    raise RuntimeError(''.join(('ohai', *((': ', msg) if msg else ()))))


""" Appendix :#here1:

The idea was that we build configs from arbitrary adapters with complete
autonomy. SO logic up at this level shouldn't be using these names, it
should be using some kind of index it makes of what types of adapters are
at the top level.. #todo
"""

# #born
