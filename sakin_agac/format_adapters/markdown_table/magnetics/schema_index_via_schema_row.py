from sakin_agac import (
        cover_me,
        )
import re


class SELF:

    def __init__(self, schema_as_line):
        (
            self.__field_readerer,
            self.offset_via_field_name__,
        ) = _these_two(schema_as_line)

    def field_reader(self, field_name):
        return self.__field_readerer(field_name)


def _these_two(schema_as_line):
    """given a table with a header row like this, make a dictionary like this

    like this:
        | Foo Biff Bazz  | Bumbo-Boffo     | Xx

    like this:
        { 'foo_biff_bazz': 0, 'bumbo_boffo': 1, 'xx': 2 }

    this way, given a "normal field name" you can know the offset of the field
    """

    cels_count = schema_as_line.cels_count
    schema_row = schema_as_line.row_DOM

    def normal_field_name_via_offset(offset):
        _cel_DOM = schema_row.cel_at_offset(offset)
        _s = _cel_DOM.content_string()
        return _normal_field_via_whatever_this_is(_s)

    _f = normal_field_name_via_offset
    name_and_offsets = ((_f(i), i) for i in range(cels_count))
    name_and_offsets = [x for x in name_and_offsets]  # ..
    offset_via_normal_field_name = {k: v for (k, v) in name_and_offsets}
    if len(name_and_offsets) != len(offset_via_normal_field_name):
        cover_me('duplicate field name? (when normalized)')

    def f(s):
        offset = offset_via_normal_field_name[s]

        def g(item):
            _cel = item.ROW_DOM_.cel_at_offset(offset)
            _val_s = _cel.content_string()
            return _val_s  # #todo
        return g
    return (f, offset_via_normal_field_name)


def _normal_field_via_whatever_this_is(big_s):  # #testpoint

    # first, in one pass get rid of characters we know we don't allow
    # (note we keep characters we will use to split on)

    _sanitized_s = _lowlevel_blacklist_rx.sub('', big_s)

    # then, all this

    return '_'.join(s.lower() for s in _split_on_everything(_sanitized_s))


def _split_on_everything(big_s):

    for mid_s in _split_on_camel_case(big_s):
        for s in _split_on_whitespace(mid_s):
            yield s


def _split_on_whitespace(s):
    return _whitespace_rx.split(s)


def _split_on_camel_case(s):  # #testpoint
    """ruby has to be better at something"""

    offset = 0
    for m in _camelcase_rx.finditer(s):
        offset_ = m.start()
        yield s[offset:offset_]
        offset = offset_
    yield s[offset:]


_camelcase_rx = re.compile('(?<=[a-z])(?=[A-Z])')

_whitespace_rx = re.compile(r'[- \t]+')

_lowlevel_blacklist_rx = re.compile('[^-a-zA-Z0-9_ \t]+')

# #born.
