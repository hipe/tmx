"""
## objectives, requirements and provisions (all subject to change)

so:
  - we write this *after* the bulk of the query model is finished

  - let's have fun

and:

  - hopscotch

  - warnings
"""


import _init  # noqa F401
from tag_lyfe_test.tagging import (
        TaggingCommonCase as _ThisCase,
        )
import unittest


_CommonCase = unittest.TestCase


class Case042_empty_string(_CommonCase, _ThisCase):

    def given_string(self):
        return ''

    def expect_shadow(self):
        return ''


class Case125_string_with_no_octothorpe(_CommonCase, _ThisCase):

    def given_string(self):
        return 'foo'

    def expect_shadow(self):
        return 'sss'


class Case208_octothorpe_at_end(_CommonCase, _ThisCase):

    def given_string(self):
        return '#'

    def expect_shadow(self):
        return 's'


class Case292_quite_simple(_CommonCase, _ThisCase):

    def given_string(self):
        return '#foo'

    def expect_shadow(self):
        return 'TTTT'


class Case375_begin_with_number(_CommonCase, _ThisCase):

    def given_string(self):
        return '#8ee4ff'

    def expect_shadow(self):
        return 'TTTTTTT'


class Case458_not_this__need_space(_CommonCase, _ThisCase):

    def given_string(self):
        return 'welf#foo'

    def expect_shadow(self):
        return 'ssssssss'


class Case542_yes_this__has_space(_CommonCase, _ThisCase):

    def given_string(self):
        return 'welf #foo'

    def expect_shadow(self):
        return 'sssssTTTT'


class Case625_false_alarm_separator_run(_CommonCase, _ThisCase):

    def given_string(self):
        return 'welf hi #foo'

    def expect_shadow(self):
        return 'ssssssssTTTT'


class Case708_strange_hashtag_wont_mess(_CommonCase, _ThisCase):

    def given_string(self):
        return 'welf h#i #foo'

    def expect_shadow(self):
        return 'sssssssssTTTT'


class Case792_multiple_tags_no_head_no_tail(_CommonCase, _ThisCase):

    def given_string(self):
        return '#foo #bar'

    def expect_shadow(self):
        return 'TTTTsTTTT'


class Case875_multiple_tags_no_head_yes_tail(_CommonCase, _ThisCase):

    def given_string(self):
        return '#foo  #bar '

    def expect_shadow(self):
        return 'TTTTssTTTTs'


class Case958_three_not_two(_CommonCase, _ThisCase):

    def given_string(self):
        return '#foo  #bar #baz '

    def expect_shadow(self):
        return 'TTTTssTTTTsTTTTs'


if __name__ == '__main__':
    unittest.main()

# #born.
