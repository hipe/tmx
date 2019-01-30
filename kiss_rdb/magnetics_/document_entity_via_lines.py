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
        lo = mde.PROCURE_LINE_OBJECT(line, listener)
        if lo is None:
            return
        mde.APPEND_LINE_OBJECT(lo)
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

    def INSERT_LINE_OBJECT(self, lo, iid):
        new_iid = self._LL.insert_item_before_item(lo, iid)
        self._accept(new_iid, lo)
        return new_iid

    def APPEND_LINE_OBJECT(self, lo):
        iid = self._LL.append_item(lo)
        self._accept(iid, lo)
        return iid

    def PROCURE_LINE_OBJECT(self, line, listener):
        """DUPLICATES LOGIC IN SIBLING"""

        if '\n' == line:
            return _newline_line_object_singleton
        elif '#' == line[0]:
            return _CommentLine(line)
        else:
            return self.__attribute_line_with_avalable_name(line, listener)

    def __attribute_line_with_avalable_name(self, line, listener):
        """implement attribute line parsing in close concert with the

        document entity so we can check for gist collision at the exact
        "moment" we have the whole identifier string so that if there's a
        collision (signifying a corrupted datastore) we can give
        up-to-the-character context in an error report..
        """

        scn = scn_lib.Scanner(line, listener)

        pieces = []
        stay = True
        while stay:
            s = scn.scan_required(_all_LC_or_UC)
            if s is None:
                return
            pieces.append(s)
            stay = scn.skip(_stacey_dash)

        # mid-parsing of the line we check this so we can get cutesey context
        # this is not thread safe lol
        an = _AttributeName(pieces)
        err = self.__error_structure_for_validate_attribute_name(an, listener)
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

        _the_rest = scn.rest()
        return _AttributeLine(an, _the_rest, line)

    def __error_structure_for_validate_attribute_name(self, an, listener):
        # not thread safe lol
        gist = an.name_gist
        if gist in self._IID_via_gist:
            _iid = self._IID_via_gist[gist]
            _attribute_line = self._LL.item_via_IID(_iid)
            return _build_this_one_error_structure(an, _attribute_line)

    def DELETE_LINE_OBJECT(self, iid):
        lo = self._LL.delete_item(iid)
        if lo.is_attribute_line:
            self._IID_via_gist.pop(lo.to_name_gist())
        return lo

    def _accept(self, iid, lo):
        if lo.is_attribute_line:
            gist = lo.to_name_gist()
            sanity() if gist in self._IID_via_gist else None
            self._IID_via_gist[gist] = iid

    # == READ

    def TO_LINES(self):
        yield self._open_table_line_object.line
        for lo in self._LL.to_item_stream():
            yield lo.line


# -- parsey things used in parsing attribute lines

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
    name0 = attr_name.to_name_string()
    name1 = attribute_line.name_object.to_name_string()
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


class _AttributeLine:

    def __init__(self, attribute_name, remainder_of_line, line):
        # #todo - currently we are ignoring things we will need later
        self.name_object = attribute_name
        self.line = line

    def to_name_gist(self):
        return self.name_object.name_gist

    is_attribute_line = True


class _AttributeName:

    def __init__(self, pieces):
        pieces = tuple(pieces)  # from array [#008.D]
        self.name_gist = ''.join(s.lower() for s in pieces)
        self._pieces = pieces

    def to_name_string(self):
        return '-'.join(self._pieces)


class _CommentLine:

    def __init__(self, line):
        self.line = line

    is_attribute_line = False


class _NewlineLineObjectSingletonImplementation:
    line = '\n'  # ..
    is_attribute_line = False


_newline_line_object_singleton = _NewlineLineObjectSingletonImplementation()


def cover_me():
    raise Exception('cover me')


def sanity():
    raise Exception('sanity')

# #born.
