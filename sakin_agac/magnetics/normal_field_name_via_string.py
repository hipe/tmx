"""the idea of a "normal field name" is something like a string that has

only lowercase alpha and the underscore (and maybe some integers somewhere).
this fellow attempts to make one from any string. ("attempts").
"""

import re
import sys


def normal_field_name_via_string(big_s):

    # first, in one pass get rid of characters we know we don't allow
    # (note we keep characters we will use to split on)

    _sanitized_s = _lowlevel_blacklist_rx.sub('', big_s)

    # then, all this

    return '_'.join(s.lower() for s in _split_on_everything(_sanitized_s))


_lowlevel_blacklist_rx = re.compile('[^-a-zA-Z0-9_ \t]+')


def _split_on_everything(big_s):

    for mid_s in _split_on_camel_case(big_s):
        for s in _split_on_whitespace(mid_s):
            yield s


def _split_on_whitespace(s):
    return _whitespace_rx.split(s)


_whitespace_rx = re.compile(r'[- \t]+')


def _split_on_camel_case(s):
    """ruby has to be better at something"""

    offset = 0
    for m in _camelcase_rx.finditer(s):
        offset_ = m.start()
        yield s[offset:offset_]
        offset = offset_
    yield s[offset:]


normal_field_name_via_string._split_on_camel_case = _split_on_camel_case  # #testpoint  # noqa: E501


_camelcase_rx = re.compile('(?<=[a-z])(?=[A-Z])')


sys.modules[__name__] = normal_field_name_via_string

# #abstracted.
