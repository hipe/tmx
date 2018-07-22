# #[#019.file-type-D]

import os.path as os_path


def _():
    dn = os_path.dirname
    import sys

    a = sys.path
    head = a[0]

    top_test_dir = dn(__file__)
    project_dir = dn(top_test_dir)

    if project_dir == head:

        pass  # assume low entrypoint loaded us to use for resources

    elif top_test_dir == head:

        # we get here when running `pud tag_lyfe_test`
        None if project_dir == a[1] else sanity()
        # at #history-A.1 the above changed from being '' to being the
        # project dir.

        # for some weird reason we want the one thing to be first and the
        # other thing to be second. but this might change
        # changed at #history-A.1

        a[0] = project_dir
        a[1] = top_test_dir  # [#019.why-this-in-the-second-position]

    else:
        sanity()


def hello_you():  # #open #[#707.B]
    pass


def sanity(s='assumption failed'):
    raise Exception(s)


_()


from modality_agnostic.memoization import (  # noqa: E402
        dangerous_memoize as shared_subject,
        memoize,
        )

import modality_agnostic.test_support.listener_via_expectations as l_via_e  # noqa: E402 E501


class _Watcher(type):

    def __init__(cls, name, bases, clsdict):
        if len(cls.mro()) > 2:
            _add_memoizing_methods(cls)
        super().__init__(name, bases, clsdict)


class ScaryCommonCase(metaclass=_Watcher):

    def does_not_match_against(self, tup):
        _did = self._yes_no_match(tup)
        self.assertFalse(_did)

    def matches_against(self, tup):
        _did = self._yes_no_match(tup)
        self.assertTrue(_did)

    def _yes_no_match(self, tup):

        cache = _yikes_cache_of_tag_subtrees
        if tup in cache:
            subtree = cache[tup]
        else:
            subtree = _build_tag_subtree(tup)
            cache[tup] = subtree

        _query = self.end_state().result

        _yn = _query.yes_no_match_via_tag_subtree(subtree)
        return _yn  # #todo

    def point_at(self, w):
        _1, _2 = self.end_state().first_emission_messages[1:3]
        offset_of_where_arrow_is_pointing_to = len(_2) - 1
        md = _word_regex().search(_1, offset_of_where_arrow_is_pointing_to)
        _act = md[0]  # ..
        self.assertEqual(_act, w)

    def says(self, s):
        _act = self.end_state().first_emission_messages[0]
        self.assertEqual(_act, s)

    def fails(self):
        self.assertIsNone(self.end_state().result)

    def query_compiles(self):
        sta = self.end_state()
        self.assertIsNotNone(sta.result)
        self.assertIsNone(sta.first_emission_messages)


def _add_memoizing_methods(cls):
    @shared_subject
    def end_state(self):
        return _EndState(self)
    cls.end_state = end_state


def _build_tag_subtree(tag_emblems):
    import tag_lyfe.the_tag_model as lib
    import re

    cache = _yikes_cache_of_tags
    rx = re.compile('^#([a-z]+)$')

    def f(tag_emblem):
        if tag_emblem in cache:
            return cache[tag_emblem]
        else:
            tag = lib.tag_via_sanitized_tag_stem(rx.search(tag_emblem)[1])
            cache[tag_emblem] = tag
            return tag

    return lib.tag_subtree_via_tags(f(x) for x in tag_emblems)


class _EndState:

    def __init__(self, tc):

        em_a = []
        tox = tc.given_tokens()
        listener = l_via_e.listener_via_emission_receiver(em_a.append)
        # listener = l_via_e.for_DEBUGGING

        from tag_lyfe.magnetics import (
                query_via_token_stream as mag,
                )

        from tag_lyfe import NULL_BYTE_

        query_s = NULL_BYTE_.join(tox)

        itr = mag.MAKE_CRAZY_ITERATOR_THING(query_s)

        next(itr)  # ignore the model

        unsani = next(itr)

        x = unsani.sanitize(listener)

        if len(em_a):
            em, = em_a  # ..
            self.first_emission_messages = em.to_strings()
        else:
            self.first_emission_messages = None

        if x is None:
            self.result = None
        else:
            self.result = x


@memoize
def _word_regex():
    import re
    return re.compile(r'\w+')


_yikes_cache_of_tag_subtrees = {}
_yikes_cache_of_tags = {}


# #history-A.1: things changed at upgrade to python 3.7
# #born.
