""":[#458.E] record mapping

convert an upstream dictionary stream (a.k.a "JSON stream") to a downstream
where certain transformations are performed on possibly each record in the
collection.

transformations are specified per field name (by far name) using the
supported "directives":

    - rename a field from its far name to its desired near name (`rename_to`)
    - specify how to derive the outputted cel string (`string_via_cel`)
    - split one field into two (or maybe many) (`split_to`)

(hypothetically you could apply multiple directives to one field.
generically this whole mess of fields and their directives is specified
under the "special field instructions".)
"""


def dictionary_via_cells_via_definition(
        unsanitized_far_field_names,
        special_field_instructions,
        string_via_cel):

    near_field_names = []  # note them along the way yikes
    specials = (special_field_instructions or ())
    default_tup = ('string_via_cel', string_via_cel)

    from kiss_rdb import normal_field_name_via_string

    def formal_via(unsanitized_far_field_name):
        far_k = normal_field_name_via_string(unsanitized_far_field_name)
        return _FormalManifold(
                near_field_names,
                specials[far_k] if far_k in specials else default_tup,
                far_k,
                string_via_cel)

    manifolder = _RowManifolder(
            tuple(formal_via(k) for k in unsanitized_far_field_names))

    def dictionary_via_cels(cels):
        i = -1
        o = manifolder()
        for cel in cels:  # 👀
            i += 1
            o.receive_cel(i, cel)
        return o.release_dictionary()

    dictionary_via_cels.near_field_names = tuple(near_field_names)
    return dictionary_via_cels


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

    def __init__(
            self,
            write_near_field_names,
            tup_or_dict,
            far_key,
            string_via_cel,
            ):

        if isinstance(tup_or_dict, tuple):
            use_dict = {tup_or_dict[0]: tup_or_dict[1:]}  # all have args
        elif isinstance(tup_or_dict, dict):
            raise Exception('cover me: just a sketch - probably fine')
            use_dict = tup_or_dict
        else:
            _ = 'type error - need tuple or dict, had %s' % type(tup_or_dict)
            raise Exception(_)

        self._string_via_cel = string_via_cel
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

    def _process_string_via_cel(self, f):
        self._string_via_cel = f
        pass

    def _write_near_field_names(self, *names):
        for k in names:
            self._mutable_near_field_names.append(k)
        self._did_write_near_field_names = True

    def WRITE_VALUES_NOW(self, dct, cel):
        # (this would need to change for aggregate fields)

        s = self._string_via_cel(cel)
        if 0 != len(s):  # (Case2763DP) (test 420) #[#873.5] where sparseness
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
        'string_via_cel': '_process_string_via_cel',
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
      - if custom value via cel, use that, otherwise use the default
    """

    def __init__(self, far_cel_formal_manifolds):
        self._dict = {}
        self._far_cel_formal_manifolds = far_cel_formal_manifolds

    def receive_cel(self, i, cel):
        _fm = self._far_cel_formal_manifolds[i]
        _fm.WRITE_VALUES_NOW(self._dict, cel)

    def release_dictionary(self):
        x = self._dict
        del self._dict
        return x

# #abstracted.
