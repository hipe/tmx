def build_CLI(definition):
    from ._cli import build_CLI_ as func
    return func(definition)


def hub_via_defininition_(definition):
    # == Define the State Machine

    def beginning_state():  # #[#008.2] this one kind of state machine
        yield 'here_file', handle_here_file, here_file_state

    def here_file_state():
        yield 'templates_dir', handle_templates_dir, templates_dir_state

    def templates_dir_state():
        yield 'template', handle_template, template_state

    def template_state():
        yield 'file', handle_file

    class self:  # #class-as-namespace
        current_state = beginning_state

    # == Action

    def handle_file(def_val):
        test_path_head = None if isabs(def_val) else o['test_path_head']
        o['files'].append(_File_UOW(def_val, test_path_head, o['template']))

    def handle_template(def_val):
        if not isabs(def_val):
            def_val = join(o['templates_dir'], def_val)
        o['template'] = def_val

    def handle_templates_dir(def_val):
        if not isabs(def_val):
            def_val = normpath(join(o['template_head'], def_val))
        o['templates_dir'] = def_val

    def handle_here_file(def_val):
        o['template_head'] = dirname(def_val)
        o['test_path_head'] = dirname(o['template_head'])

    from os.path import dirname, isabs, normpath, join

    o = {'files': []}

    # == Run the State Machine

    for def_k, def_value in definition:  # ..
        not_found = True
        for (formal_k, action, *rest) in self.current_state():
            not_found = False
            break
        if not_found:
            csn = self.current_state.__name__
            raise _DefinitionError(f"no transition from '{csn}' to '{def_k}'")
        next_state = self.current_state
        if len(rest):
            next_state, = rest
        self.current_state = None
        action(def_value)
        self.current_state = next_state

    # == Finish

    return _Hub(tuple(o['files']), o['template_head'])


class _Hub:
    def __init__(self, file_uows, wicked_dir):
        self.file_units_of_work = file_uows
        self.wicked_dir = wicked_dir

    def update_files(self, files, listener, is_dry, edit_in_place_extension):
        from ._updated_file_via_two_file_DOMs import update_files_ as func
        return func(listener, files, is_dry, edit_in_place_extension, self)

    def viztest1_see_how_file_parses(self, path):
        from ._file_DOM_via_lines import _blocks_via_lines as func
        with open(path) as lines:
            for block in func(lines):
                for line in block.to_debugging_lines():
                    yield line

    def to_doc_bigstring(self):
        this_guy = self.wicked_dir
        from os.path import dirname as dn
        yikes = dn(dn(this_guy))
        if yikes == this_guy[:(leng := len(yikes))]:
            this_guy = this_guy[leng+1:]
        return f"wicked template stuff for '{this_guy}'"


class _File_UOW:
    def __init__(self, tail, head, template_path):
        self.tail, self.head, self.template_path = tail, head, template_path
        self._abspath = None

    @property
    def absolute_path(self):
        if self._abspath is None:
            self._abspath = self._to_absolute_path()
        return self._abspath

    def _to_absolute_path(self):
        from os.path import join
        return join(self.head, self.tail)  # tail might be abs, which is ok


class _DefinitionError(RuntimeError):
    pass


def xx(msg=None):
    raise RuntimeError(msg or "wee")


# #born
