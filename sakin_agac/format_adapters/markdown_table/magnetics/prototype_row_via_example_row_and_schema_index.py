"""conceptually, the "prototype row" is the thing that makes new rows.

really it's just a function that produces new rows, but we have so-named
it because:

  - it does the "heuristic templating" as touched on in [#408], so the
    name is a better semantic fit, because it "feels" like it's coming
    from a true prototype object (if you're into that sort of thing).

  - the responsibility of this module might expand beyond creating new
    rows. (it may also create merged rows from one existing row and one
    far native object.)



## about alignment

note: we weirdly align the content sub-strings of the cels of the the ASCII
test matrix (table) with the alignment as indicated in the markdown table,
which is all of:
  - out-of-spec
  - purely cosmetic (has no effect on the e.g HTML that is generated)
  - of not-yet-proven cosmetic value at that

but we accidentally mostly implemented it before realizing this (A) and B)
it actually does probably make sense to right-align your ASCII "art" for
right-aligned tables (think numbers).

however, this does not do the "heuristic templating" that it could do here.
(that is, it could try to detect whether the human does in fact (e.g)
right-align the ASCII art for right-aligned columns, and follow suit
accordingbly.)

and come to think of it, center-aligning ASCII art seems like a misfeature.

indeed it's a poor separation of content from presentation. the human should
be able to change the alignment of a column (e.g from `:---` to `---:`) and
have it not change how subsequent machine-generated rows are aligned. meh

#todo the above should be an #open issue
"""

from sakin_agac import (
        cover_me,
        sanity,
        )
import sys


class _SELF:

    def __init__(
            self,
            example_row,
            row_schema_for_alignment,
            schema_index,
            ):

        orig_children = example_row.children

        def f(i):
            _cel_schema = _CelSchema(row_schema_for_alignment.children[i])
            return _celer_via(orig_children[i], _cel_schema)

        tained_example_cel_DOM = orig_children[0]
        tained_example_cel_DOM.content_string()  # be sure it's decomposed
        childreners = _childreners_via(tained_example_cel_DOM)

        _CelDOM = orig_children[0].__class__  # use any child
        _celer_via = _celer_via_via(
                childreners, row_schema_for_alignment, _CelDOM)

        self.__celers = [f(i) for i in range(0, example_row.cels_count)]
        self.__offset_via_field_name = schema_index.offset_via_field_name__
        self.__reuse_newline = orig_children[-1]
        self._RowDOM = example_row.__class__
        self.__cels_count = example_row.cels_count

    def new_via_name_value_pairs(self, pairs):

        new_value_via_offset = self.__new_value_via_offset_via_pairs(pairs)

        def f(i):
            if i in new_value_via_offset:
                return _value_cel(i)
            else:
                return _spaces_cel(i)

        def _value_cel(i):
            _new_value = new_value_via_offset[i]
            _new_STRING = str(_new_value)  # ..
            _new_cel = _celers[i](_new_STRING)
            return _new_cel

        def _spaces_cel(i):  # #coverpoint1.3
            d = _spaces_cel_cache
            if i not in d:
                d[i] = _celers[i]('')
            return d[i]

        _spaces_cel_cache = {}

        _celers = self.__celers

        new_cels = [f(i) for i in range(0, self.__cels_count)]

        new_cels.append(self.__reuse_newline)

        _new_row = self._RowDOM().init_via_children_tuple__(tuple(new_cels))

        return _new_row  # #todo

    def __new_value_via_offset_via_pairs(self, pairs):
        d = self.__offset_via_field_name
        return {d[k]: v for k, v in pairs}  # KeyError #coverpoint1.1


def _celer_via_via(childreners, cel_schema, _CelDOM):

    def _celer_via(tained_example_cel_DOM, cel_schema):

        """a "celer" is a function that makes cels
        """

        def f(new_content_string):
            new_content_w = len(new_content_string)
            total_margin_w = max_content_w - new_content_w
            if total_margin_w < 0:
                # #coverpoint1.4 - content overlflow
                _gen = aligned_children(0, new_content_string)
            else:
                _gen = aligned_children(total_margin_w, new_content_string)

            cx = [reuse_pipe]
            for x in _gen:
                cx.append(x)
            return _CelDOM().init_via_children__(cx)

        tained_example_cel_DOM.content_string()  # ensure decomposed
        tainted_cx = tained_example_cel_DOM.children
        reuse_pipe = tainted_cx[0]

        def w(offset):
            return len(tainted_cx[offset].string_)

        max_content_w = w(1) + w(2) + w(3)  # for #coverpoint.2
        aligned_children = getattr(childreners, cel_schema.alignment)

        return f

    return _celer_via


def _childreners_via(tainted_example_cel_DOM):

    class _childreners:  # namespace only

        def align_left(total_margin_w, new_content_s):  # #coverpoint1.5
            yield _spaces(0)
            yield _fellow(new_content_s)
            yield _spaces(total_margin_w)

        def align_center(total_margin_w, new_content_s):  # #coverpoint1.6
            cover_me('center')
            each_side, was_odd = divmod(total_margin_w, 2)
            yield _spaces(each_side)
            yield _fellow(new_content_s)
            yield _spaces(each_side + was_odd)  # hard coded: prefer left by 1

        def align_right(total_margin_w, new_content_s):  # #coverpoint1.7
            yield _spaces(total_margin_w)
            yield _fellow(new_content_s)
            yield _spaces(0)

        no_alignment_specified = align_left

    def _fellow(new_content_s):
        return _LeafDOM(new_content_s)

    def _spaces(num):
        if num not in _cache:
            _cache[num] = _LeafDOM(' ' * num)
        return _cache[num]

    _cache = {}

    _pipe_meh = tainted_example_cel_DOM.children[0]
    _LeafDOM = _pipe_meh.__class__

    return _childreners


def _CelSchema(cel_DOM):
    """so,

    these:

        :---   left aligned
        :---:  center aligned
         ---:  right aligned
         ---   (it appears this is also left align)
    """
    import re

    s = cel_DOM.content_string()
    md = re.search(r'^(?:(:)|(-))(?:-*(?:(:)|(-)))?$', s)
    if md is None:
        sanity('interesting')

    if md[1] is None:
        if md[3] is None:
            return _cel_schemas.no_alignment_specified
        else:
            cover_me('no colon - yes colon')
    elif md[3] is None:
        cover_me('yes colon - no colon')
    else:
        None if md[2] is None else sanity()
        None if md[4] is None else sanity()
        return _cel_schemas.right_aligned


class _CelSchema_:
    def __init__(self, s):
        self.alignment = s


class _cel_schemas:  # namespace only

    right_aligned = _CelSchema_('align_right')
    no_alignment_specified = _CelSchema_('no_alignment_specified')


sys.modules[__name__] = _SELF

# #born.
