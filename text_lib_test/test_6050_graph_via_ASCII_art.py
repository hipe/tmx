from modality_agnostic.test_support.common import \
        dangerous_memoize_in_child_classes as shared_subject_in_child_classes
import unittest


class CommonCaseMetaclass(type):  # #[#510.16] this one kind of meta-class

    def __new__(cls, class_name, bases=None, dct=None):
        res = type.__new__(cls, class_name, bases, dct)
        if unittest.TestCase == bases[-1]:
            return res
        if True:  # leave room in future to make it conditional
            setattr(res, 'test_010_node_names', res.do_test_node_names)

        if True:
            setattr(res, 'test_020_edges', res.do_test_edges)
        return res


class CommonCase(unittest.TestCase, metaclass=CommonCaseMetaclass):

    def do_test_edges(self):
        exp = tuple(self.expected_edges())
        act = tuple(self.actual_edges())
        self.assertSequenceEqual(act, exp)

    def actual_edges(self):
        es = self.end_state
        for edge in es.to_classified_edges():

            # == BEGIN
            if edge.points_to_first:
                if edge.points_to_second:
                    normal = '<->'
                else:
                    normal = '<-'
            elif edge.points_to_second:
                normal = '->'
            else:
                normal = '-'
            # == END

            yield edge.first_node_label, normal, edge.second_node_label

    def do_test_node_names(self):
        exp = tuple(self.expected_nodes())
        act = tuple(self.end_state.nodes.keys())
        self.assertSequenceEqual(act, exp)

    @property
    @shared_subject_in_child_classes
    def end_state(self):
        given_lines = self.given_lines()
        return subject_function()(given_lines)


class Case6038_introduce_verticalesque(CommonCase):

    def expected_nodes(_):
        return 'A', 'B', 'C'

    def expected_edges(_):
        yield 'A', '-', 'B'
        yield 'A', '-', 'C'

    def given_lines(_):
        yield r'    A '
        yield r'   / \ '
        yield r'  B   \ '
        yield r'       C '


class Case6042_introduce_horizontal(CommonCase):

    def expected_nodes(_):
        return 'D', 'E', 'G', 'F'

    def expected_edges(_):
        yield 'D', '->', 'E'
        yield 'D', '<-', 'G'
        yield 'G', '<-', 'F'
        yield 'E', '->', 'F'

    def given_lines(_):
        yield r' D--->E '
        yield r' ^    | '
        yield r' |    v '
        yield r' G<---F '


def subject_function():
    from text_lib.magnetics.graph_via_ASCII_art import func
    return func


if '__main__' == __name__:
    unittest.main()

# #born
