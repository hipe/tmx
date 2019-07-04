# just messing around


def build_parser(but_wrong):
    from kiss_rdb.magnetics_.string_scanner_via_definition import (
            pattern_via_description_and_regex_string as o)

    if but_wrong:
        # this is a super big hack to accomodate the wrong format in "tag-lyfe"
        head = o('hashtag', r'(?:\[\\\[)?#')
        body = o('identifier body', r'[^ |\\\]]+')  # pessimistic-is
        tail = o('maybe this one thing', r'(?:\\\]\])?')
    else:
        head = o('square bracket and octothorpe', r'\[#')
        body = o('identifier body', r'[^\]]+')  # optimistic
        tail = o('closing square bracket', r'\]')

    def parse(scn):
        scn.skip_required(head)
        content = scn.scan_required(body)
        scn.skip_required(tail)
        one_or_two = content.split('-', 1)
        ids = tuple(parse_identifier(s) for s in one_or_two)
        if 2 == len(ids):
            return _Range(*ids)
        one, = ids
        return one

    def parse_identifier(content):
        one_or_two = content.split('.', 1)
        tail = None if 1 == len(one_or_two) else one_or_two.pop()
        head, = one_or_two
        return _Identifier(int(head), tail)  # ..

    return parse


class _Range:

    def __init__(self, one, two):
        self._left = one
        self._right = two

    def to_string(self):
        _1 = self._left.to_string_inner()
        _2 = self._right.to_string_inner()
        return f'[#{_1}-{_2}]'


class _Identifier:

    def __init__(self, i, tail):
        self._integer = i
        self._tail = tail

    def to_string(self):
        return f'[#{self.to_string_inner()}]'

    def to_string_inner(self):
        return ''.join(self.__pieces())

    def __pieces(self):
        yield '%03d' % self._integer
        if self._tail is None:
            return
        yield '.'
        yield self._tail

# #born.
