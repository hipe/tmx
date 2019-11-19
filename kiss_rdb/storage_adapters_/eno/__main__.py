def _CLI(sin, sout, serr, argv):

    # == BEGIN experiment (take this out and it still works)
    from os import PathLike

    class Xx(PathLike):
        def __fspath__(self):
            return _experiment()

    argv[0] = Xx()
    # == END

    from script_lib.cheap_arg_parse import cheap_arg_parse
    return cheap_arg_parse(
            _do_CLI, sin, sout, serr, argv,
            formal_parameters=(('file', 'some eno file'),),
            description_template_valueser=lambda: {})


def _do_CLI(mon, sin, sout, serr, file_path):
    """ad-hoc develoment utility for seeing a parsed eno document as a dump.

    not complete. (This was really just tooling to find the cause of a "bug"
    that turned out to be us cutting off the trailing newline on every
    multi-line text field because that's how the eno markup works.)
    """

    if True:
        with open(file_path) as fh:
            big_string = fh.read()

    from enolib import parse as enolib_parse
    doc = enolib_parse(big_string)

    def recurse(parent, depth=0):
        margin = margin_for(depth)
        _elements = parent.elements()
        for el in _elements:
            _these = tuple(_profile_via(el))
            one, = _these  # ..
            if 'yields_section' == one:
                sect = el.to_section()
                sout.write(f'{margin}{sect.string_key()}:\n')
                recurse(sect, depth+1)
            elif 'yields_field' == one:
                field = el.to_field()
                k = field.string_key()
                v = field.required_string_value()
                if '\n' in v:
                    sout.write(f'{margin}{k}: ')
                    sout.write(repr(v))
                    sout.write('\n')
                else:
                    sout.write(f'{margin}{k}: {v}\n')
            else:
                raise Exception(f'do me: {one}')

    def margin_for(depth):
        if len(ocd_cache) <= depth:
            for i in range(len(ocd_cache), depth+1):
                ocd_cache.append(' ' * i)
        return ocd_cache[depth]

    ocd_cache = []

    recurse(doc)
    return mon.exitstatus


def _experiment():
    here = __file__
    _tail = here[here.index('kiss_rdb'):]  # not robust
    from os.path import dirname
    _inner = dirname(_tail)
    from os import sep as path_separator
    _mod_name = _inner.replace(path_separator, '.')
    return f'py -m {_mod_name}'


def _profile_via(el):
    for m in ('yields_empty', 'yields_field', 'yields_fieldset',
              'yields_fieldset', 'yields_section'):
        if getattr(el, m)():
            yield m


if __name__ == '__main__':
    import sys as o
    exit(_CLI(o.stdin, o.stdout, o.stderr, o.argv))

# #born.
