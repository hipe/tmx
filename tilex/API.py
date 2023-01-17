#!/usr/bin/env -S python3 -W error::::

"""At #birth we don't know exactly how far to carry this architecture
because it has a self-dependent loop in its conception:

- We want our backends to be able to be "mounted" by e.g. flask
- To do that we "need" to "cover" flask documentation "systematically"
- This started as the backend for that system.

As such, this script will help discover its own shortcomings, and in this
way eventually become "self-supporting", at which point, hopefully the
major annoyances here will get cleaned up.
"""

def _CLI(_, sout, __, argv):
    try:
        return _main(sout, argv)
    except _Stop as e:
        sout.write(str(e))
        return 3


def _main(sout, argv):
    """On the surface it looks like we support the same syntax as that
    of our apprentice, but in actuality for the time being (given note at
    top of file) our "syntax" is actually just a fixed sequence of literal
    tokens; that is, there is only one command string (at writing) that is
    valid to invoke this backend.

    As such, don't get attached to *any* of the below; but *all* of it
    is experimental to the end of seeing how each possible innovation "feels"
    """

    # Derive exactly one endpoint path from ARGV
    path_tail = _imagine_parsing_many_things_from_ARGV(argv)

    # Load the module for the endpoint
    mod, typ = _path_tail_splitext(path_tail)

    if 'JSON' == typ:
        func_name = 'WRITE_JSON__INTERFACE_IS_EXPLORATORY'
    else:
        assert 'LINES' == typ
        func_name = 'WRITE_LINES__INTERFACE_IS_EXPLORATORY'

    endpoint_func = getattr(mod, func_name)  # ..

    return endpoint_func(sout, _stop)


def _path_tail_splitext(path_tail):
    assert len(path_tail)
    assert '/' != path_tail[0]  # just helpful sanity reminder
    from os.path import splitext
    slug, ext = splitext(path_tail)
    assert ext in ('.json', '.lines')
    typ = ext[1:].upper()
    use_stem = slug.replace('-', '_')
    pcs = 'tilex', '_endpoints', use_stem
    mod_name = '.'.join(pcs)
    from importlib import import_module
    mod = import_module(mod_name)  # ..
    return mod, typ


def _imagine_parsing_many_things_from_ARGV(argv):
    arg = _one_arg_via_argv(argv)
    scn = _CustomStringScanner(arg)
    scn.mandatory('fparam', ':')
    scn.mandatory('url', '=')
    scn.mandatory('', '/')  # require a leading slash before the "API" part
    scn.mandatory('API', '/')
    path_tail = scn.flush()
    literal = 'youtubes-treemap.json'
    if path_tail == literal:
        return path_tail
    if 'front-page-thing.lines' == path_tail:
        return path_tail
    if True:
        _stop(f"expecting {literal!r} had {path_tail!r}")


class _CustomStringScanner:

    def __init__(self, string):
        self.string = string
        self.pos = 0
        self.last = len(string) - 1

    def mandatory(self, literal, delimiter):
        pos = self.string.find(delimiter, self.pos)
        if -1 == pos:
            context = repr(self.string[self.pos:self.pos+5])
            _stop(f"expecting {delimiter!r} near {context}")
        if pos == self.last:
            _stop("expecting more at end of path")
        my_next_pos = pos + 1
        actual = self.string[self.pos:pos]
        if actual != literal:
            _stop(f"expecting {literal!r} had {actual!r}")
        self.pos = my_next_pos

    def flush(self):
        res = self.string[self.pos:]
        self.pos = self.last
        del self.string
        return res


def _one_arg_via_argv(argv):
    if 1 == len(argv):
        _stop("expecting argument: fparam:url=")

    if 2 < len(argv):
        _stop(f"unexpected argument: {argv[2]!r}")

    return argv[1]


def _stop(reason):
    raise _Stop(reason)


class _Stop(RuntimeError):
    pass


if '__main__' == __name__:
    from sys import stdout, argv
    exit(_CLI(None, stdout, None, argv))

# #birth
