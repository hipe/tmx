from modality_agnostic.test_support.common import lazy
import unittest


CommonCase = unittest.TestCase


class Case2750_AST(CommonCase):

    def test_100_builds(self):
        self.assertIsNotNone(self.AST)

    def test_200_PLACEHOLDER(self):
        ast = self.AST
        ast['interesting_head_phrase']
        ast['node_phrase']
        ast['association_phrase']

    @property
    def AST(self):
        return first_AST()


@lazy
def first_AST():
    from os import path as os_path
    input_path = os_path.join(recordings_dir(), '050-realistic.dot')
    return AST_via_path(input_path)


def AST_via_path(path):
    def listener(severity, *rest):
        if 'debug' == severity:
            return
        raise RuntimeError('cover me')

    with open(path) as lines:
        return asset_lib()._AST_via_input_lines(lines, listener)


@lazy
def recordings_dir():
    from pho_test.common_initial_state import fixture_directory
    return fixture_directory('graph-viz')


def asset_lib():
    from pho.cli import dot2cytoscape
    return dot2cytoscape


if __name__ == '__main__':
    unittest.main()

# #born.
