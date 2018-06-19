"""at birth, is an experiment for a particular data producer.

there is an asymmetry: if markdown tables are so special and get their
own format adapter, why not HTML tables too? maybe one day..

it gets coverage by way of #coverpoint12 for now.

also #coverpoint13

perhaps this is vaguely like XSLT..
"""

from sakin_agac import (
        cover_me,
        pop_property,
        )
import sys


class _DictionaryStream_via_Table:

    def __init__(
            self,
            table,
            string_via_td_for_body_row=None,
            string_via_td_for_header_row=None,
            special_field_instructions=None
            ):

        self._rows = self.__make_rows_iterator(table)

        self._far_field_names = _far_field_names_via_first_row(
                next(self._rows),
                (string_via_td_for_header_row or _s_via_td_loosely),
                self._is_proper)

        def f(i):
            far_k = self._far_field_names[i]
            _tup = use_dict[far_k] if far_k in use_dict else default_tup
            return _FormalManifold(near_field_names, far_k, _tup)

        near_field_names = []  # note them along the way yikes
        default_tup = ('string_via_td', string_via_td_for_body_row or _s_via_td_loosely)  # noqa: E501
        use_dict = (special_field_instructions or ())

        _ = tuple(f(i) for i in range(0, len(self._far_field_names)))
        self._manifolder = _RowManifolder(_)
        self.field_names = tuple(near_field_names)

    def __iter__(self):

        for row in self._rows:
            o = self._manifolder()
            tds = row.select('> td')
            for i in range(0, len(tds)):
                o.receive_td(i, tds[i])
            yield o.release_dictionary()

    def __make_rows_iterator(self, table):
        # (since we want to do this as a generator, we can't result
        # in a tuple (or anything). so instead we write a property.
        # hence, we can't break this out cleanly into a function.)

        def trs_via(thead_or_tbody):
            return thead_or_tbody.find_all('tr', recursive=False)

        theads = table.select('> thead')
        tbody, = table.select('> tbody')

        if 0 == len(theads):
            self._is_proper = False
        else:
            self._is_proper = True
            thead, = theads
            for tr in trs_via(thead):
                yield tr
        for tr in trs_via(tbody):
            yield tr


class _RowManifolder:
    """
    makes row manifolds (see)
    """

    def __init__(self, far_cel_formal_manifolds):
        self._far_cel_formal_manifolds = far_cel_formal_manifolds

    def __call__(self):
        return _RowManifold(self._far_cel_formal_manifolds)


class _FormalManifold:
    """
    so:

      - 'rename_to' can be modeled as specialized version of 'split_to'
    """

    def __init__(self, write_near_field_names, far_key, tup_or_dict):

        if isinstance(tup_or_dict, tuple):
            use_dict = {tup_or_dict[0]: tup_or_dict[1:]}  # all have args
        elif isinstance(tup_or_dict, dict):
            cover_me('just a sketch - probably fine')
            use_dict = tup_or_dict
        else:
            _ = 'type error - need tuple or dict, had %s' % type(tup_or_dict)
            raise Exception(_)

        self._string_via_td = _s_via_td_loosely
        self._did_write_near_field_names = False
        self._mutable_near_field_names = write_near_field_names
        self._use_key = far_key
        self._this_one_mutex = None

        for k, tup in use_dict.items():
            _m = _method_name_via_directive[k]
            getattr(self, _m)(* tup)

        if not self._did_write_near_field_names:
            self._write_near_field_names(self._use_key)

        self._this_one_mutex = None
        del(self._this_one_mutex)
        del(self._did_write_near_field_names)
        del(self._mutable_near_field_names)

    def _process_rename_to(self, k):
        del(self._this_one_mutex)
        self._use_key = k
        self._write_near_field_names(k)

    def _process_split_to(self, names, f):
        del(self._this_one_mutex)
        self._write_near_field_names(*names)
        self._did_write_near_field_names = True
        self._RECEIVE_STRING = self._receive_string_when_split
        self._range_for_split = range(0, len(names))
        self._names_for_split = names
        self._function_for_split = f

    def _process_string_via_td(self, f):
        self._string_via_td = f
        pass

    def _write_near_field_names(self, *names):
        for k in names:
            self._mutable_near_field_names.append(k)
        self._did_write_near_field_names = True

    def WRITE_VALUES_NOW(self, dct, td):
        # (this would need to change for aggregate fields)

        s = self._string_via_td(td)
        if 0 != len(s):  # coverpoint [#708.2.4] #[#410.M] where sparseness
            self._RECEIVE_STRING(dct, s)

    def _RECEIVE_STRING(self, dct, s):
        dct[self._use_key] = s

    def _receive_string_when_split(self, dct, split_me):
        values = self._function_for_split(split_me)
        for i in self._range_for_split:
            s = values[i]
            if s is not None:
                dct[self._names_for_split[i]] = s


_method_name_via_directive = {
        'rename_to': '_process_rename_to',
        'split_to': '_process_split_to',
        'string_via_td': '_process_string_via_td',
        }


class _RowManifold:
    """
    is called "manifold" because:

      - like the same-named parts in a car, it can split one thing into
        many things or (maybe one day) aggregate many things into one.

      - we have a specific `release_dictionary` step to leave an upgrade
        path for us to maybe one day do aggregation. (an aggregation can't
        write the output cel until all input cels are in. note that a split
        does not have this constraint, so were it not for the potential want
        of this we would not have a specific such function because the
        cel manifolds would just write to outputs as they encounter each
        far cel value.)

    so:
      - if custom value via td, use that, otherwise use the default
    """

    def __init__(self, far_cel_formal_manifolds):
        self._dict = {}
        self._far_cel_formal_manifolds = far_cel_formal_manifolds

    def receive_td(self, i, td):
        _fm = self._far_cel_formal_manifolds[i]
        _fm.WRITE_VALUES_NOW(self._dict, td)

    def release_dictionary(self):
        return pop_property(self, '_dict')


def _far_field_names_via_first_row(row, s_via_td, is_proper):

    _selector = '> th' if is_proper else '> td'

    def field_via_td(td):
        return normal_field_name_via_string(s_via_td(td))

    from sakin_agac.magnetics import normal_field_name_via_string

    return tuple([field_via_td(td) for td in row.select(_selector)])


def _s_via_td_loosely(td):
    return td.text


def _s_via_td_strictly(td):
    navigable_string, = td.children
    return navigable_string.strip()


sys.modules[__name__] = _DictionaryStream_via_Table

# #born.
