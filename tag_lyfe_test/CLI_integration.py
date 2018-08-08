"""
## synopsis

the central conceit of our integration is CLI-centric. testing against
CLI is cumbersome for all non-CLI-centric behaviors. therefor, we have
siloed both the asset architecture and tests accordingly.



## the central conceit of our integration is CLI-centric

the central "game mechanic" of the "filter by" script is the cleverness of
[#706] how it can parse queries living as they do alongside and in front
of the remaining non-query arguments that also need to be parsed in the
list of command-line arguments.

this is decidedly a CLI contrivance, because all other imaginable modality
use-cases leverage in-built interface mechanics that obviate this somewhat
challenging self-imposed requirement. for example in a GUI (like web) or
even just in a plain old API endpoint call, there will never be a need to
figure out where the query ends and the other stuff begins because there are
pre-existing in-built boundaries between actual arguments. (indeed this
boundary is such an afterthought in non-CLI modalities that it sounds weird
and clinical to frame it in these terms in the first place.)



## testing against CLI is cumbersome for all non-CLI-centric stuff

this is all background to say this: early in the efforts to test (and so
develop) this, it became apparent that it was cumbersome to be trapped
behind the "wall" of CLI (reminiscent to the OCD-triggering discussed in
[#417]); as it pertains to testing all facets of this integration beyond
CLI-specific issues.



## therefor, we have siloed both the asset architecture and tests accordingly.

this dynamic had a retrgrade impact on our architecture: at the birth of
this document we refactored the "architecture" of the filter-by client
by balkanizing it into many small functions that were more modular and
independent.
:[#706.B]
"""


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

    def says_this_as_message_line_regex(self, line):
        self._says_this_as_msg_line(self.assertRegex, line)

    def expect_usage_line(self):
        self._says_this_as_usage_line(self.assertRegex, r'\busage:')

    def _says_only_this(self, f, matcher):
        only_section = self._lone_stderr_section()
        self._says_this_one_line_via_section(only_section, f, matcher)

    def _says_this_one_line(self, f, matcher):
        _section = self.end_state().first_section('stderr')
        self._says_this_one_line_via_section(_section, f, matcher)

    def _says_this_as_msg_line(self, f, matcher):
        self._says_this_as_which_line(1, f, matcher)

    def _says_this_as_usage_line(self, f, matcher):
        self._says_this_as_which_line(0, f, matcher)

    def _says_this_as_which_line(self, offset, f, matcher):
        sect = self._lone_stderr_section()
        f(sect.lines[offset], matcher)

    def _says_this_one_line_via_section(self, section, f, matcher):
        only_line, = section.lines
        f(only_line, matcher)

    def _lone_stderr_section(self):
        only_section, = self.end_state().sections
        self.assertEqual(only_section.which, 'stderr')
        return only_section

    def expect_matches_items(self, * item_names):
        """.#history-A.1 this was where we decided on an abstraction layer
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
        argv = ['«my-proggie»', * _query_s_a]
        coll_id_MIXED = self.given_collection_identifier()
        if coll_id_MIXED is not None:
            argv.append(coll_id_MIXED)

        import script.filter_by as exe

        import script_lib.test_support.stdout_and_stderr_and_end_stater as lib
        sout, serr, finish = lib.for_flip_flopping_sectioner()
        # sout, serr, finish = lib.for_DEBUGGING()

        _stdin = lib.MINIMAL_INTERACTIVE_IO  # ..

        _exitstatus = exe._CLI(_stdin, sout, serr, argv)

        return finish(_exitstatus)


def sanity():
    raise Exception('sanity')


# #history-A.1
# #born.
