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
        tup = self._ID_and_path(_file_must_already_exist, id_s, listener)
        if tup is None:
            return
        iid, path = tup

        with self._open_locked_mutable_entities_file(path) as lmef:
            res = _update_entity(lmef, iid, cuds, self._filesystem, listener)

        return res

    # == BEGIN create and delete are more complicated

    def delete_entity(self, id_s, listener):

        # certainly, the entities file must first exist

        # before attempting to lock the index file, see if we can resolve the
        # valid path for the entities file (so we get nicer error message)

        tup = self._ID_and_path(_file_must_already_exist, id_s, listener)
        if tup is None:
            return
        iid, path = tup

        # then after the above, try to get the two locks:

        with self._open_locked_mutable_index() as lmif:
            with self._open_locked_mutable_entities_file(path) as lmef:
                res = _delete_entity(
                        lmef, lmif, iid, self._filesystem, listener)
        return res

    # == END

    def retrieve_entity(self, id_s, listener):
        """NOTICE

        to retrieve one entity; this opens a file, reads some or all of the
        file line-by-line, and then closes it (ALL just for that one entity.)
        o not use this as written if you need to retrieve multiple entities
        in one invocation.. :#here2
        """

        tup = self._ID_and_path(_file_must_already_exist, id_s, listener)
        if tup is None:
            return
        iid, path = tup
        return _retrieve_entity(iid, path, self._filesystem, listener)

    def _ID_and_path(self, file_must_already_exist, id_s, listener):

        id_obj = self._depthly_valid_identifier_via_string(id_s, listener)
        if id_obj is None:
            return

        file_path = _valid_path_for(
                id_obj, file_must_already_exist, self._dir_path, listener)
        if file_path is None:
            return

        return id_obj, file_path

    def _open_locked_mutable_index(self):
        _ = os_path.join(self._dir_path, '.entity-index.txt')
        return self._filesystem.open_locked_file(_)

    def _open_locked_mutable_entities_file(self, path):
        return self._filesystem.open_locked_file(path)

    def to_identifier_stream(self, listener):
        from .entities_via_collection import identifiers_via_collection as _
        return _(self._dir_path, self._depthly_valid_identifier_via_string, listener)  # noqa: E501


# ==


def _update_entity(locked_ents_file, identifier, cuds, fs, listener):

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

    def rewrite_ents_file(orig_lines, my_listener):
        return _sib_lib().new_lines_via_update_and_existing_lines(
                identifier.to_string(),
                new_lines_via_entity,
                orig_lines,
                my_listener)

    with fs.FILE_REWRITE_TRANSACTION(listener) as trans:
        trans.rewrite_file(locked_ents_file, rewrite_ents_file)
        res = trans.finish()

    return res


def _delete_entity(locked_ents_file, locked_index_file, identifier, fs, listener):  # noqa: E501

    def rewrite_ents_file(orig_lines, my_listener):
        return _sib_lib().new_lines_via_delete_and_existing_lines(
                identifier.to_string(),
                orig_lines,
                my_listener)

    def rewrite_index_file(orig_lines, my_listener):

        # (although the index file is written tree-like, we search for
        # the guy to delete in an inefficient way, because we don't care
        # about the efficiency of deletes right now.)

        from .identifiers_via_index import (
                identifiers_via_lines_of_index as _)
        itr = _(orig_lines)
        keep_iids = []
        did_find = False
        count_for_debug = 0

        # find the IID you want to delete (traversal search yikes!)

        for this_iid in itr:
            if identifier == this_iid:  # #here4
                did_find = True
                break
            count_for_debug += 1
            keep_iids.append(this_iid)

        if not did_find:
            cover_me(_say_integrity_error(identifier, count_for_debug))

        # pass-thru any remaining IID's after the one you found

        for this_iid in itr:
            keep_iids.append(this_iid)

        # death if there wasn't at least one :(

        _depth = len(this_iid.native_digits)

        from .index_via_identifiers import (
            lines_of_index_via_identifiers as _)

        return _(keep_iids, _depth)

    with fs.FILE_REWRITE_TRANSACTION(listener) as trans:
        # (per [#867.Q] do index file second)
        trans.rewrite_file(locked_ents_file, rewrite_ents_file)
        trans.rewrite_file(locked_index_file, rewrite_index_file)
        res = trans.finish()

    return res


def _retrieve_entity(identifier, file_path, filesystem, listener):
    """DISCUSSION

    - the founding purpose of the "collection" idiom was to centralize
      operations that mutate the file (CUD).
    - but it seems to make sense to expose also the read-only verb (R in CRUD)
    - the "filesystem" argument is only for injecting a spy. we do not bother
      with the extra complexity of injecting spies when doing read-only on FS.
    - see #here2 about gross inefficiency in calling this multiple times.
    """

    from .entity_via_identifier_and_file_lines import (
            entity_via_identifier_and_file_lines as MDE_via,
            entity_dict_via_entity_big_string__ as dict_via,
            )

    id_s = identifier.to_string()

    with open(file_path) as lines:  # file existed last we checked #here1
        mde = MDE_via(id_s, lines, listener)

    if mde is None:
        return  # (Case710)

    # (Case711):

    assert(mde.table_type == 'attributes')
    assert(mde.identifier_string == id_s)

    _big_string = ''.join(mde.to_line_stream())

    return dict_via(_big_string, listener)


# == individual identifier stuff

def _valid_path_for(identifier, file_must_already_exist, dir_path, listener):
    pieces = __file_path_pieces_via_identifier(identifier, dir_path)
    file_path = os_path.join(*pieces)
    if file_must_already_exist:
        if os_path.exists(file_path):  # :#here1
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
            return  # (Case702)
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

    def __eq__(self, other):  # :#here4
        return self.native_digits == other.native_digits  # (Case712)

    def to_string(self):
        return ''.join(nd.character for nd in self.native_digits)


class _NativeDigit:

    def __init__(self, as_int, char):
        self.integer = as_int
        self.character = char

    def __eq__(self, other):
        return self.integer == other.integer  # (Case712)


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
        reason = f'no such file - {no_ent}'  # (Case704)
    else:
        _ = os_path.join(*pieces[num:])
        reason = f'for {repr(_)}, no such directory - {no_ent}'  # (Case703)

    _emit_input_error_structure(lambda: {'reason': reason}, listener)


def _whine_about_ID_depth(identifier, expected_length, listener):
    def f():  # (Case703)
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
    def f():  # (Case702)
        _reason = (
                f'invalid character {repr(s)} in identifier - '
                'identifier digits must be [0-9A-Z] minus 0, 1, O and I.'
                )
        return {'reason': _reason}
    _emit_input_error_structure(f, listener)


def _say_integrity_error(identifier, count_for_debug):
    return (
        f'integrity error: did not find {identifier.to_string()}'
        f' in {count_for_debug}')


def _emit_input_error_structure(f, listener):
    listener('error', 'structure', 'input_error', f)


def cover_me(msg=None):
    raise Exception('cover me' if msg is None else f'cover me: {msg}')


def _sib_lib():
    from . import file_lines_via_CUD_entity_and_file_lines as _
    return _


_file_must_already_exist = True

_okay = True

# #born.
