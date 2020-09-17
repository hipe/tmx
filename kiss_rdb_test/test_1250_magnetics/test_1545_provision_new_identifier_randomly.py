import unittest


class CommonCase(unittest.TestCase):

    def expect(self, before, after):
        provisioned_before, length = _provisioned_via_bar(before)
        provisioned_before = tuple(provisioned_before)  # make it resuable
        new_int = _subject_module().provision_integer(
                provisioned_integers=provisioned_before,
                capacity=length,
                random_number_generator=_random_number_generator)

        expected_provisioned_after, _ = _provisioned_via_bar(after)
        expected_provisioned_after = tuple(expected_provisioned_after)

        actual_provisioned_after = provisioned_before + (new_int,)
        actual_provisioned_after = sorted(actual_provisioned_after)

        self.assertSequenceEqual(actual_provisioned_after, expected_provisioned_after)  # noqa: E501


def _provisioned_via_bar(bar):

    length = len(bar)
    _ = (i for i in range(0, len(bar)) if _yes_no[bar[i]])
    return _, length


_yes_no = {
        '-': False,
        'X': True,
        }


class Case1545_simplified(CommonCase):

    def test_07_load_module(self):
        self.assertIsNotNone(_subject_module())

    def test_21_from_6(self):
        self.expect(
            '------',
            '--X---')

    def test_36_from_5(self):
        self.expect(
            '--X---',
            '--XX--')

    def test_50_from_4(self):
        self.expect(
            '--XX--',
            '--XX-X')

    def test_64_from_3(self):
        self.expect(
            '--XX-X',
            'X-XX-X')

    def test_79_from_2(self):
        self.expect(
            'X-XX-X',
            'X-XXXX')

    def test_93_from_1(self):
        self.expect(
            'X-XXXX',
            'XXXXXX')


def _random_number_generator(pool_size):
    """
    this is our super-easy-to-read mock of a random number generator.

    we imagine that our real-world provision of a random number generator
    will go something like this:

        import random
        randrange = random.Random('some seed idk').randrange

        def random_number_generator(pool_size):
            return randrange(0, pool_size)

        return random_number_generator

    although the asset we are testing (our "system under test") is
    fundamentally based around pseudo-randomness, in our test we want
    opaque, explicit, easy-to-read determinancy.

    we can get determinancy by seeding the random number generator with some
    hard-coded constant value as we have done above. however, we want the
    finer-grained control of being able to specify number-by-number what
    number is generated at each step so that the number generation fits our
    didactic story.
    """

    return _xx[pool_size]


_xx = {
    6: 2,
    5: 2,
    4: 3,
    3: 0,
    2: 1,
    1: 0,
    }


def _subject_module():
    from kiss_rdb.magnetics_ import provision_ID_randomly_via_identifiers as _
    return _


if __name__ == '__main__':
    unittest.main()

# #born.
