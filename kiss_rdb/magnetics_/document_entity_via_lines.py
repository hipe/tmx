from . import (
        string_scanner_via_definition as scn_lib,
        )


def mutable_document_entity_via_lines(
        lines, identifier_string, table_type, listener):

    otl = _open_table_line_via(identifier_string, table_type, listener)
    if otl is None:
        return

    mde = _MutableDocumentEntity(otl)
    for line in lines:
        lo = mde.procure_line_object__(line, listener)
        if lo is None:
            return
        mde.append_line_object(lo)
    return mde


class _MutableDocumentEntity:
    """
    we follow the double responsibility principle:

    1) expose a mutable list API that the operations can layer on top of.
    the operations are concerned with things like ensuring that the lines
    adjacent to edited lines are not comments. we do not effectuate such
    assurances here but we make them possible with the API we expose.

    2) gist API. help prevent gist collisions, with procurement. in flux. #todo
    """

    def __init__(self, open_table_line_object):

        from . import doubly_linked_list_functions as _
        self._LL = _.build_new_doubly_linked_list()

        self._open_table_line_object = open_table_line_object
        self._IID_via_gist = {}

    def insert_line_object(self, lo, iid):
        new_iid = self._LL.insert_item_before_item(lo, iid)
        self._accept(new_iid, lo)
        return new_iid

    def append_line_object(self, lo):
        iid = self._LL.append_item(lo)
        self._accept(iid, lo)
        return iid

    def replace_line_object__(self, lo):
        _iid = self._IID_via_gist[lo.attribute_name.name_gist]
        return self._LL.replace_item(_iid, lo)

    def procure_line_object__(self, line, listener):  # #testpoint
        """DUPLICATES LOGIC IN SIBLING"""

        if '\n' == line:
            return newline_line_object_singleton
        elif '#' == line[0]:
            return _CommentLine(line)
        else:
            return attribute_line_via_line(
                    line,
                    listener,
                    self.__error_structure_for_validate_attribute_name)

    def __error_structure_for_validate_attribute_name(self, an):
        # not thread safe lol

        al = self.any_attribute_line_via_gist(an.name_gist)
        if al is not None:
            return _build_this_one_error_structure(an, al)

    def delete_attribute_line_object_via_gist__(self, gist):
        return self._delete_line_object_via_iid(self._IID_via_gist[gist])

    def _delete_line_object_via_iid(self, iid):  # #testpoint
        lo = self._LL.delete_item(iid)
        if lo.is_attribute_line:
            self._IID_via_gist.pop(lo.to_name_gist())
        return lo

    def _accept(self, iid, lo):
        if lo.is_attribute_line:
            gist = lo.to_name_gist()
            assert(gist not in self._IID_via_gist)
            self._IID_via_gist[gist] = iid

    # == READ

    def TO_LINES(self):
        yield self._open_table_line_object.line
        for lo in self.TO_BODY_LINE_OBJECT_STREAM():
            yield lo.line

    def any_attribute_line_via_gist(self, gist):
        if gist in self._IID_via_gist:
            return self._LL.item_via_IID(self._IID_via_gist[gist])

    def TO_BODY_LINE_OBJECT_STREAM(self):
        return self._LL.to_item_stream()


# -- parsey things used in parsing attribute lines


def _nah(_):
    pass


def attribute_line_via_line(line, listener, input_error_structure_via_AN=_nah):
    """with the optional argument the client can for example check for gist

    collision and emit an error at the exact "moment" when it happened
    so that the UI can point to the exact character in the input string
    where it happened.
    """

    scn = scn_lib.Scanner(line, listener)
    an = _parse_attribute_name_passively(scn)
    if an is None:
        return

    # mid-parsing of the line we check this so we can get cutesey context
    # this is not thread safe lol
    err = input_error_structure_via_AN(an)
    if err is not None:
        scn.MUTATE_ERROR_STRUCTURE(err)
        listener('error', 'structure', 'input_error', lambda: err)
        return

    if not scn.skip_required(_exactly_one_space):
        return
    if not scn.skip_required(_equals_sign):
        return
    if not scn.skip_required(_exactly_one_space):
        return
    if scn.eos():
        cover_me()

    return _AttributeLine(an, scn.pos(), line)


def attribute_name_via_string(attr_name, listener):
    # this pains us
    scn = scn_lib.Scanner(attr_name, listener)
    pieces = []
    while True:
        s = scn.scan_required(_all_LC_or_UC)
        if s is None:
            return
        pieces.append(s)
        if scn.eos():
            break
        if not scn.skip_required(_stacey_dash):
            return
    return _AttributeName(pieces)


def _parse_attribute_name_passively(scn):
    pieces = []
    stay = True
    while stay:
        s = scn.scan_required(_all_LC_or_UC)
        if s is None:
            return
        pieces.append(s)
        stay = scn.skip(_stacey_dash)
    return _AttributeName(pieces)


o = scn_lib.pattern_via_description_and_regex_string
_all_LC_or_UC = o(
    'all lowercase or all uppercase attribute name piece',
    r'[a-z0-9]+|[A-Z0-9]+')
_stacey_dash = o('dash', '-')
_exactly_one_space = o('exactly one space', ' ')
_equals_sign = o('equals sign', '=')
del(o)


# -- keep crunchy noise out of class body


def _build_this_one_error_structure(attr_name, attribute_line):
    name0 = attr_name.name_string
    name1 = attribute_line.attribute_name.name_string
    return {
            'reason': (
                f'new name {repr(name1)} too similar to '
                f'existing name {repr(name0)}'),
            'expecting': 'available name',
            }


# == LINE OBJECT CLASSES


def _open_table_line_via(identifier_string, table_type, listener):

    if 'attributes' == table_type:
        pass
    elif 'meta' == table_type:
        pass
    else:
        cover_me()

    # no validation of identifier string for now
    # a sibling file does something near this

    _line = f'[item.{identifier_string}.{table_type}]\n'

    return _OpenTableLine(identifier_string, table_type, _line)


class _OpenTableLine:

    def __init__(self, id_s, typ, line):
        self.line = line
        # ..


class _AttributeLine:  # #testpoint

    def __init__(self, attribute_name, value_position, line):
        self.position_of_start_of_value = value_position
        self.attribute_name = attribute_name
        self.line = line

    def to_name_gist(self):
        return self.attribute_name.name_gist

    is_attribute_line = True
    is_comment_line = False


class _AttributeName:

    def __init__(self, pieces):
        self.name_gist = ''.join(s.lower() for s in pieces)
        self.name_string = '-'.join(pieces)


class _CommentLine:

    def __init__(self, line):
        self.line = line

    is_attribute_line = False
    is_comment_line = True


class _NewlineLineObjectSingletonImplementation:
    line = '\n'  # ..
    is_attribute_line = False
    is_comment_line = False


newline_line_object_singleton = _NewlineLineObjectSingletonImplementation()


def cover_me():
    raise Exception('cover me')

# #born.
