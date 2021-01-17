from modality_agnostic.test_support.common import \
        dangerous_memoize_in_child_classes as shared_subject_in_child_classes
import unittest


class CommonCase(unittest.TestCase):

    @property
    @shared_subject_in_child_classes
    def end_state(self):
        def lines_plus_count():
            count = 0
            for line in self.given_lines():
                count += 1
                yield line
            self._fixture_file_line_count = count
        asts = tuple(subject_function()(lines_plus_count()))
        count = self._fixture_file_line_count
        return asts, count

    def given_lines(self):
        path = self.given_fixture_file()
        with open(path) as fh:
            for line in fh:
                yield line


class Case4853_intro(CommonCase):

    def test_010_loads(self):
        assert subject_module()

    def test_020_parses(self):
        assert self.end_state

    def test_030_line_cound_looks_right(self):
        asts, count = self.end_state
        act = sum(sect.line_count for sect in asts)
        assert count == act

    def given_fixture_file(_):
        return 'pho-doc/notecards/entities/P/B.eno'


def subject_function():
    return subject_module().sections_parsed_coarsely_via_lines


def subject_module():
    import kiss_rdb.storage_adapters.eno as mod
    return mod


if __name__ == '__main__':
    unittest.main()

# #born
