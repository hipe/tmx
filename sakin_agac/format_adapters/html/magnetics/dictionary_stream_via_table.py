"""at birth, is an experiment for a particular data producer.

there is an asymmetry: if markdown tables are so special and get their
own format adapter, why not HTML tables too? maybe one day..

it gets coverage by way of #coverpoint12 for now.
"""


import sys


class _DictionaryStream_via_Table:

    def __init__(
            self,
            table,
            value_via_td_via_field_name=None,
            default_function_for_value_via_td=None,
            value_via_td_for_header_row=None,
            ):

        tbody, = table.select('> tbody')
        self._rows = iter(tbody.find_all('tr', recursive=False))

        _ = (value_via_td_for_header_row or _x_via_td_normally)
        self.field_names = _field_names_via_first_row(next(self._rows), _)

        _ = (default_function_for_value_via_td or _x_via_td_normally)

        self.__init_value_via_td_via_field_name(value_via_td_via_field_name, _)

    def __iter__(self):

        x_via_td_via_k = self._value_via_td_via_field_name
        field_names = self.field_names

        for row in self._rows:
            dct = {}
            tds = row.select('> td')
            for i in range(0, len(tds)):
                k = field_names[i]
                s = x_via_td_via_k[k](tds[i])
                if 0 != len(s):  # coverpoint [#708.2.4]
                    dct[k] = s
            yield dct

    def __init_value_via_td_via_field_name(self, h, x_via_td):

        pool = () if h is None else {k: h[k] for k in h}

        def f(k):
            return pool.pop(k) if k in pool else x_via_td
        self._value_via_td_via_field_name = {k: f(k) for k in self.field_names}
        if 0 != len(pool):
            _ = ', '.join(k for k in pool)
            _ = 'page stucture changed? header(s) not found: (%s)' % _
            raise Exception(_)


def _field_names_via_first_row(row, x_via_td):

    def field_via_td(td):
        return normal_field_name_via_string(x_via_td(td))

    from sakin_agac.magnetics import normal_field_name_via_string

    return tuple([field_via_td(td) for td in row.select('> td')])


def _x_via_td_normally(td):
    return td.content


sys.modules[__name__] = _DictionaryStream_via_Table

# #born.
