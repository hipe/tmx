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
        identifier_depth = 3  # #open #[#867.K]

        def f(id_s, listener):
            id_obj = _identifier_via_string(id_s, listener)
            if id_obj is None:
                return
            length = len(id_obj.native_digits)
            if identifier_depth != length:
                _whine_about_ID_depth(id_obj, identifier_depth, listener)
                return
            return id_obj
        self._depthly_valid_identifier_via_string = f
        self._dir_path = dir_path
        self._filesystem = fs

    def update_entity(self, id_s, cuds, listener):
        return self._CUD(
                (cuds,),
                _update_entity,
                id_s,
                listener)

    def delete_entity(self, id_s, listener):
        return self._CUD(
                (),
                _delete_entity,
                id_s,
                listener)

    def _CUD(self, args, func, id_s, listener):

        id_obj = self._depthly_valid_identifier_via_string(id_s, listener)
        if id_obj is None:
            return

        file_path = _valid_path_for(id_obj, func, self._dir_path, listener)
        if file_path is None:
            return

        return func(
                *args,
                identifier=id_obj,
                file_path=file_path,
                filesystem=self._filesystem,
                listener=listener)

    def to_identifier_stream(self, listener):
        from .entities_via_collection import identifiers_via_collection as _
        return _(self._dir_path, self._depthly_valid_identifier_via_string, listener)  # noqa: E501


# ==

def _update_entity(cuds, identifier, file_path, filesystem, listener):
    # (see `_delete_entity` below for high-level explanation of interface)

    def new_lines_via_entity(mde, my_listener):
        # unlike both CREATE and DELETE, UPDATE determines its modified entity
        # lines *as a function of* the existing entity, so more complicated.

        from .CUD_attributes_request_via_tuples import request_via_tuples as _
        req = _(cuds, my_listener)
        if req is None:
            return  # not covered - blind faith

        _ok = req.edit_mutable_document_entity__(mde, my_listener)

        if not _ok:
            return  # not covered - blind faith

        return tuple(mde.to_line_stream())

    def rewrite(orig_lines, my_listener):
        return _sib_lib().new_lines_via_update_and_existing_lines(
                identifier.to_string(),
                new_lines_via_entity,
                orig_lines,
                my_listener)

    return filesystem.rewrite_file(rewrite, file_path, listener)


_update_entity.file_must_already_exist = True


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
      - the function may signal failure at any point during its execution
        by emitting one (or maybe more) `error` into *the provided* listener.
      - if the iterator yields no lines (and no errors are emitted),
        this amounts to a request to truncate the file to zero bytes.
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


# == individual identifier stuff

def _valid_path_for(identifier, func, dir_path, listener):
    pieces = __file_path_pieces_via_identifier(identifier, dir_path)
    file_path = os_path.join(*pieces)
    if func.file_must_already_exist:
        if os_path.exists(file_path):
            return file_path
        else:
            __whine_about_no_path(pieces, listener)
            return
    else:
        cover_me('create is the only one')


def __file_path_pieces_via_identifier(identifier, dir_path):

    # this will absolutely change when we abstract schema-ism out

    nds = identifier.native_digits
    length = len(nds)
    assert(1 < length)

    # get all but the last component. "ABC" -> "A/B.toml"
    these = [nds[i].character for i in range(0, (length - 1))]

    these[-1] = f'{these[-1]}.toml'

    return (dir_path, 'entities', *these)


def _identifier_via_string(id_s, listener):

    digits = []

    s_a = tuple(id_s)
    if not len(s_a):
        cover_me('might let this slip thru - needs coverage tho')

    for s in s_a:
        nd = native_digit_via_character_(s, listener)
        if nd is None:
            return  # (Case703)
        digits.append(nd)

    return Identifier_(tuple(digits))


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


# FOR NOW every time this file is loaded, we're gonna build our thing here

_digits = tuple('23456789ABCDEFGHJKLMNPQRSTUVWXYZ')  # NO: 0, 1, O, I

_num_digits = len(_digits)

assert(32 == _num_digits)

_int_via_digit_char = {_digits[i]: i for i in range(0, _num_digits)}


# ==

class Identifier_:

    def __init__(self, native_digits):
        self.native_digits = native_digits  # assume tuple #wish #[#008.D]

    def to_string(self):
        return ''.join(nd.character for nd in self.native_digits)


class _NativeDigit:

    def __init__(self, as_int, char):
        self.integer = as_int
        self.character = char


# == whiners

def __whine_about_no_path(pieces, listener):
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


def _whine_about_ID_depth(identifier, expected_length, listener):
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
