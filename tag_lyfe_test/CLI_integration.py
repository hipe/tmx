from modality_agnostic.memoization import (  # noqa: E402
        dangerous_memoize as shared_subject,
        )


class _MetaClass(type):  # #cp

    def __init__(cls, name, bases, clsdict):
        if len(cls.mro()) > 2:
            _add_common_case_memoizing_methods(cls)
        super().__init__(name, bases, clsdict)


def _add_common_case_memoizing_methods(cls):
    @shared_subject
    def end_state(self):
        return self._build_end_state()
    cls.end_state = end_state


class MemoizyCommonCase(
        metaclass=_MetaClass,
        ):

    # -- assertions

    def says_only_this(self, line):
        self._says_only_this(self.assertEqual, line)

    def says_only_this_regex(self, regex_string):
        self._says_only_this(self.assertRegex, regex_string)

    def says_this_one_line(self, line):
        self._says_this_one_line(self.assertEqual, line)

    def _says_only_this(self, f, matcher):
        only_section, = self.end_state().sections
        self.assertEqual(only_section.which, 'stderr')
        self._says_this_one_line_via_section(only_section, f, matcher)

    def _says_this_one_line(self, f, matcher):
        _section = self.end_state().first_section('stderr')
        self._says_this_one_line_via_section(_section, f, matcher)

    def _says_this_one_line_via_section(self, section, f, matcher):
        only_line, = section.lines
        f(only_line, matcher)

    def expect_matches_items(self, * item_names):
        """(when writing this it occurred to us maybe we want to refactor
        the whole filter-by client so that it semi-artificially enforces
        a modality-agnostic doo-hah:
            - execute for stdout, stderr and argv calls:
            - generator via listener and argv which calls:
            - generator via query and collection identifier
        """

        _lines = self.end_state().first_section('stdout').lines

        def f(line):  # OCD prevents us
            None if '{"aa": "' == line[0:8] else sanity()
            None if '"' == line[14] else sanity()
            return line[8:14]

        _act = tuple(f(x) for x in _lines)
        self.assertEqual(_act, item_names)

    def fails(self):
        _es = self._asserted_exitstatus()
        self.assertNotEqual(_es, 0)

    def succeeds(self):
        _es = self._asserted_exitstatus()
        self.assertEqual(_es, 0)

    def _asserted_exitstatus(self):
        es = self.end_state().exitstatus
        self.assertIsInstance(es, int)
        return es

    # -- the rest

    def _build_end_state(self):

        _query_s_a = self.given_query_tokens()
        _coll_id_MIXED = self.given_collection_identifier()
        _fake_ARGV = ['«my-proggie»', * _query_s_a, _coll_id_MIXED]

        import script.filter_by as exe

        import script_lib.test_support.stdout_and_stderr_and_end_stater as lib
        sout, serr, finish = lib.for_flip_flopping_sectioner()
        # sout, serr, finish = lib.for_DEBUGGING()

        _stdin = lib.MINIMAL_INTERACTIVE_IO  # ..

        _exitstatus = exe._CLI(_stdin, sout, serr, _fake_ARGV)

        return finish(_exitstatus)


def sanity():
    raise Exception('sanity')


# #born.
