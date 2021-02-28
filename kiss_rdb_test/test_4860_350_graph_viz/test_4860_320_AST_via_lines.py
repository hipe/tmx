from modality_agnostic.test_support.common import lazy
from unittest import TestCase as unittest_TestCase, main as unittest_main
from collections import namedtuple
from os.path import join as path_join


class CommonCase(unittest_TestCase):

    def build_end_state(self):
        dct = {}

        if True:
            path = self.given_fixture_path()
            opened = open(path)

        with opened as fh:
            for sx in subject_function()(fh):
                typ = sx[0]
                if (arr := dct.get(typ)) is None:
                    dct[typ] = (arr := [])
                arr.append(sx)

        es = EndState(
            node_expressions=dct.pop('node_expression', None),
            edge_expressions=dct.pop('edge_expression', None))

        assert not dct
        return es


class Case4860_316_this_file(CommonCase):

    def test_030_you_can_see_node_names(self):
        es = self.build_end_state()
        act = tuple(ne.node_identifier for ne in es.node_expressions)
        exp = 'node1', 'node2'
        self.assertSequenceEqual(act, exp)

    def test_040_you_get_the_node_attribute_list_as_a_plain_dict(self):
        es = self.build_end_state()
        dct = es.node_expressions[0].attributes
        assert isinstance(dct, dict)
        exp = ('artist|\n'
               '<artist_ID> artist_ID int primary key|\n'
               '<artist_title> artist_title text')
        self.assertEqual(dct['label'], exp)

    def test_060_edges_you_get_all_four_names(self):
        es = self.build_end_state()
        edge, = es.edge_expressions
        act = these_four(edge)
        exp = 'node1 artist_ID node2 artist_ID'.split()
        self.assertSequenceEqual(act, exp)

    def test_080_edges_have_attributes_too(self):
        es = self.build_end_state()
        edge, = es.edge_expressions
        assert 'odot' == edge.attributes['arrowhead']

    def given_fixture_path(_):
        return fixture_file_one()


def these_four(edge):
    return tuple((getattr(edge, attr) for attr in edge._fields[1:5]))


EndState = namedtuple('EndState', 'node_expressions edge_expressions'.split())


def fixture_file_one():
    head = my_fixtures_dir()
    return path_join(head, '050-one-to-many-minimal.dot')


@lazy
def my_fixtures_dir():
    from os.path import dirname as dn
    test_top = dn(dn(__file__))
    return path_join(test_top, 'fixture-directories', '4860-350-graph-viz')


def subject_function():
    return subject_module().func


def subject_module():
    import kiss_rdb.storage_adapters.graph_viz.AST_via_lines as mod
    return mod


if __name__ == '__main__':
    from sys import argv
    if 1 < len(argv) and '--list' == argv[1]:
        def w(s):
            write(s)
            write('\n')
        from sys import stdout
        write = stdout.write
        w(fixture_file_one())
        exit(0)
    unittest_main()

# #born
