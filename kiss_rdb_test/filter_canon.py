from modality_agnostic.memoization import (  # noqa: E402
        dangerous_memoize as shared_subject,
        memoize,
        )


class _MetaClass(type):  # #cp

    def __init__(cls, name, bases, clsdict):
        if len(cls.mro()) > 2:
            _add_common_case_memoizing_methods(cls)
        super().__init__(name, bases, clsdict)


def _add_common_case_memoizing_methods(cls):

    @shared_subject
    def _lines_AI(self):  # "AI" = API_integration (module-private method)
        return self.assume_exactly_one_emission().to_strings()
    cls._lines_AI = _lines_AI

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
        _ = self.assume_exactly_one_emission_and_of_that_exactly_one_line()
        f(_, matcher)

    def _says_this_one_line(self, f, matcher):
        em = self.assume_exactly_one_emission()
        _ = em.to_first_string()
        f(_, matcher)

    def first_line(self):
        return self._lines_AI()[0]

    def second_line(self):
        return self._lines_AI()[1]

    def assume_exactly_one_emission_and_of_that_exactly_one_line(self):
        em = self.assume_exactly_one_emission()
        _, = em.to_strings()
        return _

    def assume_exactly_one_emission(self):
        em, = self.end_state().emissions  # ..
        return em

    def expect_matches_items(self, * item_names):

        _items = self.end_state().result_items

        def f(item):
            return item['aa']

        _act = tuple(f(x) for x in _items)
        self.assertEqual(_act, item_names)

    def fails(self):
        """
        our working definition for how we know an API call failed:
          - if it had no results in the iterator traveral thing AND
          - emitted an error as its last emission
        """
        es = self.end_state()
        self.assertEqual(len(es.result_items), 0)
        em = es.emissions[-1]
        self.assertEqual(em.channel[0], 'error')

    def succeeds(self):
        """
        our definition for success should simply be to invert the definition
        for failure, but we're gonna go practical instead:
        """

        for em in self.end_state().emissions:
            if 'info' != em.channel[0]:  # extra paranoid for now
                self.fail(f'expected no error emission (had: {em.channel[0]})')

    def _asserted_exitstatus_TAINTED(self):
        es = self.end_state().exitstatus
        self.assertIsInstance(es, int)
        return es

    # -- the rest

    def _build_end_state(self):

        import modality_agnostic.test_support.listener_via_expectations as lib

        emissions = []
        listener = lib.listener_via_emission_receiver(emissions.append)
        # listener = lib.for_DEBUGGING

        query = self.given_query()

        coll_id = self.given_collection_identifier()

        import script.filter_by as exe

        _ = exe._filtered_items_via_query_and_collection_id(
                query, coll_id, listener)

        result_items = tuple(_)

        return _EndState(emissions, result_items)

    def given_query(self):
        """
        this method definition exists as a default definition, one that
        calls out to a hook-out and (as a convenience) parses the query.

        however if a test knows it's going to re-use a query a lot, consider
        memoizing..
        """

        return query_via_tokens(* self.given_query_tokens())


class _LazyExperiment:

    def __init__(self):
        self._call = self._call_initially

    def __call__(self, line):
        return self._call(line)

    def _call_initially(self, line):
        import re
        rx = re.compile(r'[().]')

        def f(line_):
            return rx.sub('', line_)
        self._call = f
        return self(line)


simplify_emission_line = _LazyExperiment()
simplify_emission_line.__doc__ = """hacky fellow:
    given this:
        "(1 match(es) of 2 item(s) seen.)"

    as this:
        "1 matches of 2 items seen"

    (#[#007.2] wish doctest)
"""


class _EndState:

    def __init__(self, em_a, dcts):
        self.emissions = em_a
        self.result_items = dcts


@memoize
def query_which_is_no_see():
    return query_via_tokens('#x-no-see')


def query_via_tokens(*tokens):
    """we aren't here to test parse failures of queries (altho CLI test yes)
    """
    import script.filter_by as exe
    tokens = [*tokens, 'not_a_keyword']
    # (awful bleedthru of our [#706] central conceit - work around the
    # special dog-ear appropriation of allowing a null query)
    res = exe._parse_query(tokens, None).execute()
    aaq = res.args_after_query
    None if (1 == len(aaq) and 'not_a_keyword' == aaq[0]) else sanity()
    # sanity() if len(aaq) else None
    return res.query


def sanity():
    raise Exception('sanity')


# #born.
