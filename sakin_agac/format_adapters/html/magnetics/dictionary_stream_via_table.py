"""at birth, is an experiment for a particular data producer.

there is an asymmetry: if markdown tables are so special and get their
own format adapter, why not HTML tables too? maybe one day..

it gets coverage by way of #coverpoint12 for now.

also #coverpoint13

at #history-A.1 a big chunk of it is abstracted out to be not format-specific.

perhaps this is vaguely like XSLT..
"""


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

        _unsanitized_far_field_names = _unsanitized_far_field_names_via_first_row(  # noqa: E501
                next(self._rows),
                (string_via_td_for_header_row or _s_via_td_loosely),
                self._is_proper)

        _string_via_cel = (string_via_td_for_body_row or _s_via_td_loosely)

        import sakin_agac.magnetics.dictionary_via_cels_via_definition as _

        f = _(
                unsanitized_far_field_names=_unsanitized_far_field_names,
                special_field_instructions=special_field_instructions,
                string_via_cel=_string_via_cel,
                )

        self.field_names = f.near_field_names
        self._dictionary_via_cels = f
        self._mutex = None

    def __iter__(self):
        del(self._mutex)
        dictionary_via_cels = self._dictionary_via_cels

        def dictionary_via_row(row):
            _tds = _filter('td', row)
            return dictionary_via_cels(_tds)
        return (dictionary_via_row(row) for row in self._rows)

    def __make_rows_iterator(self, table):
        # (since we want to do this as a generator, we can't result
        # in a tuple (or anything). so instead we write a property.
        # hence, we can't break this out cleanly into a function.)

        def trs_via(thead_or_tbody):
            return thead_or_tbody.find_all('tr', recursive=False)

        theads = _filter('thead', table)
        tbody, = _filter('tbody', table)

        if 0 == len(theads):
            self._is_proper = False
        else:
            self._is_proper = True
            thead, = theads
            for tr in trs_via(thead):
                yield tr
        for tr in trs_via(tbody):
            yield tr


def _unsanitized_far_field_names_via_first_row(row, s_via_td, is_proper):
    _selector = 'th' if is_proper else 'td'
    return tuple(s_via_td(td) for td in _filter(_selector, row))


def _s_via_td_loosely(td):
    return td.text


def _s_via_td_strictly(td):
    navigable_string, = td.children
    return navigable_string.strip()


def _filter(sel, el):
    # at #history-A.1 BeautifulSoup changed
    import soupsieve as sv
    return sv.filter(sel, el)


sys.modules[__name__] = _DictionaryStream_via_Table

# #history-A.2: as referenced
# #history-A.1: a big chunk of it abstracted out to be not format specific
# #born.
