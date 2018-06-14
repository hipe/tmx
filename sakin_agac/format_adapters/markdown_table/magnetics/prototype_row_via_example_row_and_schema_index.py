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
            natural_key_field_name,
            example_row,
            complete_schema,
            ):

        orig_children = example_row.children
        self._eg_endcap = example_row.any_endcap_()

        def f(i):
            _cel_schema = _cel_schema_via(row_schema_for_alignment.children[i])
            return _celer_via(orig_children[i], _cel_schema)

        row_schema_for_alignment = complete_schema.row_for_alignment__

        tainted_example_cel_DOM = orig_children[0]
        tainted_example_cel_DOM.content_string()  # be sure it's decomposed
        childreners = _childreners_via(tainted_example_cel_DOM)

        _CelDOM = orig_children[0].__class__  # use any child
        _celer_via = _celer_via_via(
                childreners, row_schema_for_alignment, _CelDOM)

        self._celers = [f(i) for i in range(0, example_row.cels_count)]
        self._offset_via_field_name = complete_schema.offset_via_field_name__
        self.__reuse_newline = orig_children[-1]
        self._RowDOM = example_row.__class__
        self._cels_count = example_row.cels_count
        self._natural_key_field_name = natural_key_field_name

    def MERGE(self, pairs, near_row_DOM):
        """for each key-value in the far pairs, make the new cel.

        for all the rest, use the doo-hah that was there already!
        """

        """assume the human key in the far pairs has the same effective
        value as that in the near row. no reason to incur the "cost"
        of updating this value, so delete that item from the dictionary.
        """

        value_via_name = {k: v for k, v in pairs}
        value_via_name.pop(self._natural_key_field_name)

        # instead of value via key, we want value via offset.

        offset_via_name = self._offset_via_field_name
        new_value_via_offset = {offset_via_name[k]: value_via_name[k] for k in value_via_name}  # KeyError #coverpoint1.1 (1/2)  # noqa: E501

        if 0 == len(new_value_via_offset):
            # #coverpoint4.1
            # if there's no actual values you want to sync, it's a no-op
            return near_row_DOM  # (#not-SESE) you can't max below.

        # make a reader function for producing near cels from offsets

        def near_f(i):
            return near_children[i]
        near_children = near_row_DOM.children

        """the rub: the goal is to have the "correct" end-cappiness.
        what we mean by "correct" depends:
        is the near row's length being "pushed outwards" by having new
        right-anchored cels being added to it that it didn't have before?
        then you use the end-cappiness of the prototype.
        otherwise (and its number of cels is staying the same),
        preserve the existing end-cappiness.
        """

        far_max_offset = max(new_value_via_offset.keys())
        near_max_offset = near_row_DOM.cels_count - 1

        near_row_any_endcap = near_row_DOM.any_endcap_()

        if near_max_offset < far_max_offset:
            use_endcap = self._eg_endcap  # #coverpoint5.5
        else:
            use_endcap = near_row_any_endcap  # #coverpoint5.4

        return self._build_new_row(near_f, new_value_via_offset, use_endcap)

    def new_via_name_value_pairs(self, pairs):
        """for each key-value in the far pairs, make the new cel.

        for all the rest, make them blank cels.
        """

        def spaces_cel(i):  # #coverpoint1.3
            d = _spaces_cel_cache
            if i not in d:
                d[i] = _celers[i]('')
            return d[i]

        _celers = self._celers

        _spaces_cel_cache = {}

        offset = self._offset_via_field_name
        _nvvo = {offset[k]: v for k, v in pairs}  # KeyError #coverpoint1.1

        return self._build_new_row(spaces_cel, _nvvo, self._eg_endcap)

    def _build_new_row(self, user_f, new_value_via_offset, near_row_endcap):

        new_cels = self.__build_new_cels(user_f, new_value_via_offset)

        has = self.__write_any_endcap(new_cels, near_row_endcap)

        new_cels.append(self.__reuse_newline)  # always add a newline

        _new_row = self._RowDOM().init_via_all_memberdata__(
            cels_count=self._cels_count,
            children=tuple(new_cels),
            has_endcap=has,
            )

        return _new_row  # #todo

    def __build_new_cels(self, user_f, new_value_via_offset):

        def new_cel_for(i):
            if i in new_value_via_offset:
                return value_cel(i)
            else:
                return user_f(i)

        value_cel = self.__value_celer(new_value_via_offset)

        _new_cels = [new_cel_for(i) for i in range(0, self._cels_count)]
        return _new_cels  # #todo

    def __value_celer(self, new_value_via_offset):

        def _value_cel(i):
            _new_value = new_value_via_offset[i]
            _new_STRING = str(_new_value)  # ..
            _new_cel = _celers[i](_new_STRING)
            return _new_cel

        _celers = self._celers

        return _value_cel

    def __write_any_endcap(self, new_cels, near_row_endcap):

        if near_row_endcap is None:
            has = False
        else:
            new_cels.append(near_row_endcap)
            has = True
        return has



def _celer_via_via(childreners, cel_schema, _CelDOM):

    def _celer_via(tainted_example_cel_DOM, cel_schema):

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

        tainted_example_cel_DOM.content_string()  # ensure decomposed
        tainted_cx = tainted_example_cel_DOM.children
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


def _cel_schema_via(cel_DOM):
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
            # #coverpoint4.1 - no colon - yes colon
            return _cel_schemas.right_aligned
    elif md[3] is None:
        # #coverpoint4.2 - yes colon - no colon
        return _cel_schemas.left_aligned
    else:
        None if md[2] is None else sanity()
        None if md[4] is None else sanity()
        return _cel_schemas.right_aligned


class _CelSchema:
    def __init__(self, s):
        self.alignment = s


class _cel_schemas:  # namespace only

    left_aligned = _CelSchema('align_left')
    right_aligned = _CelSchema('align_right')
    no_alignment_specified = _CelSchema('no_alignment_specified')


sys.modules[__name__] = _SELF

# #history-A.1: sneak merge into here to be alongside create new
# #born.
