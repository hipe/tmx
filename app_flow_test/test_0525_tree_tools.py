import unittest
from dataclasses import dataclass


class CommonCase(unittest.TestCase):

    def expect_expected_lines(self):
        subject_func = subject_module().lines_via_tree_dictionary
        arg_lines = self.given_recfile_lines()
        recs_itr = my_records_via_lines(arg_lines)
        from app_flow.tree_toolkit import tree_dictionary_via_tree_nodes as func
        tree_dct = func(recs_itr, listener=None)
        actual_lines = subject_func(
            tree_dct,
            branch_node_opening_line_by=lambda rec, _: f"=> {rec.EID}:\n",
            branch_node_closing_line_string=None,
            leaf_node_line_by=lambda rec, _: f"=> {rec.EID}\n")
        actual_lines = tuple(actual_lines)
        expected_lines = tuple(self.expected_output_lines())
        self.assertSequenceEqual(actual_lines, expected_lines)

    def expected_output_lines(self):
        return unindent(self.expected_output_lines_big_string())

    def given_recfile_lines(self):
        return unindent(self.given_recfile_lines_big_string())


class Case0525_tree_lines_via_tree_typical_case(CommonCase):

    def test_500_everything(self):
        self.expect_expected_lines()

    def expected_output_lines_big_string(self):
        return """
        => AB:
          => BA
          => BB
        => AC
        => AD
        """

    def given_recfile_lines_big_string(self):
        return """
        Label: Root Thing (Don't see this label)
        ID: AA
        Child: AB
        Child: AC
        Child: AD

        Label: The first section
        ID: AB
        Child: BA
        Child: BB

        Label: The BA item
        ID: BA

        Label: The BB item
        ID: BB

        Label: the AC
        ID: AC

        Label: the AD
        ID: AD

        Label: the BB
        ID: CA
        """

def unindent(big_string):
    memo = unindent
    if not memo.f:
        from text_lib.magnetics.via_words import _the_unindent_function as func
        memo.f = func()
    return memo.f(big_string)


unindent.f = None


# == BEGIN our own "denativizer"
#    denativization is out of scope for this level of testing

def my_records_via_lines(lines):
    from kiss_rdb.storage_adapters.rec import native_records_via_lines as func
    native_recs = func(lines, listener=None)
    return (my_rec_via_native_rec(rec) for rec in native_recs)


def my_rec_via_native_rec(dct):
    use = {}
    use['label'] = one(dct.pop('Label'))
    use['EID'] = one(dct.pop('ID'))
    use['children'] = many(dct.pop('Child', None))
    assert not dct
    return MyRec(**use)


def one(lines):
    assert 1 == len(lines)
    res, = many(lines)
    return res


def many(lines):
    if lines is None:
        return None
    return tuple(do_many(lines))


def do_many(lines):
    for line in lines:
        assert '\n' == line[-1]
        yield line[:-1]


@dataclass
class MyRec:
    label:str
    EID:str
    children:tuple = None

# == END


def subject_module():
    from app_flow import tree_toolkit as mod
    return mod


if __name__ == '__main__':
    unittest.main()

# #history-C.1 hand-written denativization not business model
# #born
