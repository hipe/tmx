class SSG_controller_via_defn:

    def __init__(self, itr):
        self._these = []
        for direc in itr:
            if 'source_directory' == direc[0]:
                self._accept_source_directory(* direc[1:])

    def _accept_source_directory(self, pc):
        from pho.config_component_ import varname_via_placeholder_ as func
        varname = func(pc)
        if not varname:
            xx('no')
            self._source_directory = pc  # no. it's a string
            return
        self._source_directory_varname = varname
        self._these.append((varname, 'source_directory'))

    def finish_via_resolved_forward_references(self, comps):
        kw = {v: comps[k] for k, v in self._these}
        kw['source_directory_varname'] = self._source_directory_varname
        return _SSG_Controller(**kw)

    @property
    def forward_references(self):
        return (tup[0] for tup in self._these)


class _SSG_Controller:

    def __init__(self, source_directory, source_directory_varname):
        self._source_directory = source_directory
        self._source_directory_varname = source_directory_varname

    def EXECUTE_COMMAND(self, cmd, listener, stylesheet=None):
        xx("this is next")

    def execute_show_(self, ss, listener):
        yield ''.join((self.label_for_show_, ss.colon, '\n'))

        if (sdvn := self._source_directory_varname):
            yield ''.join((ss.tab, 'source directory: ', sdvn, '\n'))
            return

        lines = iter(self._source_directory.execute_show_(ss, listener))
        first_line = next(lines)

        yield ''.join((ss.tab, 'source directory ', first_line))

        for line in lines:
            yield ''.join((ss.tab, line))

    label_for_show_ = '(SSG controller)'


class intermediate_directory_via_defn:

    def __init__(self, itr, filesystem=None):
        self._filesystem = filesystem
        for direc in itr:
            typ = direc[0]
            if 'path' == typ:
                self._process_path(direc[1:])
            else:
                xx()

    def finish_via_resolved_forward_references(self, comps):
        path = self._path
        del self._path
        path = path.finish_via_resolved_forward_references(comps)
        from pho.config_component_.directory_via_path import func
        return func(path, _functions, filesystem=self._filesystem)

    def _process_path(self, rest):
        from pho.config_component_.path_with_forward_references import func
        path = func(rest)
        self._forward_references_of_path = path.forward_references
        self._path = path

    @property
    def forward_references(self):
        return self._forward_references_of_path


class _functions:
    pass


def xx(msg=None):
    raise RuntimeError(''.join(('ohai', *((': ', msg) if msg else ()))))

# #born
