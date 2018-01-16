import os, sys, unittest

# boilerplate
_ = os.path
path = _.dirname(_.dirname(_.abspath(__file__)))
a = sys.path
if a[0] != path:
    a.insert(0, path)
# end boilerplate

import game_server_test.helper as helper

import game_server

helper.hello()

class TestBasics(unittest.TestCase):

    def test_touch_the_top(self):

        x = game_server.hello_game_server()
        self.assertEqual(0, x)

if __name__ == '__main__':
    unittest.main()
