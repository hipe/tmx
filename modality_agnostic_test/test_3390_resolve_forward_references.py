import unittest


class CommonCase(unittest.TestCase):

    def go(self):
        cc = {k: v for k, v in self.given_compound_component()}
        act = plan_via_dependency_graph(cc.items())
        exp = tuple(self.expected_plan())
        self.assertSequenceEqual(act, exp)


class Case3390_(CommonCase):

    def test_100_go(self):
        self.go()

    def expected_plan(_):
        yield 'no_dependencies', 'C'
        yield 'resolve', 'B'
        yield 'resolve', 'A'

    def given_compound_component(_):
        yield 'A', depends_on('C', 'B')
        yield 'B', depends_on('C')
        yield 'C', depends_on()


class depends_on:

    def __init__(self, *ks):
        self.forward_references = tuple(ks)


def plan_via_dependency_graph(items):
    from modality_agnostic.magnetics.resolve_forward_references import \
            plan_via_dependency_graph as func
    return func(items)


if __name__ == '__main__':
    unittest.main()

# #born
