import unittest


def _yuck_normalize_sys_path():  # in denial about [#019]
    from sys import path as a
    from os import path

    dn = path.dirname
    head = a[0]

    test_sub_dir = dn(path.abspath(__file__))
    mono_repo_dir = dn(dn(test_sub_dir))

    if test_sub_dir == head:
        # test file or its directory entrypoint
        a[0] = mono_repo_dir
    elif mono_repo_dir == head:
        # topmost test dir was entrypoint
        pass
    else:
        raise Exception('sanity')


_yuck_normalize_sys_path()


from modality_agnostic.memoization import (  # noqa: E402
        dangerous_memoize as shared_subject,
        )


_CommonCase = unittest.TestCase


class Case100_works(_CommonCase):

    def test_100_loads(self):
        self.assertIsNotNone(_subject_function())

    def test_200_works(self):
        _these = {'fn': 'Xx', 'ln': 'Yy'}
        _lines = _subject_function()(
                _these, "hello $fn $ln\n", lambda x: x, None)
        a = []
        for line in _lines:
            a.append(line)

        self.assertEqual(a, ["hello Xx Yy\n"])


class Case200_fails(_CommonCase):

    def test_100_channel(self):
        chan = self._channel_and_lines()[0]
        self.assertEqual(
                chan, ['error', 'expression', 'missing_required_doohahs'])

    def test_200_message(self):
        lines = self._channel_and_lines()[1]
        line, = lines  # assert exactly one
        self.assertEqual(
                line, 'set these environment variables: (Qfn, Qln)')

    @shared_subject
    def _channel_and_lines(self):

        emissions = []

        def listener(*args):
            *chan, lines = args
            emissions.append((chan, list(lines())))

        _these = {'no': 'see'}
        _lines = _subject_function()(
                _these, "hello $fn $ln\n", lambda x: f'Q{x}', listener)

        self.assertIsNone(_lines)

        em, = emissions  # assert exactly one
        chan, lines = em

        return (chan, lines)


def _subject_function():
    import script.lines_via_template as _
    return _._lines_via


if __name__ == '__main__':
    unittest.main()

# #born.
