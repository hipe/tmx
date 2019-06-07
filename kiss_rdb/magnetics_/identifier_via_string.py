def _CLI(sin, sout, serr, argv):  # :[#867.S]
    """a quick and dirty CLI for visual testing ID encoding/decoding."""

    stack = list(reversed(argv))

    # program name and derivaties wee

    long_program_name = stack.pop()

    def pn():
        from os import path as os_path
        res = os_path.basename(long_program_name)
        nonlocal pn

        def pn():
            return res
        return res

    # parse options at head of argv

    did_ask_help = False
    exit_code = 0

    def see_option(token):
        nonlocal did_ask_help
        nonlocal exit_code
        import re
        if re.match('^--?h(?:e(?:lp?)?)?$', token):
            did_ask_help = True
        else:
            serr.write(f"unrecogized option(s): {token}\n")
            exit_code = 1

    def looks_like_option(tok):
        return '-' == tok[0]

    while len(stack) and looks_like_option(stack[-1]):
        see_option(stack.pop())

    def invite(sp=None):
        tail = "see '--help'\n"
        serr.write(tail if sp is None else f'{sp} {tail}')
        return 2

    if exit_code:
        invite()
        return exit_code

    # process actionable options that were at head (just one)

    int_via_id = 'id2int'
    id_via_int = 'int2id'

    exit_ok = 0

    def express_help():
        serr.write('description: ')
        serr.write(_CLI.__doc__)
        serr.write('\n\nusage:\n')
        serr.write(f'    {pn()} {id_via_int} DEPTH INTEGER\n')
        serr.write(f'    {pn()} {int_via_id} IDENTIFIER\n')
        return exit_ok

    if did_ask_help:
        return express_help()

    # descend into sub-action

    def func_np():
        return f"'{id_via_int}' or '{int_via_id}'"

    if not len(stack):
        return invite(f'expecting {func_np()}.')

    func = stack.pop()

    if func not in (int_via_id, id_via_int):
        serr.write(f"unrecognized function '{func}'. ")
        return invite(f'expecting {func_np()}.')

    def listener(*a):
        mood, shape, *ignore, payloader = a
        if 'structure' == shape:
            _ = payloader()['reason']
            serr.write(f'{_}\n')
        elif 'expession' == shape:
            for line in payloader():
                serr.write(f'{line}\n')
        else:
            cover_me()

    if int_via_id == func:
        ln = len(stack)
        if 1 is not ln:
            return invite(f'need 1 had {ln} argument(s) for IDENTIFIER.')
        arg, = stack
        iid = identifier_via_string__(arg, listener)
        if iid is None:
            return 3

        _, int_via_iid, _ = three_via_depth_(len(iid.native_digits))

        _int = int_via_iid(iid)
        serr.write(f'{_int}\n')
        return exit_ok

    if id_via_int == func:
        ln = len(stack)
        if 2 is not ln:
            return invite(f'need 2 had {ln} argument(s) for DEPTH INTEGER.')
        integer, depth = stack  # BACKWARDS! because stack
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


def identifier_via_string__(id_s, listener):

    digits = []

    s_a = tuple(id_s)
    if not len(s_a):
        cover_me('might let this slip thru - needs coverage tho')

    for s in s_a:
        nd = native_digit_via_character_(s, listener)
        if nd is None:
            return  # (Case702)
        digits.append(nd)

    return Identifier_(tuple(digits))


class Identifier_:

    def __init__(self, native_digits):
        self.native_digits = native_digits  # assume tuple #wish #[#008.D]

    def __lt__(self, other):  # :#here5
        return self.native_digits < other.native_digits  # (Case764) and ..

    def __eq__(self, other):  # :#here4
        return self.native_digits == other.native_digits  # (Case712)

    def to_string(self):
        return ''.join(nd.character for nd in self.native_digits)


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
        return self.integer == other.integer  # (Case712)


# FOR NOW every time this file is loaded, we're gonna build our thing here

_digits = tuple('23456789ABCDEFGHJKLMNPQRSTUVWXYZ')  # NO: 0, 1, O, I

_num_digits = len(_digits)

assert(32 == _num_digits)

_int_via_digit_char = {_digits[i]: i for i in range(0, _num_digits)}


# == whiners

def __whine_about_bad_digit(s, listener):
    def f():  # (Case702)
        _reason = (
                f'invalid character {repr(s)} in identifier - '
                'identifier digits must be [0-9A-Z] minus 0, 1, O and I.'
                )
        return {'reason': _reason}
    _emit_input_error_structure(f, listener)


def _emit_input_error_structure(f, listener):
    listener('error', 'structure', 'input_error', f)


# ==

def cover_me(msg=None):
    raise Exception('cover me' if msg is None else f'cover me: {msg}')


if __name__ == '__main__':
    from sys import argv, stdout, stderr
    exit(_CLI(None, stdout, stderr, argv))


# #abstracted.