def _state_machine():
    # NOTE in this module, state is only ever derived from actual FS state;
    # we don't ever actually traverse these transitions *in* our FSA.
    # So the right hand side node names below are only didactic.

    yield 'noent', 'create_directory', 'empty_directory', 'call', '_create_directory'  # noqa: E501
    yield 'empty_directory', 'ls', 'empty_directory', 'call', '_list_directory'
    yield 'non_empty_directory', 'ls', 'non_empty_directory', 'call', '_list_directory'  # noqa: E501


class directory_via_path:
    """Imagine that it's itself stateless, just a wrapper around the

    filesystem whose state determines its state, and also it exposes functions
    to mutate the filesystem and (in effect) move us through our states.

    (In practice we are seeing if we can avoid redudant filesystem hits while
    avoiding the pitfalls of caching:..)
    """

    def __init__(self, path, injected_functions=None, filesystem=None):
        self.path = path
        self.injected_functions = injected_functions
        self._injected_filesystem = filesystem
        self._d = None

    # == Hook-in to component API

    def EXECUTE_COMMAND(self, cmd, listener, stylesheet=None):
        from pho.config_component_ import execute_command_ as func
        with self._open_cache_session():
            # (traverse the iteration while within the cache)
            for line in func(self, cmd, listener, stylesheet):
                yield line

    def to_additional_commands_(self):
        for k in self._state.transition_names:
            yield k, lambda kw: self._execute_action(**kw)

    def _execute_action(self, command_name, rest, stylesheet, listener):
        tr = self._state[command_name]
        args = () if rest is None else (rest,)  # idk
        func = getattr(self, tr.action_function_name)
        return func(listener, *args)

    # == Mutates filesystem

    def _create_directory(self, listener):
        self._clear_cache_early()
        pretend = ''.join(('mkdir ', self.path, '\n'))
        yield pretend
        self._filesystem.mkdir(self.path)  # result is none

    # == Read-only and derivations

    def _list_directory(self, listener):
        tup = self._cached('listdir_tuple')
        if not len(tup):
            msg = f'(empty directory: {self.path})'
            listener('info', 'expression', 'dir_is_empty', lambda: (msg,))
        return (f"{s}\n" for s in tup)

    def execute_show_(self, ss, listener):
        with self._open_cache_session():
            for line in self._do_execute_show(ss, listener):
                yield line

    def _do_execute_show(self, ss, listener):
        yield '(intermediate directory):\n'
        yield f'  path: {self.path!r}\n'
        yield f'  status: {self.status}\n'

    @property
    def _state(self):
        return self._FFSA[self.status]

    @property
    def status(self):
        return self._cached('status_symbol')

    # == BEGIN cache yikes

    def _cached(self, k):
        cache = self._d
        assert cache is not None
        if len(cache):
            return cache[k]  # VERY experimental

        # Experimental: do this whole cached "performance" all in once place
        status_symbol = self._hit_filesystem_for_initial_status_symbol()
        if 'exists_and_is_directory' == status_symbol:
            func = self._filesystem.listdir
            entries = tuple(func(self.path))
            cache['listdir_tuple'] = entries
            status_symbol = 'non_empty_directory' if len(entries) else 'empty_directory'  # noqa: E501
        cache['status_symbol'] = status_symbol

        return cache[k]

    def _clear_cache_early(self):
        self._d.clear()

    def _hit_filesystem_for_initial_status_symbol(self):
        os_stat_mode = self._filesystem.os_stat_mode
        try:
            mode = os_stat_mode(self.path)
        except FileNotFoundError:
            return 'noent'

        from stat import S_ISDIR as is_directory
        if is_directory(mode):
            return 'exists_and_is_directory'

        return 'exists_and_is_not_directory'

    def _open_cache_session(self):
        # produce the context manger within which you can use the cache

        from contextlib import nullcontext, contextmanager as cm

        # If you are already in the middle of using your cache, do nothing
        if self._d is not None:
            return nullcontext()

        # Since you haven't started your cache yet, create it then destroy
        @cm
        def cm():
            try:
                yield
            finally:
                if (dct := self._d) is None:  # idk
                    return
                dct.clear()  # OCD
                self._d = None
        self._d = {}
        return cm()

    # == END

    @property
    def _FFSA(_):
        return _formal_state_machine()

    @property
    def _filesystem(self):
        return self._injected_filesystem or _real_filesystem()

    component_dictionary_ = None


func = directory_via_path


def _formal_state_machine():
    o = _formal_state_machine
    if o.value is None:
        from script_lib.curses_yikes._formal_state_machine_collection import \
                build_formal_FSA_via_definition_function_ as func
        o.value = func(__name__, _state_machine)
    return o.value


_formal_state_machine.value = None


def _real_filesystem():
    o = _real_filesystem
    if o.value is None:
        o.value = _build_real_filesystem()
    return o.value


_real_filesystem.value = None


class _build_real_filesystem:
    @property
    def mkdir(_):
        from os import mkdir as result
        return result

    @property
    def listdir(_):
        from os import listdir as result
        return result

    def os_stat_mode(_, path):
        from os import stat
        return stat(path).st_mode


def xx(msg=None):
    raise RuntimeError(''.join(('ohai', *((': ', msg) if msg else ()))))

# #born
