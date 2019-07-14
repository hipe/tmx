"""conceptually, the "prototype row" is the thing that makes new rows.

really it's just a function that produces new rows, but we have so-named
it because:

  - it does the [#458.3] "heuristic templating", so the
    name is a better semantic fit, because it "feels" like it's coming
    from a true prototype object (if you're into that sort of thing).

  - the responsibility of this module might expand beyond creating new
    rows. (it may also create merged rows from one existing row and one
    far native object.)



## about alignment

(the below is covered near (Case2478KR) and (Case2479KR)

our policy on alignment is guided by one central design objective: when
bringing in new data (through a sync), format things the way the user wants.
as it turns out, this is not as straightforward as it may sound:

when the new content string is of a different width than the old one (and
even when it is the same width as the old one),

  - do we simply re-use the padding characters ("coddling") from before?
  - do we try to keep the width of the cel the same?
  - or do we try to make the width of the cel match the example row?
  - wat do when the new content string makes the resulting cel so wide
    that it violates any of the above provisions that you might have?

we assume users may want to "normalize" their formatting to some latest and
greatest conventional formatting so that the rows generally line up prettily.
(we arrived at this heuristically.) as such we follow the third option above,
and when (4) we just let the content push the cel outwards infinitely. (data
producers can of course always trim their own value strings, too.)

but then that's not all. whenever the content string changes width, or the
target width of the cel changes; we're typically adding or removing
"coddling" spaces (padding).

(this is where the right description of our wrong behavior begins.)

currently we weirdly align the content strings within the cels by align
left, center ("") or right as indicated in the markdown table header,
which is all of:
  - purely cosmetic (has no effect on the e.g HTML that is generated)
  - of not-yet-proven cosmetic value at that

but we accidentally mostly implemented it before realizing this (A) and B)
it actually does probably make sense to right-align your ASCII "art" for
right-aligned tables (think numbers).

however, this does not do the [#458.3] "heuristic templating" that it could
do here.
(that is, it could try to detect whether the human does in fact (e.g)
right-align the ASCII art for right-aligned columns, and follow suit
accordingbly.)

and come to think of it, center-aligning ASCII art seems like a misfeature.

indeed it's a poor separation of content from presentation. the human should
be able to change the alignment of a column (e.g from `:---` to `---:`) and
have it not change how subsequent machine-generated rows are aligned. meh

((Case4075) is used formally to connect this magnet with its test file)
"""

from sakin_agac import (
        cover_me,
        )
import sys


