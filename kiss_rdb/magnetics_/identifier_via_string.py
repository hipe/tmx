def _CLI(sin, sout, serr, argv):  # :[#867.S]
    """a quick and dirty CLI for visual testing ID encoding/decoding."""

    int_via_id = 'id2int'
    id_via_int = 'int2id'

    # == FROM #history-C.1

    from script_lib.via_usage_line import build_invocation
    invo = build_invocation(
        sin, sout, serr, argv,
        usage_lines=(
            "usage: {{prog_name}} int2id DEPTH INTEGER\n",  # [#857.13]
            "usage: {{prog_name}} id2int IDENTIFIER\n" ),
        docstring_for_help_description=_CLI.__doc__)
    rc, pt = invo.returncode_or_parse_tree()
    if rc is not None:
        return rc

    func, = pt.subcommands
    dct = pt.values
    del pt

    # == TO

    # descend into sub-action

    def listener(*a):
        mood, shape, *ignore, payloader = a
        if 'structure' == shape:
            _ = payloader()['reason']
            serr.write(f'{_}\n')
        elif 'expession' == shape:
            for line in payloader():
                serr.write(f'{line}\n')
        else:
            xx()

    if int_via_id == func:
        arg = dct.pop('identifier')
        assert not dct
        iid = identifier_via_string_(arg, listener)
        if iid is None:
            return 3

        _, int_via_iid, _ = three_via_depth_(iid.number_of_digits)

        _int = int_via_iid(iid)
        serr.write(f'{_int}\n')
        return 0

    if id_via_int == func:
        depth = dct.pop('depth')
        integer = dct.pop('integer')
        assert not dct
        depth = int(depth)  # meh
        integer = int(integer)  # meh

        iid_via_int, _, _ = three_via_depth_(depth)
        _iid = iid_via_int(integer)
        _as_s = _iid.to_string()
        serr.write(f'{_as_s}\n')
        return 0

    assert(False)  # placehold future sub-actions


def three_via_depth_(depth):
    """given depth, produce an encoder function, decoder function, & capacity.

    for both "encoding" an identifier (i.e from integer to string), and for
    "decoding" an identifier string into an integer; these operations are
    straightforward but depend on some terms that are derived from depth
    (which is constant per collection).

    rather than recompute these terms identically for each identifier in
    a collection, it generally makes sense to precompute them only once
    (and when it doesn't make sense, the cost is negligible).

    both encoding and decoding use some of these same derived terms, so
    we produce these functions together.

    "capacity" is simply the max number of entities given depth. used elsewh.

    BUT if you really want the version that doesn't have fixed depth,
    see identifier_via_integer__ and integer_via_identifierer__ below.
    """

    # from depth, derive a bunch of stuff you need to make the functions

    assert(1 < depth)  # or cover me
    least_significant_digit_offset = depth - 1
    significant_digit_offsets = tuple(range(0, least_significant_digit_offset))

    a = []
    for i in significant_digit_offsets:
        a.append(_num_digits ** (least_significant_digit_offset - i))
    multiplier_via_digit_offset = a

    _capacity = _num_digits ** depth

    # define the two functions from all these

    def iid_via_int(integer):

        def ints(use_this):
            for i in significant_digit_offsets:
                quotient, remainder = divmod(
                        use_this, multiplier_via_digit_offset[i])
                yield quotient
                use_this = remainder

            yield use_this

        _ints = ints(integer)
        _chars = (_digits[i] for i in _ints)
        _nd_tup = tuple(native_digit_via_character_(c, None) for c in _chars)
        return Identifier_(_nd_tup)

    def int_via_iid(iid):
        nd_tup = iid.native_digits

        if len(nd_tup) != depth:
            _msg = ('identifier depth mismatch '
                    f'(needed {depth} had {len(nd_tup)})')
            raise Exception(_msg)  # #cover-me (encountered IRL)

        total = nd_tup[least_significant_digit_offset].integer
        for i in significant_digit_offsets:
            total += nd_tup[i].integer * multiplier_via_digit_offset[i]

        return total

    return iid_via_int, int_via_iid, _capacity


def identifier_via_string_(id_s, listener):
    digits = []

    assert isinstance(id_s, str)  # [#022]
    if not len(id_s):
        xx('might let this slip thru - needs coverage tho')

    for s in id_s:
        nd = native_digit_via_character_(s, listener)
        if nd is None:
            return  # (Case4282)
        digits.append(nd)

    return Identifier_(tuple(digits))


