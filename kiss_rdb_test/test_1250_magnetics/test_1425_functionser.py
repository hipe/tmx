from modality_agnostic.test_support.common import \
        dangerous_memoize_in_child_classes as shared_subject_in_children, \
        throwing_listener as throw_listen
import unittest
from collections import namedtuple as _nt


"""DISCUSSION
Our main objective is to determine under what circumstances our resources are
and aren't managed correctly in the context of collections.

(For example, we discovered that if you `break` out of the traversal of an
iterator, it doesn't magically call the `__exit__` of its internal CM. It
appears necessary that we indeed wrap every interaction with the collection
in a `with` block. The groundwork laid out here allows us to discover/confirm
constraints like these.)

Our approach here is to *stub* parts of the imaginary thing that take the
SA and a resource identifier and and turn it into a "collection". After a
given "performance" (run), we assert that the faked resource was indeed
closed as we require it to be.

Verisimilitude: our objective is *not* to faithfully re-create the correct
API interface for all the things. Note, for example, we don't have anything
(production or consumption) about emissions (listeners). However, we *do*
want to proscribe the correct "functionser" API with respect to collection
adaptations so keep that correct.
"""


class CommonCase(unittest.TestCase):

    # == Assertions

    def expect_everything_closed_normally(self):
        es = self.end_state
        self.assertTrue(es.resource_is_closed)
        act = es.cm_recordings
        self.assertSequenceEqual(act, ('did_exit',))

    # == End State Components

    @property
    def end_state_result(self):
        return self.end_state.result_value

    # == Build End State

    @property
    @shared_subject_in_children
    def end_state(self):
        mcoll = collectioner()
        sa = mcoll.storage_adapter_via_key('storo_adapto_2')
        fxer = sa.module.FUNCTIONSER_FOR_SINGLE_FILES()
        funcs = fxer.PRODUCE_READ_ONLY_FUNCTIONS_FOR_SINGLE_FILE()
        func = funcs.schema_and_entities_via_lines
        coll_via_opened_lines = build_coll_via_opened_lines(func)
        lines_tup = tuple(self.given_input_lines())
        cm, nexter = recording_context_manager(lines_tup)
        coll = coll_via_opened_lines(cm)
        rv = self.given_run(coll)
        return _EndState(tuple(cm.RECORDINGS), rv, nexter.is_closed)

    do_debug = False


class Case1424_traverse_whole_collection_without_stopping_early(CommonCase):

    def test_100_traverse(self):
        self.expect_everything_closed_normally()
        act = self.end_state_result
        exp = ("Hi I'm 'AA'", "Hi I'm 'BB'")
        self.assertSequenceEqual(act, exp)

    def given_run(self, coll):
        result_ents = []
        with coll.open_entity_traversal() as ents:
            for ent in ents:
                result_ents.append(ent.say_hello_as_entity())
        return tuple(result_ents)

    def given_input_lines(_):
        return 'AA\n', 'BB\n'


class Case1425_traverse_but_stop_early(CommonCase):

    def test_100_traverse(self):
        self.expect_everything_closed_normally()
        act = self.end_state_result
        exp = ("Hi I'm 'QQ'", "Hi I'm 'RR'")
        self.assertSequenceEqual(act, exp)

    def given_run(self, coll):
        result_ents = []
        with coll.open_entity_traversal() as ents:
            for ent in ents:
                if 'SS' == ent.ent_name:
                    break
                result_ents.append(ent.say_hello_as_entity())
        return tuple(result_ents)

    def given_input_lines(_):
        return 'QQ\n', 'RR\n', 'SS\n', 'TT\n'


def build_coll_via_opened_lines(schema_and_ents_via_lines):

    def coll_via_opened_lines(opened):

        class collection:

            def open_entity_traversal(self):
                from contextlib import contextmanager

                @contextmanager
                def cm():
                    fh = opened.__enter__()
                    try:
                        sch, ents = schema_and_ents_via_lines(fh, throw_listen)
                        yield ents
                    finally:
                        opened.__exit__()  # in production a function
                return cm()

        return collection()
    return coll_via_opened_lines


def recording_context_manager(lines_tup):
    assert isinstance(lines_tup, tuple)  # #[#022]

    # Try to simulate an open (then closed) file resource
    class nexter:
        def __init__(self):
            self.is_closed = False

        def __iter__(self):
            return self

        def __next__(self):
            if self.is_closed:
                raise RuntimeError('is closed')
            if not len(stack):
                self.is_closed = True
                raise StopIteration()
            return stack.pop()

    nexter = nexter()  # ick/meh
    stack = list(reversed(lines_tup))

    class cm:
        def __init__(self):
            self.RECORDINGS = []

        def __enter__(self):
            return nexter

        def __exit__(self, *_3):
            nexter.is_closed = True
            self.RECORDINGS.append('did_exit')
    return cm(), nexter


_EndState = _nt(
    'EndState',
    ('cm_recordings', 'result_value', 'resource_is_closed'))


def collectioner():
    from kiss_rdb_test.common_initial_state import didactic_collectioner as fun
    return fun()


if __name__ == '__main__':
    unittest.main()

# #born
