def cli_for_production():
    def enver():
        from os import environ
        return environ
    import sys as o
    exit(_CLI(o.stdin, o.stdout, o.stderr, o.argv, enver))


def _CLI(sin, sout, serr, argv, enver):
    def line_contents():
        yield 'experiments in generating documents from "notecards"'
    from script_lib.cheap_arg_parse_branch import cheap_arg_parse_branch
    return cheap_arg_parse_branch(
            sin, sout, serr, argv, _big_flex(), line_contents, enver)


def _lazy(build):  # [#510.8] yet another take on "lazy"
    class Lazy:
        def __init__(self):
            self._is_first = True

        def __call__(self):
            if self._is_first:
                self._is_first = False
                self._value = build()
            return self._value
    return Lazy()


def _build_memoized_thing():

    coll_path_env_var_name = 'PHO_COLLECTION_PATH'

    class Fellow:

        @property
        def descs(_):
            yield 'The path to the directory with the notecards '
            yield '(the directory that contains the `entities` directory)'
            yield f'(or set the env var {coll_path_env_var_name})'

        def require_collection_path(_, enver, listener):
            collection_path = enver().get(coll_path_env_var_name)
            if collection_path is not None:
                return collection_path
            whine_about(listener)

    def whine_about(listener):
        listener('error', 'structure', 'parameter_is_currently_required',
                 lambda: {'reason_tail': '--collection-path'})

    return Fellow()


CP_ = _lazy(_build_memoized_thing)


def _big_flex():

    these = ('cli', 'commands')

    from os import path as o
    _pho_project_dir = o.abspath(o.join(__file__, '..', '..'))
    _commands_dir = o.join(_pho_project_dir, *these)

    mod_head = '.'.join(('pho', *these))
    from importlib import import_module

    def build_loader(mod_tail):
        def load_CLI_function():
            _mod_name = '.'.join((mod_head, mod_tail))
            _mod = import_module(_mod_name)
            return _mod.CLI

        return load_CLI_function

    from os import listdir
    for fn in listdir(_commands_dir):
        if not fn.endswith('.py'):
            continue
        if fn.startswith('_'):
            continue
        module_tail = fn[0:-3]
        _slug = module_tail.replace('_', '-')
        yield _slug, build_loader(module_tail)


# #history-A.1 rewrite during cheap arg parse not click
# #born.
