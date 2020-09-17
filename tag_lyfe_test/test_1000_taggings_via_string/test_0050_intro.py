"""
the salient features of the grammar demonstrated here:

  - "hopscotch" between "taggings" and "garbage"
"""

from tag_lyfe_test.tagging import TaggingCommonCase as _ThisCaseHere
import unittest


class _ThisCase(_ThisCaseHere):

    def test_100_shadow(self):
        _exp = self.expect_shadow()
        super().expect_shadow(_exp)  # the worst..


CommonCase = unittest.TestCase


class Case0042_empty_string(CommonCase, _ThisCase):

    def given_string(self):
        return ''

    def expect_shadow(self):
        return ''


class Case0043_string_with_no_octothorpe(CommonCase, _ThisCase):

    def given_string(self):
        return 'foo'

    def expect_shadow(self):
        return 'sss'


class Case0045_octothorpe_at_end(CommonCase, _ThisCase):

    def given_string(self):
        return '#'

    def expect_shadow(self):
        return 's'


class Case0046_quite_simple(CommonCase, _ThisCase):

    def given_string(self):
        return '#foo'

    def expect_shadow(self):
        return 'TTTT'


class Case0048_begin_with_number(CommonCase, _ThisCase):

    def given_string(self):
        return '#8ee4ff'

    def expect_shadow(self):
        return 'TTTTTTT'


class Case0049_not_this__need_space(CommonCase, _ThisCase):

    def given_string(self):
        return 'welf#foo'

    def expect_shadow(self):
        return 'ssssssss'


class Case0051_yes_this__has_space(CommonCase, _ThisCase):

    def given_string(self):
        return 'welf #foo'

    def expect_shadow(self):
        return 'sssssTTTT'


class Case0052_false_alarm_separator_run(CommonCase, _ThisCase):

    def given_string(self):
        return 'welf hi #foo'

    def expect_shadow(self):
        return 'ssssssssTTTT'


class Case0054_strange_hashtag_wont_mess(CommonCase, _ThisCase):

    def given_string(self):
        return 'welf h#i #foo'

    def expect_shadow(self):
        return 'sssssssssTTTT'


class Case0055_multiple_tags_no_head_no_tail(CommonCase, _ThisCase):

    def given_string(self):
        return '#foo #bar'

    def expect_shadow(self):
        return 'TTTTsTTTT'


class Case0057_multiple_tags_no_head_yes_tail(CommonCase, _ThisCase):

    def given_string(self):
        return '#foo  #bar '

    def expect_shadow(self):
        return 'TTTTssTTTTs'


class Case0058_three_not_two(CommonCase, _ThisCase):

    def given_string(self):
        return '#foo  #bar #baz '

    def expect_shadow(self):
        return 'TTTTssTTTTsTTTTs'


if __name__ == '__main__':
    unittest.main()

# #born.
