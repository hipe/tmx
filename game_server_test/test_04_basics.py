import _init_SKETCH  # noqa: F401
import game_server
import unittest


class Case010_basics(unittest.TestCase):

    def test_010_hello_game_server(self):
        x = game_server.hello_game_server()
        self.assertEqual(0, x)


if __name__ == '__main__':
    unittest.main()

# #born: lost DNA
