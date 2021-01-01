def via_path(path, use_environ):
    from os.path import splitext, sep
    base, ext = splitext(path)
    assert '.py' == ext
    mname = base.replace(sep, '.')
    from importlib import import_module
    config_mod = import_module(mname)
    config = config_mod.generation_service_config(use_environ)
    return func(config)


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

    def get_component_(self, k):
        return self._components.get(k)

    def to_component_keys_(self):
        return self._components.keys()

    def to_component_keys_and_values_(self):
        return self._components.items()

    has_components_ = True

    label_for_show_ = 'config for generation'


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

# #born
