import kiss_rdb.magnetics_.items_via_toml_file as trav_lib
from .items_via_toml_file import (
        stop, okay, nothing,
        )


def in_file_attributes_via(id_s, all_lines, listener):

    def actionser(ps):
        def f(name):
            return getattr(actions, name)
        actions = _ActionsforRetrieveWithInFileAttributes(id_s, ps)
        return f

    _ = trav_lib.parse_(all_lines, actionser, listener)

    did_find = False
    for partitions_dct in _:
        did_find = True
        break  # per [#864.provision-3.1] stop at the first one

    if did_find:
        return partitions_dct
    else:
        cover_me()


class _ActionsforRetrieveWithInFileAttributes:

    def __init__(self, id_s, parse_state):
        self._on_section_start = self._on_section_start_while_searching
        self._identifier_string = id_s
        self._ps = parse_state

    def on_section_start(self):
        return self._on_section_start()

    def _on_section_start_while_searching(self):
        o = self._ps
        tup = trav_lib.item_section_line_via_line_(o.line, o.listener)
        if tup is None:
            return stop

        # we are not validating. we are simply waiting for that first section
        # line that is of the right type and a matching ID string

        id_s, which = tup
        if 'attributes' == which:
            if self._identifier_string == id_s:
                self._wahoo_change_modes()
                return nothing
            else:
                return nothing
        elif 'meta' == which:
            return nothing
        else:
            sanity()

    def _wahoo_change_modes(self):
        self._on_section_start = self._on_section_start_while_consuming
        ps = self._ps
        lines_of_interest = [ps.line]

        def f():
            lines_of_interest.append(ps.line)
        ps.on_line_do_this(f)
        self._lines_of_interest = lines_of_interest

    def _on_section_start_while_consuming(self):
        self._lines_of_interest.pop()  # wee
        return self._same_close()

    def at_end_of_input(self):
        cover_me()
        return self._same_close()

    def _same_close(self):
        del self._on_section_start
        x = _big_mondo_vendor_parse(self._lines_of_interest, self._ps.listener)
        if x is None:
            cover_me()
        return (okay, x)


def _big_mondo_vendor_parse(line_list, listener):
    """most of this is validating etc.
    this will expand when we get to [#864.future-feature-1] meta
    """
    import toml
    _big_string = ''.join(line_list)
    # ..
    dct = toml.loads(_big_string)

    item_key, = dct.keys()
    None if 'item' == item_key else sanity()
    item = dct[item_key]
    id_string, = item.keys()
    item_partitions = item[id_string]
    attrs_key, = item_partitions.keys()
    None if 'attributes' == attrs_key else sanity()

    return {
            'identifier_string': id_string,
            'in_file_attributes': item_partitions[attrs_key],
            }


def cover_me():
    raise Exception('cover me')


def sanity():
    raise Exception('sanity')


_ok = True

# #born.
