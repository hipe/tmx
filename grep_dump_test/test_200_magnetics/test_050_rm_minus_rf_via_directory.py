from grep_dump_test.common_initial_state import (
        writable_tmpdir)
from modality_agnostic.memoization import (
        dangerous_memoize as shared_subject,
        memoize,
        )

import unittest
import os
p = os.path


class Case010_Main(unittest.TestCase):

    def test_010_function_loads(self):
        self.assertIsNotNone(_subject_function())

    def test_020_story_executes(self):
        self.assertIsNotNone(self._long_story)

    def test_030_the_directory_itself_is_removed(self):
        self.assertFalse(self._long_story['exists after'])

    def test_040_we_see_these_emissions_about_files(self):
        lines = self._lines('info', 'expression', 'removing_file')
        self.assertEqual(3, len(lines))
        self.assertRegex(lines[0], r"^NOTE totally throwing away in-progre")

    def test_050_we_see_these_emissions_about_directories(self):
        lines = self._lines('info', 'expression', 'removing_directory')
        self.assertEqual(3, len(lines))
        self.assertRegex(lines[0], r"^rming dir: ")

    def _lines(self, *channel):
        _d = self._long_story['emissions']

        def line_via_lines(lines):
            self.assertEqual(1, len(lines))
            return lines[0]

        return [line_via_lines(lines) for lines in _d[channel]]

    @property
    @shared_subject
    def _long_story(self):
        """NOTE - convoluted setup..

        ...should ofc be broken up
        """

        def listener(*channel_and_emitter):
            a = list(channel_and_emitter)
            emitter = a.pop()
            channel = tuple(a)
            _lines = [line for line in emitter(None)]
            del a

            if (channel in emissions):
                a = emissions[channel]
            else:
                a = []
                emissions[channel] = a

            a.append(_lines)

        emissions = {}

        work_dir = _build_this_one_tree()
        _itr = _subject_function()(work_dir)
        for uow in _itr:
            uow.execute_emitting_into(listener)

        return {
                'exists after': p.exists(work_dir),
                'emissions': emissions,
                }


def _build_this_one_tree():
    """make this:

        wazoo/
          file-1.txt
          dir-one/
            file-2.txt
            file-3.txt
          dir-two/
    """
    work_dir = p.join(writable_tmpdir, 'wazoo')
    os.mkdir(work_dir)
    _touch(p.join(work_dir, 'file-1.txt'))
    dir_one = p.join(work_dir, 'dir-one')
    os.mkdir(dir_one)
    _touch(p.join(dir_one, 'file-2.txt'))
    _touch(p.join(dir_one, 'file-3.txt'))
    os.mkdir(p.join(work_dir, 'dir-two'))
    return work_dir


def _touch(path):  # #todo how
    open(path, 'w').close()


@memoize
def _subject_function():
    from grep_dump._magnetics.rm_minus_rf_via_directory import (  # #[#204]
       rm_minus_rf_via_directory as x)
    return x


if __name__ == '__main__':
    unittest.main()

# #born.
