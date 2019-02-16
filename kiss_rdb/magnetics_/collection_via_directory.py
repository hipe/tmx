from os import path as os_path

"""NOTES

as of file birth, this is a "rumspringa" playground that's mushing together
several different *separate* responsibilities:
  - schema
  - collection
  - "native digits"
"""


class collection_via_directory_and_filesystem:

    def __init__(self, dir_path, fs):
        self._dir_path = dir_path
        self._filesystem = fs

    def delete_entity(self, id_s, listener):
        return _RequestInvolvingIdentifier(
                (),
                _delete_entity,
                id_s,
                self._dir_path,
                self._filesystem,
                listener).execute()


# ==

def _delete_entity(identifier, file_path, filesystem, listener):
    """NOTES: EXPERIMENTALLY:

    with great power comes great responsibility.
      - rewrites of files are realized by sending the "filesystem" a function.
      - the function will receive some pertinent arguments and
      - must result in an iterator that yields each line of the rewritten
        file's target end state
      - (i.e the function *cannot* result in e.g None to indicate e.g failure).
      - (we expect most functions will want to use the `yield` construct
        (becoming an iterator function) but this is user's choice.)
      - if the iterator yields no lines (and again, no errors are emitted),
        this amounts to a request to truncate the file to zero bytes.
      - the function may signal failure at any point during its execution
        by emitting one (or maybe more) `error` into *the provided* listener.
      - the result of the call to the filesystem is True/None indicating
        whether or not the request was fulfilled (determined by inputs
        including but not limited to whether there were any user-generated
        error emissions (the API sketched above)).
    """

    def rewrite(orig_lines, my_listener):
        return _sib_lib().new_lines_via_delete_and_existing_lines(
                identifier.to_string(),
                orig_lines,
                my_listener)

    return filesystem.rewrite_file(rewrite, file_path, listener)


_delete_entity.file_must_already_exist = True


# ==

class _RequestInvolvingIdentifier:
    """NOTES: create. retrieve. update. delete.

    imagine this as a decorator..
    """

    def __init__(self, args, func, id_s, dir_path, fs, listener):
        self._args = args
        self._function = func
        self._identifier_string = id_s
        self._dir_path = dir_path
        self._filesystem = fs  # #testpoint
        self._listener = listener
        self._identifier_depth = 3  # ..; assumed greater than zero!

    def execute(self):
        if not self.__resolve_identifier_via_identifier_string():
            return
        if not self.__check_identifier_depth():
            return
        if not self.__check_for_any_necessary_presence_of_file():
            return
        return self._function(
                *self._args,
                identifier=self._identifier,
                file_path=self._file_path,
                filesystem=self._filesystem,
                listener=self._listener)

    def __check_for_any_necessary_presence_of_file(self):
        pieces = _file_path_pieces_via_identifier(
                self._identifier, self._dir_path)
        self._file_path = os_path.join(*pieces)
        if self._function.file_must_already_exist:
            if os_path.exists(self._file_path):
                return _okay
            else:
                _whine_about_no_path(pieces, self._listener)
                return
        else:
            cover_me('create is the only one')

    def __check_identifier_depth(self):
        length = len(self._identifier.native_digits)
        if self._identifier_depth == length:
            return _okay
        _whine_about_identifier_depth(
                self._identifier, self._identifier_depth, self._listener)

    def __resolve_identifier_via_identifier_string(self):
        tup = _normalize_identifier_in_general(
                self._identifier_string, self._listener)
        if tup is None:
            return
        del(self._identifier_string)
        self._identifier = _Identifier(tup)
        return _okay


# ==

def _file_path_pieces_via_identifier(identifier, dir_path):

    # this will absolutely change when we abstract schema-ism out

    nds = identifier.native_digits
    length = len(nds)
    assert(1 < length)

    # get all but the last component. "ABC" -> "A/B.toml"
    these = [nds[i].character for i in range(0, (length - 1))]

    these[-1] = f'{these[-1]}.toml'

    return (dir_path, 'entities', *these)


def _normalize_identifier_in_general(id_s, listener):

    digits = []

    s_a = tuple(id_s)
    if not len(s_a):
        cover_me('might let this slip thru - needs coverage tho')

    for s in s_a:
        if s in _ID_digit_cache:
            digit = _ID_digit_cache[s]
        else:
            digit = _native_digit_via_character(s, listener)
            if digit is None:
                return  # (Case703)
            _ID_digit_cache[s] = digit
        digits.append(digit)

    return tuple(digits)


_ID_digit_cache = {}  # cache native digits (the mapping btwn char & number)


def _native_digit_via_character(s, listener):
    if s not in _int_via_digit_char:
        __whine_about_bad_digit(s, listener)
        return

    _as_int = _int_via_digit_char[s]

    return _NativeDigit(_as_int, s)


# FOR NOW every time this file is loaded, we're gonna build our thing here

_digits = tuple('23456789ABCDEFGHJKLMNPQRSTUVWXYZ')  # NO: 0, 1, O, I

_num_digits = len(_digits)

assert(32 == _num_digits)

_int_via_digit_char = {_digits[i]: i for i in range(0, _num_digits)}


# ==

class _Identifier:

    def __init__(self, native_digits):
        self.native_digits = native_digits  # assume tuple #wish #[#008.D]

    def to_string(self):
        return ''.join(nd.character for nd in self.native_digits)


class _NativeDigit:

    def __init__(self, as_int, char):
        self.AS_INTEGER = as_int
        self.character = char


# == whiners

def _whine_about_no_path(pieces, listener):
    """given a filesystem path that does not exist, determine the longest

    head of the path that *does*.

    (you could either do deep-to-shallow or shallow-to-deep. tradeoffs each)
    """

    length = len(pieces)
    assert(1 < length)

    num_not_exist = length
    no_ent = os_path.join(*pieces)

    for num in reversed(range(1, length)):
        path = os_path.join(*pieces[0:num])
        if os_path.exists(path):
            break
        no_ent = path
        num_not_exist = num

    if length == num_not_exist:
        reason = f'no such file - {no_ent}'  # (Case706)
    else:
        _ = os_path.join(*pieces[num:])
        reason = f'for {repr(_)}, no such directory - {no_ent}'  # (Case705)

    _emit_input_error_structure(lambda: {'reason': reason}, listener)


def _whine_about_identifier_depth(identifier, expected_length, listener):
    def f():  # (Case704)
        act = len(identifier.native_digits)
        if act < expected_length:
            head = 'not enough'
        elif act > expected_length:
            head = 'too many'
        _id_s = identifier.to_string()
        _reason = (
                f'{head} digits in identifier {repr(_id_s)} - '
                f'need {expected_length}, had {act}'
                )
        return {'reason': _reason}  # ..
    _emit_input_error_structure(f, listener)


def __whine_about_bad_digit(s, listener):
    def f():  # (Case703)
        _reason = (
                f'invalid character {repr(s)} in identifier - '
                'identifier digits must be [0-9A-Z] minus 0, 1, O and I.'
                )
        return {'reason': _reason}
    _emit_input_error_structure(f, listener)


def _emit_input_error_structure(f, listener):
    listener('error', 'structure', 'input_error', f)


def cover_me(msg=None):
    raise Exception('cover me' if msg is None else f'cover me: {msg}')


def _sib_lib():
    from . import file_lines_via_CUD_entity_and_file_lines as _
    return _


_okay = True

# #born.
