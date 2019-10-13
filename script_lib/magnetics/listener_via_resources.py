"""
This module is the formal home of our "modality-specific adapatation" of

listeners, the essential "modality-agnostic" [#017] concept.

👉 We have #history-A.2 buried an explanation of listeners because it doesn't
belong here but we might want to find it in the :[#017] future.
"""


def desc_lineser_via(description_template_valueser, CLI_function):
    s = CLI_function.__doc__
    if s is None:
        return
    if description_template_valueser is None:
        content_big_s = s
    else:
        content_big_s = s.format(** description_template_valueser())

    from script_lib import deindent_doc_string_

    def desc_lineser():
        return deindent_doc_string_(content_big_s, False)
    return desc_lineser


def help_lines(program_name, desc_lineser, opts, args):

    # -- to find max widths, traverse opts & args memoizing rendered components

    opts_max_width_seer = _MaxWidthSeer()
    args_max_width_seer = _MaxWidthSeer()

    opt_shorties = []
    opt_rows = []
    arg_shorties = []
    arg_rows = []

    has_args = len(args)

    # help gets option rows but (unlike business opts), adds no "shorties" {{

    def add_option_rows(renderer):
        rows = tuple(renderer.to_rows())
        opts_max_width_seer.see(rows[0][0])
        for row in rows:
            opt_rows.append(row)

    from script_lib.cheap_arg_parse import FormalOption_

    _help_option = FormalOption_('-h', ('help', None), ('show this screen',))
    for opt in opts:
        renderer = _OptionRenderer(opt)
        add_option_rows(renderer)
        opt_shorties.append(renderer.render_shorty())

    add_option_rows(_OptionRenderer(_help_option))  # }}

    for arg in args:
        args_max_width_seer.see(arg.name)
        for row in _rows_via(arg.name, arg.description_lines):
            arg_rows.append(row)
        arg_shorties.append(arg.name)

    # -- usage lines

    _opts_s = (' ' + ' '.join(opt_shorties)) if len(opts) else ''
    _args_s = (' ' + ' '.join(arg_shorties)) if has_args else ''

    from os import path as os_path
    use_program_name = os_path.basename(program_name)

    yield f'usage: {use_program_name}{_opts_s}{_args_s}'
    yield f'usage: {use_program_name} --help'

    # -- desco

    if desc_lineser is not None:
        yield
        itr = desc_lineser()
        yield f'description: {next(itr)}'
        for line in itr:
            yield line

    # -- splay options & arguments

    def lines_for_items(cel_one_max_width, rows):
        fmt = f'  %-{cel_one_max_width}s  %s'
        for cel_one, cel_two in rows:
            _use_cel_one = '' if cel_one is None else cel_one
            yield fmt % (_use_cel_one, cel_two)

    if True:  # (imagine no help)
        yield
        yield 'options:' if len(opts) else 'option:'  # off by one b.c help
        for line in lines_for_items(opts_max_width_seer.max_width, opt_rows):
            yield line

    if has_args:
        yield
        yield 'argument:' if 1 == len(args) else 'arguments:'
        for line in lines_for_items(args_max_width_seer.max_width, arg_rows):
            yield line


def string_via_pieces(f):  # #decorator
    def use_f(self):
        return ''.join(f(self))
    return use_f


class _OptionRenderer:
    # DRY the rendering commonalities among "shorty" and rows

    def __init__(self, opt):
        self._long_token = f'--{opt.long_name}'
        if opt.short_name is not None:
            self._short_token = f'-{opt.short_name}'
        if opt.takes_argument:
            self._the_equals_part = f'={opt.meta_var}'
        self._opt = opt

    def to_rows(self):
        _cel_one = self._render_cel_one()
        return _rows_via(_cel_one, self._opt.description_lines)

    @string_via_pieces
    def _render_cel_one(self):
        if self._opt.short_name is not None:
            yield self._short_token
            yield ', '
        yield self._long_token
        if self._opt.takes_argument:
            yield self._the_equals_part

    @string_via_pieces
    def render_shorty(self):
        yield '['
        if self._opt.short_name is None:
            yield self._long_token
        else:
            yield self._short_token
        if self._opt.takes_argument:
            yield self._the_equals_part
        yield ']'


def _rows_via(cel_one, description_lines):
    yield (cel_one, description_lines[0])
    for line in description_lines[1:]:
        yield (None, line)


class _MaxWidthSeer:
    def __init__(self):
        self.max_width = 0

    def see(self, s):
        w = len(s)
        if self.max_width < w:
            self.max_width = w

# #pending-rename: help screen via..
# #history-A.2: spike help screen, archive older explanation of listeners
# #history-A.1: introduce the 'structure' shape
# #abstracted.