_do_shrink_to_fit_hack = False
"""
these are temporary notes towars a possible solution to #open [#418.S]:
  - the above turns on an experimental behavior that seems likely to become
    default. it's towards a possible answer to [#410.S].
  - at #history-A.3 we turned this on and used it to commit the generated
    document (accompanied in the commit).
  - (if you're going to try to use it again hackily you will have to comment
    out a cover.me added below, too.)
  - but this is far from integrated. we need dedicated design time to consider
    what the ideal alignment policy should be.
  - we are imagining a policy like this: `#eg`, `#eg `, ` #eg `, and ` #eg`
    would express the four possible options for fixed-width policy (with the
    leftmost being "shrink to fit" and the other 3 expressing the 3 kinds of
    fixed-width alignment that existed when we got here). (the fact that
    we chose tag-looking strings here is not meaningful.)
  - note the above stands in contrast to the current way where we using
    `---`, `:---`, `:---:` and `---:` to determine a fixed-width policy.
    this is now deemed squarely a smell because the way you want your HTML
    rendered should be orthogonal to whether you want to follow fixed-
    widthisms in your ASCII art.
  - (note too it would never make sense to have fixed-width columns unless
    they are head-anchored and contiguous, in terms of their left-to-right
    order as columns in the markdown table.)
"""


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

    def new_row_via_far_pairs_and_near_row_DOM__(self, far_pairs, near_row_DOM):  # noqa: E501 #testpoint
        """for each key-value in the far pairs, make the new cel.

        for all the rest, use the doo-hah that was there already!
        """

        """assume the human key in the far pairs has the same effective
        value as that in the near row. no reason to incur the "cost"
        of updating this value, so delete that item from the dictionary.
        """

        # (before #history-A.2 we use to do (Case0150DP) here)

        # instead of value via key, we want value via offset.

        offset_via_name = self._offset_via_field_name
        new_value_via_offset = {offset_via_name[k]: v for k, v in far_pairs}
        # KeyError (Case0110DP) (1/2)

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
            use_endcap = self._eg_endcap  # (Case2667DP)
        else:
            use_endcap = near_row_any_endcap  # (Case2665DP)

        return self._build_new_row(near_f, new_value_via_offset, use_endcap)

    def new_via_normal_dictionary(self, far_dict):
        """for each key-value in the far pairs, make the new cel.

        for all the rest, make them blank cels.
        """

        def spaces_cel(i):  # (Case0130DP)
            d = _spaces_cel_cache
            if i not in d:
                d[i] = _celers[i]('')
            return d[i]

        _celers = self._celers

        _spaces_cel_cache = {}

        offset = self._offset_via_field_name
        _nvvo = {offset[k]: v for k, v in far_dict.items()}
        # KeyError (Case0110DP) (2/2)

        return self._build_new_row(spaces_cel, _nvvo, self._eg_endcap)

    def _build_new_row(self, user_f, new_value_via_offset, near_row_endcap):

        new_cels = self.__build_new_cels(user_f, new_value_via_offset)

        has = self.__write_any_endcap(new_cels, near_row_endcap)

        new_cels.append(self.__reuse_newline)  # always add a newline

        return self._RowDOM().init_via_all_memberdata__(
            cels_count=self._cels_count,
            children=tuple(new_cels),
            has_endcap=has,
            )

    def __build_new_cels(self, user_f, new_value_via_offset):

        def new_cel_for(i):
            if i in new_value_via_offset:
                return value_cel(i)
            else:
                return user_f(i)

        value_cel = self.__value_celer(new_value_via_offset)

        return [new_cel_for(i) for i in range(0, self._cels_count)]

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
                # content overflow (Case0140DP)
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

        max_content_w = w(1) + w(2) + w(3)  # for (Case1320DP)

        if _do_shrink_to_fit_hack:
            use_alignment = 'align_always_shrink_to_fit'
        else:
            use_alignment = cel_schema.alignment
        aligned_children = getattr(childreners, use_alignment)

        return f

    return _celer_via


def _childreners_via(tainted_example_cel_DOM):

    class _childreners:  # #class-as-namespace

        """
        each function follows the pattern:
          1. yield a leaf DOM with the left margin spaces
          1. yield a leaf DOM with the content string
          1. yield a leaf DOM with the right margin spaces

        the only difference is whether which functions put the zero-width
        space as the margin at the (variously) left and/or right margin;
        and when not, how the nonzero width of that margin is calculated
        """

        def align_always_shrink_to_fit(total_margin_w, new_content_s):
            cover_me('this shrink-to-fit alignment worked once visually')
            yield _spaces(0)
            yield _fellow(new_content_s)
            yield _spaces(0)

        def align_left(total_margin_w, new_content_s):  # (Case2478KR)
            yield _spaces(0)
            yield _fellow(new_content_s)
            yield _spaces(total_margin_w)

        def align_center(total_margin_w, new_content_s):  # (Case2480KR)
            each_side, was_odd = divmod(total_margin_w, 2)
            yield _spaces(each_side)
            yield _fellow(new_content_s)
            yield _spaces(each_side + was_odd)  # hard coded: prefer left by 1

        def align_right(total_margin_w, new_content_s):  # (Case2479KR)
            yield _spaces(total_margin_w)
            yield _fellow(new_content_s)
            yield _spaces(0)

        no_alignment_specified = align_left  # (Case2481KR)

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

    if md[1] is None:
        if md[3] is None:
            # no alignment specified (Case2481KR)
            return _cel_schemas.no_alignment_specified
        else:
            # no colon yes colon (Case2478KR)
            return _cel_schemas.right_aligned
    elif md[3] is None:
        # yes colon no colon (Case2479KR)
        return _cel_schemas.left_aligned
    else:
        assert(not md[2])
        assert(not md[4])
        # yes colon/yes colon: center aligned (Case2480)
        return _cel_schemas.center_aligned


class _CelSchema:
    def __init__(self, s):
        self.alignment = s


class _cel_schemas:  # #class-as-namespace

    left_aligned = _CelSchema('align_left')
    center_aligned = _CelSchema('align_center')
    right_aligned = _CelSchema('align_right')
    no_alignment_specified = _CelSchema('no_alignment_specified')


sys.modules[__name__] = _SELF

# #history-A.3 (can be temporary): dog-eared specific code
# #history-A.2: short-circuiting out of updating single-field records moved up
# #history-A.1: sneak merge into here to be alongside create new
# #born.
