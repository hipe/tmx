from modality_agnostic.test_support.common import \
        dangerous_memoize_in_child_classes as shared_subj_in_child_classes
import unittest


class CommonCase(unittest.TestCase):

    @property
    @shared_subj_in_child_classes
    def end_state(self):
        return tuple(self.build_end_state())

    do_debug = False


def properties_via_offsets(attr, num):  # #

    def build_function(offset):
        def getter(tc):
            return getattr(tc, attr)[offset]
        return property(getter)

    return (build_function(i) for i in range(0, num))


class Case0303_reproduces_the_lines(CommonCase):

    def test_050_loads(self):
        assert subject_module()

    def test_100_has_name_as_property(self):
        self.assertEqual(self.fh.name, 'ohai.file')

    def test_150_puts_back_out_the_lines(self):
        lines = self.lines
        assert lines == ('aa', 'bb', 'cc')

    def test_200_multiple_closes_complains_FOR_NOW(self):
        fh = self.fh
        fh.close()
        with self.assertRaises(RuntimeError) as cm:
            fh.close()
        msg, = cm.exception.args
        self.assertEqual('for now we whine about mutiple closes', msg)

    fh, lines = properties_via_offsets('end_state', 2)

    def build_end_state(self):
        fh = subject_function()(iter(('aa', 'bb', 'cc')), 'ohai.file')
        yield fh
        lines = tuple(line for line in fh)
        yield lines


class Case0306_close_then_try_to_read(CommonCase):

    def test_050_big_story(self):
        fh = subject_function()(iter(('aa', 'bb', 'cc')), 'me')
        assert 'aa' == next(fh)
        fh.close()
        with self.assertRaises(ValueError) as cm:
            next(fh)
        msg, = cm.exception.args
        assert 'I/O operation on closed file.' == msg


def subject_function():
    return subject_module().mock_filehandle


def subject_module():
    import modality_agnostic.test_support.mock_filehandle as module
    return module


if __name__ == '__main__':
    unittest.main()

# #born 18 months after
