def desc_lineser_via(description_template_valueser, doc_string):

    if doc_string is None:
        return

    if description_template_valueser is None:
        content_big_s = doc_string
    else:
        content_big_s = doc_string.format(** description_template_valueser())

    from script_lib import deindent_doc_string_

    def desc_lineser():
        return deindent_doc_string_(content_big_s, False)
    return desc_lineser


def help_lines_via(
        program_name, desc_lineser, opts, args,
        usage_tail=None, do_splay=True):

    # -- to find max widths, traverse opts & args memoizing rendered components

    opts_max_width_seer = MaxWidthSeer_()
    args_max_width_seer = MaxWidthSeer_()

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

    _help_option = FormalOption_(
            'h', 'help', None, None, ('show this screen',))

    for opt in opts:
        renderer = _OptionRenderer(opt)
        add_option_rows(renderer)
        opt_shorties.append(renderer.render_shorty())

    add_option_rows(_OptionRenderer(_help_option))  # }}

    for arg in args:
        name = arg.styled_moniker
        args_max_width_seer.see(name)
        for row in _rows_via(name, arg.description_lines):
            arg_rows.append(row)
        arg_shorties.append(name)

    # -- usage lines

    _opts_s = ' '.join(('', *opt_shorties))

    def arg_pieces():
        yield ''
        for s in arg_shorties:
            yield s
        if usage_tail is not None:
            yield usage_tail
    _args_s = ' '.join(arg_pieces())

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

    if True:  # (imagine no help)
        yield
        yield 'options:' if len(opts) else 'option:'  # off by one b.c help
        for line in lines_for_items(opts_max_width_seer.max_width, opt_rows):
            yield line

    if has_args and do_splay:
        yield
        yield 'argument:' if 1 == len(args) else 'arguments:'
        for line in lines_for_items(args_max_width_seer.max_width, arg_rows):
            yield line


def lines_for_items(cel_one_max_width, rows):
    fmt = f'  %-{cel_one_max_width}s  %s'
    for cel_one, cel_two in rows:
        _use_cel_one = '' if cel_one is None else cel_one
        yield fmt % (_use_cel_one, cel_two)


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


class MaxWidthSeer_:
    def __init__(self):
        self.max_width = 0

    def see(self, s):
        w = len(s)
        if self.max_width < w:
            self.max_width = w

# (the below is about :[#017], if we ever document it)
# #history-A.2: spike help screen, archive older explanation of listeners
# #history-A.1: introduce the 'structure' shape
# #abstracted.