func = identifier_via_string_


def identifier_via_integer__(i):  # arbitrary depth, on the fly
    assert(0 <= i)
    big_endian = []
    remaining = i
    while True:
        quotient, remainder = divmod(remaining, _num_digits)
        if quotient:
            big_endian.append(remainder)
            remaining = quotient
            continue
        big_endian.append(remainder)
        break
    little_endian = reversed(big_endian)

    def f(num):
        _digit = _digits[num]  # perhaps not efficient
        return native_digit_via_character_(_digit, None)
    nd_tup = tuple(f(num) for num in little_endian)
    return Identifier_(nd_tup)


class Identifier_:

    def __init__(self, native_digits):
        self.native_digits = native_digits  # assume tuple #wish #[#022]
        self._as_EID = None  # EID = entity identifier (string)

    def __lt__(self, other):  # :#here5
        return self.native_digits < other.native_digits  # (Case4302) and ..

    def __eq__(self, other):  # :#here4
        return self.native_digits == other.native_digits  # (Case4294)

    def to_string(self):
        if self._as_EID is None:
            self._as_EID = ''.join(nd.character for nd in self.native_digits)
        return self._as_EID

    to_primitive = to_string

    @property
    def number_of_digits(self):
        return len(self.native_digits)

    has_depth_ = True


def integer_via_identifier_er__():
    # because we supposedly have arbitrary depth...

    from functools import reduce

    class self:  # #class-as-namespace
        _num_powers = 1

    powers = [1]

    def CALCULATE_MORE_POWERS(depth):
        for i in range(self._num_powers, depth):
            powers.append(_num_digits ** i)
        self._num_powers = depth

    def int_via_iden(iden):
        depth = len(iden.native_digits)
        if self._num_powers < depth:
            CALCULATE_MORE_POWERS(depth)
        depth_minus_one = depth - 1
        nd_tup = iden.native_digits

        def add_me(i):
            return nd_tup[i].integer * powers[depth_minus_one - i]
        return reduce(lambda m, x: m + x, (add_me(i) for i in range(0, depth)))

    return int_via_iden


def native_digit_via_character_(s, listener):

    if s in _ID_digit_cache:
        return _ID_digit_cache[s]

    nd = __build_native_digit_via_character(s, listener)
    if nd is None:
        # (don't cache failure, meh)
        return
    _ID_digit_cache[s] = nd
    return nd


_ID_digit_cache = {}  # cache native digits (the mapping btwn char & number)


def __build_native_digit_via_character(s, listener):
    if s not in _int_via_digit_char:
        __whine_about_bad_digit(s, listener)
        return

    _as_int = _int_via_digit_char[s]

    return _NativeDigit(_as_int, s)


class _NativeDigit:

    def __init__(self, as_int, char):
        self.integer = as_int
        self.character = char

    def __lt__(self, other):  # for #here5
        return self.integer < other.integer

    def __eq__(self, other):
        return self.integer == other.integer  # (Case4294)


# FOR NOW every time this file is loaded, we're gonna build our thing here

_digits = tuple('23456789ABCDEFGHJKLMNPQRSTUVWXYZ')  # NO: 0, 1, O, I

_num_digits = len(_digits)

assert(32 == _num_digits)

_int_via_digit_char = {_digits[i]: i for i in range(0, _num_digits)}


# == whiners

def __whine_about_bad_digit(s, listener):
    def structurer():  # (Case4282)
        reason = (
                f'invalid character {repr(s)} in identifier - '
                'identifier digits must be [0-9A-Z] minus 0, 1, O and I.')
        return {'reason': reason}
    _emit_input_error_structure(structurer, listener)


def _emit_input_error_structure(structurer, listener):
    listener('error', 'structure', 'input_error', structurer)


# ==

def xx(msg=None):
    raise Exception('cover me' if msg is None else f'cover me: {msg}')


if __name__ == '__main__':
    from sys import stdin, stdout, stderr, argv
    exit(_CLI(stdin, stdout, stderr, argv))


# #history-C.1: "engine" not hand-written parser
# #history-A.1: added depth-free encoder/decoder
# #abstracted.
