import os, sys, unittest

# boilerplate
_ = os.path
path = _.dirname(_.dirname(_.dirname(_.abspath(__file__))))
a = sys.path
if a[0] != path:
    a.insert(0, path)
# end boilerplate

import game_server_test.helper as helper

shared_subject = helper.shared_subject



class Case010(unittest.TestCase):

    def test_050_subject_module_loads(self):
        self.assertIsNotNone(_subject_module())  # ..

    def test_100_subject_builds(self):
        self.assertIsNotNone(self._subject())

    def test_120_you_can_read_the_name(self):
        _guy = self._subject()
        self.assertEqual(_guy.name, 'hello_there')

    @shared_subject
    def _subject(self):
        return _subject_module()(
          name = 'hello_there',
          parameter_stream = helper.empty_iterator(),
        )



def _subject_module():
    from game_server._magnetics import command_via_parameter_stream
    return command_via_parameter_stream.SELF


if __name__ == '__main__':
    unittest.main()

# #born.
