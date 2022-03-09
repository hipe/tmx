import unittest


class CommonCase(unittest.TestCase):

    def expect_expected_lines(self):
        subject_func = subject_module().lines_via_tree_dictionary
        arg_lines = self.given_recfile_lines()
        from kiss_rdb.cap_server.model_ import _structures_via_recsel as func
        recs_itr = func(arg_lines, listener=None)
        from kiss_rdb.tree_toolkit import tree_dictionary_via_tree_nodes as func
        tree_dct = func(recs_itr, listener=None)
        actual_lines = subject_func(
            tree_dct,
            branch_node_opening_line_by=lambda rec: f"=> {rec.EID}:\n",
            branch_node_closing_line_string=None,
            leaf_node_line_by=lambda rec: f"=> {rec.EID}\n")
        actual_lines = tuple(actual_lines)
        expected_lines = tuple(self.expected_output_lines())
        self.assertSequenceEqual(actual_lines, expected_lines)

    def expected_output_lines(self):
        return unindent(self.expected_output_lines_big_string())

    def given_recfile_lines(self):
        return unindent(self.given_recfile_lines_big_string())


class Case2750_tree_lines_via_tree_typical_case(CommonCase):

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


def subject_module():
    from kiss_rdb import tree_toolkit as mod
    return mod


if __name__ == '__main__':
    unittest.main()

# #born
