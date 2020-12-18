def config_via_definition(config_defn, **kw):
    from pho.magnetics_.generation_config_via_definition import func
    return func(config_defn, **kw)


class _MockFilesystem:

    def __init__(self, scn):
        self._scanner = scn

    def mkdir(self, path):
        exp_path, = self._expect('pretend_mkdir')
        if exp_path == path:
            return
        xx(f"expected path {exp_path!r}, had {path!r}")

    def listdir(self, path):
        exp_path, itr, = self._expect('pretend_listdir')
        if exp_path != path:
            xx(f"expected path {exp_path!r}, had {path!r}")
        return list(itr)

    def os_stat_mode(self, path):
        exp_path, result_sigil = self._expect('pretend_os_stat_mode')

        if exp_path != path:
            xx(f"expected path {exp_path!r}, had {path!r}")

        if 'no_ent' == result_sigil:
            raise FileNotFoundError('no see reason')

        if 'existing_directory' == result_sigil:
            # (`os.stat("some_existing_directory").st_mode` on my system)
            return 16877

        if 'is_file_not_directory' == result_sigil:
            return 33188  # some empty file we touched

        xx(f"fun, please implement this result sigil: {result_sigil!r}")

    def _expect(self, method_sigil):
        scn = self._scanner
        if scn.empty:
            xx(f"expected no more filesystem interactions, had {method_sigil!r}")  # noqa: E501
        exp = scn.next()
        exp_meth_sigil = exp[0]
        if exp_meth_sigil != method_sigil:
            xx(f"expected {exp_meth_sigil!r}, had {method_sigil!r}")
        return exp[1:]


def BUILD_MOCK_FILESYSTEM(expected):

    from text_lib.magnetics.scanner_via import scanner_via_iterator as func
    scn = func(expected)

    fs = _MockFilesystem(scn)

    def done():
        if scn.empty:
            return
        xx(f"expected but never encountered {scn.peek[0]!r}")

    return fs, done


def xx(msg=None):
    raise RuntimeError(''.join(('ohai', *((': ', msg) if msg else ()))))

# #born
