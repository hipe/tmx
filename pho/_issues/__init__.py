# just messing around

def _build_identifier_parser(listener, cstacker=None):  # #testpoint
    def identifier_via_string(piece):
        def main():
            if parse_any_open_bracket():
                if parse_any_wild_oldschool_markdown_footnote_thing():
                    parse_octothorpe()
                    parse_the_rest_of_the_identifier()
                    parse_wild_oldschool_markdown_footnote_thing_close()
                else:
                    parse_octothorpe()
                    parse_the_rest_of_the_identifier_and_close_bracket()
                    if parse_any_dash():
                        parse_open_bracket()
                        parse_the_rest_of_the_identifier_and_close_bracket()
                parse_end_of_string()
            elif parse_any_octothorpe():
                parse_the_rest_of_the_identifier()
                parse_end_of_string()
            else:
                expecting_open_bracket_or_octothorphe()

        def parse_the_rest_of_the_identifier_and_close_bracket():
            ddd = scn.scan_required(fnetd)
            if not ddd:
                raise stop()
            one_or_two_identifiers[-1][0] = int(ddd)  # #here1
            char = scn.peek(1)
            if ']' == char:
                scn.advance_by_one()
                return
            if '.' != char:
                scn.whine_about_expecting('.')
            scn.advance_by_one()
            if (s := scn.scan(second_component_as_letter)):
                one_or_two_identifiers[-1][1] = (True, s)  # #here2
            elif (s := scn.scan(second_component_as_number)):
                one_or_two_identifiers[-1][1] = (False, s)  # #here2
            else:
                xx("sketched out elaboratedly..")
                scn.whine_about_expecting(
                    second_component_as_letter, second_component_as_number)
            scn.skip_required(close_bracket)

        def parse_the_rest_of_the_identifier():
            xx()

        def parse_any_octothorpe():
            xx()

        def parse_octothorpe():
            scn.skip_required(octothorpe)

        def parse_wild_oldschool_markdown_footnote_thing_close():
            xx()

        def parse_any_wild_oldschool_markdown_footnote_thing():
            if '\\' == scn.peek(1):
                xx()

        def parse_close_bracket():
            xx()

        def parse_any_open_bracket():
            if '[' == scn.peek(1):
                scn.advance_by_one()
                one_or_two_identifiers.append([None, None, True])  # #here1
                return True

        def parse_open_bracket():
            scn.skip_required(open_bracket)
            xx()
            one_or_two_identifiers.append([None, None, True])  # #here1

        def parse_any_dash():
            if scn.empty:
                return
            if '-' == scn.peek(1):
                xx()
                scn.advance_by_one()
                return True

        def parse_end_of_string():
            if scn.empty:
                return
            scn.whine_about_expecting('end of string')

        def expecting_open_bracket_or_octothorphe():
            xx()

        one_or_two_identifiers = []

        def throwing_listener(sev, *rest):
            listener(sev, *rest)
            if 'error' == sev:
                raise stop()

        class stop(RuntimeError):
            pass

        scn = lib.StringScanner(piece, throwing_listener, cstacker)
        try:
            main()
        except stop:
            return
        rang = tuple(_Identifier(*three) for three in one_or_two_identifiers)
        if 1 == len(rang):
            iden, = rang
            return iden
        return _IdentifierRange(*rang)

    import kiss_rdb.magnetics.string_scanner_via_string as lib
    o = lib.pattern_via_description_and_regex_string
    fnetd = o('for now exactly three digits', '[0-9]{3}')
    octothorpe = o('octothorpe', '#')
    open_bracket = o('open bracket', r'\[')
    second_component_as_letter = o('second component', '[A-Z]')
    second_component_as_number = o('second component', '[0-9]{1,2}')
    close_bracket = o('close bracket', r']')

    return identifier_via_string


class _IdentifierRange:

    def __init__(self, one, two):
        self._left = one
        self._right = two

    def to_string(self):
        xx()

    is_range = True


class _Identifier:

    def __init__(self, i, tail_primitive=None, include_bracket=True):  # #here1
        if tail_primitive is None:
            self._sub_component_primitive = None
        else:
            yn, value = tail_primitive  # #here2
            if yn:
                # A => 1, B => 2 ..
                self._sub_component_as_integer = ord(value) - 64
            else:
                value = int(value)
                self._sub_component_as_integer = value
            self._sub_component_primitive = value  # #testpoint (visual)
        self._include_bracket = include_bracket
        self._integer = i  # #testpoint (visual)

    def to_string(self):
        return ''.join(self._to_string_pieces())

    def _to_string_pieces(self):
        if self._include_bracket:
            yield '['
        yield '#'
        yield '%03d' % self._integer
        if self._sub_component_primitive is not None:
            yield '.'
            yield str(self._sub_component_primitive)  # (Case3853)
        if self._include_bracket:
            yield ']'

    def __le__(self, otr):
        return self._compare(otr) in (-1, 0)

    def __lt__(self, otr):
        return -1 == self._compare(otr)

    def __ge__(self, otr):
        return self._compare(otr) in (0, 1)

    def __gt__(self, otr):
        return 1 == self._compare(otr)

    def __ne__(self, otr):
        return 0 != self._compare(otr)

    def __eq__(self, otr):
        return 0 == self._compare(otr)

    def _compare(self, otr):
        assert isinstance(otr, _Identifier)  # ..
        left_int, right_int = self._integer, otr._integer
        if left_int < right_int:
            return -1
        if left_int > right_int:
            return 1
        assert left_int == right_int
        left_has = self._sub_component_primitive is not None
        right_has = otr._sub_component_primitive is not None
        if left_has:
            if right_has:
                left_int = self._sub_component_as_integer
                right_int = otr._sub_component_as_integer
            else:
                return 1
        elif right_has:
            return -1
        else:
            return 0
        if left_int < right_has:
            return -1
        if right_int < left_int:
            return 1
        assert left_int == right_int
        return 0

    is_range = False


def xx(msg=None):
    raise RuntimeError('write me' + ('' if msg is None else f": {msg}"))

# #born.
