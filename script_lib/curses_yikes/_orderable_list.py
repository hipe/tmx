from script_lib.curses_yikes import \
        StateMachineBasedInteractableComponent_ as _InteractableComponent, \
        piece_via_has_focus_ as _piece_via_has_focus, \
        label_via_key_ as _label_via_key, \
        MultiPurposeResponse_ as _response, \
        Emission_ as _emission, \
        MutableStruct_ as _StrictDict
from collections import namedtuple as _nt


def orderable_list_state_machine():
    yield 'initial', 'cursor_enter', 'has_focus'
    yield 'has_focus', 'cursor_exit', 'initial'
    yield 'has_focus', '[enter] to edit', 'entered', 'call', '_ENTER'
    yield 'entered', '[a]dd', 'adding', 'call', '_EMACS'  # #here4 (above too)
    yield 'entered', '[d]one', 'initial', 'call', '_DONE'
    yield 'entered', 'key_down_probably', 'field_focus'

    yield 'adding', 'from_adding_to_field_focus', 'field_focus'

    yield 'field_focus', 'move-[u]p', 'field_focus', 'call', '_MOVE_UP'
    yield 'field_focus', 'move-[d]own', 'field_focus', 'call', '_MOVE_DOWN'
    yield 'field_focus', 'add-[a]fter', 'adding', 'call', '_EMACS'
    # yield 'field_focus', '[e]dit', 'editing', 'call', '_EDIT'
    yield 'field_focus', '[x]delete', 'field_focus', 'call', '_DELETE'
    yield 'field_focus', 'deleting_last', 'has_focus'
    yield 'field_focus', 'key_up_probably', 'entered'
    yield 'field_focus', 'do[n]e-editing-list', 'initial', 'call', '_DONE'


def _lazy_load_FFSA(fsa_def):
    def load_FFSA(_=None):
        return _FFSA(fsa_def)
    return load_FFSA


class __Abstract_Orderable_List__:

    def __init__(self, k, *more, value=None):
        self._key = k
        kw = {k: None for k in ('label',)}
        stack = list(reversed(more))
        while stack:
            kw[(k := stack.pop())]  # validate name
            kw[k] = stack.pop()
        kw['val'] = value
        self._klass = _abstract_anonymous_text_field()
        self._do_init(**kw)

    def _do_init(self, label, val):
        self._init_label_and_increase_minimum_width(label)
        if val:
            itr = self._item_AAs_WHILE_increasing_min_width(val)
            self._item_AAs = tuple(itr)
        else:
            self._item_AAs = None

    def _item_AAs_WHILE_increasing_min_width(self, val):
        for mixed in val:
            item_AA = self._klass.abstract_area_via_value(mixed)
            w = item_AA.minimum_width
            if self.minimum_width < w:
                self.minimum_width = w
            yield item_AA

    def _init_label_and_increase_minimum_width(self, label):

        if label is None:
            label = _label_via_key(self._key)

        # Our minimum width is a function of the following below (2 widths).
        # Since this is the first place we need knowledge of our label row
        # template structure we experimentally build the prototype dict here

        pre_bake = ''.join((label, ':'))

        proto = {  # #here1
            'left': _piece_via_has_focus.blank_span,
            'label_and_colon': pre_bake,
            'right_filler': None
        }

        self.minimum_width = sum(len(s) for s in proto.values() if s)
        proto['left'] = None  # important for _MutableStruct rules
        self._label_row_proto = proto

    def concretize_via_available_height_and_width(self, h, w, li=None):
        item_AAs = self._item_AAs
        klass = self._klass
        state = self.FFSAer().to_state_machine()
        return _ConcreteOrderableList(
            state, h, w, item_AAs, self._label_row_proto, self._key, klass)

    def minimum_height_via_width(self, _):
        return 3  # one for the label row, 2 for 2 items. no point in list if n

    FFSAer = _lazy_load_FFSA(orderable_list_state_machine)

    # minimum_width = len("👉 [foo bar baz]: [biffo bazzo waffo]")  # ..
    two_pass_run_behavior = 'break'
    can_fill_vertically = True  # maybe hard-code this to off at first..
    is_interactable = True
    defer_until_after_interactables_are_indexed = False


KLASS = __Abstract_Orderable_List__


class _ConcreteOrderableList(_InteractableComponent):

    def __init__(self, state, h, w, item_AAs, label_proto_d, k, klass):
        self._state = state
        self._height, self._width, self._key = h, w, k

        # Populate the components from the existing item values list
        self._init_components(item_AAs, label_proto_d, klass)

        # Derive the number of items from the components dictionary (method)

        # Derive the max number of items from the height
        self._max_number_of_items = h - 1  # #here2

        # Assert the number of items against the max
        if self._max_number_of_items < self._current_number_of_items:
            xx(f"can't init with {self._current_number_of_items} items "
               f"when max height is {h}")

        self._key_of_focused = None
        self._blank_row = ' ' * w

        self._focus_controller = None

    @property
    def FFSA_AND_STATE_NAME_ONCE_HAS_FOCUS_(self):
        ffsa = _FFSA(orderable_list_state_machine)
        return ffsa, 'has_focus'

    # == BEGIN we want the buttonpress function of parent class, but, as
    #    a compound area, our visual representation is entirely a function of
    #    that of our children. So us gaining and losing focus is a matter of
    #    giving and revoking focus to our top-child or ..

    def become_focused(self):  # OVERRIDE (compare)
        self._label_row.become_focused()  # #here5
        self._state.move_to_state_via_transition_name('cursor_enter')  # 🤷

    def become_not_focused(self):  # OVERRIDE (compare)
        if self._focus_controller is not None:  # #here8
            xx('enjoy')
        self._label_row.become_not_focused()
        self._state.move_to_state_via_transition_name('cursor_exit')  # 🤷

    # == END

    # == BEGIN managing one state to rule them all

    def apply_change_focus(self, k, k_):
        # Again, we have to do more than the focus controller because we have
        # "one state to rule them all"

        s = self._state
        sn = s.state_name

        if k is None:  # when deleted
            if 'label_row' == k_:
                xx('give me a case please')
            else:
                _item_offset_via_item_key(k_)  # assert
                assert 'field_focus' == sn
                # (leave state as-is)
        elif 'label_row' == k:
            _item_offset_via_item_key(k_)  # assert
            if 'entered' == sn:
                s.move_to_state_via_transition_name('key_down_probably')
            else:
                assert 'field_focus' == sn  # idk

        elif 'label_row' == k_:
            _item_offset_via_item_key(k)  # assert
            if 'initial' == sn:
                # (when do[n]e was pressed). state was changed automatically
                pass
            elif 'field_focus' == sn:
                pass  # #cover-me
            else:
                xx(f"easy: {sn!r}")
        else:
            _item_offset_via_item_key(k)  # assert
            _item_offset_via_item_key(k_)  # assert
            # Leave state as it is

        # The easy part: do what the focus controller does
        if k:
            # (if a component was deleted, k is None (maybe))
            self._components[k].become_not_focused()
        self._components[k_].become_focused()

    def _ENTER(self):
        # Entering into an SOC, push a new controller (us) on to the stack
        change = 'input_controller', 'push_receiver', self._key
        return _response(changes=(change,))

    def _DONE(self):
        # You're going to pop out. leave your label row as focused becase
        # that's what had focus when you popped in.
        if 'label_row' == self._FC_curr_key:
            resp = _response(changes=())  # 😢
        else:
            resp = self._focus_controller.change_focus_to('label_row')

        # You've got to leave your focus controller alive because you use
        # it to change focus at the apply stroke later (to change buttons)
        # self._focus_controller = None  # #here8

        change = 'input_controller', 'pop_receiver', self._key
        resp.changes = *resp.changes, change  # meh
        return resp

    def CONTROLLER_FRAME__(self):

        if self._focus_controller is None:  # imagine re-entering the SAC
            # A little rough: #here5 we give this guy focus manually so we
            # look right when we are cursored over. But no focus controller
            # yet. Now that yes, tell it who has focus to start with
            self._init_focus_controller('label_row')

        yield 'get_direction_controller', lambda: self._focus_controller

        # Normally the business button routing takes into account the currently
        # focused component to find a state transition that corresponds to
        # the pressed button. But here we don't want this lookup to take into
        # account our actually focused child, we want it only ever to use our
        # "one state to rule them all". AND when that state change request
        # bounces back in, it has to be addressed to us, the SOA.

        from script_lib.curses_yikes.input_controller_ import \
            business_buttonpress_controller_class_EXPERIMENTAL_via_ as func
        bbc_class = func(None)

        def RECV_BUTTONPRESS(bbc, _k_, label):
            t = bbc.transition_via_label(label)
            return self.RECEIVE_BUTTONPRESS(t)

        bbc_class.give_buttonpress_to_component = RECV_BUTTONPRESS  # BIG FLEX

        yield 'BBC', bbc_class()

    # == FROM emacs

    def _EMACS(self):
        # #eventually :#here6 we will have hide/disable buttons. The button
        # for adding an item should be suspended when the list is full.
        # But today is not that day, so check it manually :#here7:
        if self._max_number_of_items == self._current_number_of_items:
            return self._response_via_info('list_full', 'oops! list is full')

        self._point_of_ref_key = self._FC_curr_key
        changes = (('host_directive', 'enter_text_field_modal', self._key),)
        return _response(changes=changes)

    @property
    def value_span_x_and_width_for_modal_(self):

        # Where to draw the textbox? Draw it where the soon-to-exist item will
        # be. (It would be nice to shift the existing rows down first instead
        # of drawing the textbox over an existing item #wish)

        # First, Y: Assume "insert after". (Because of #here2 label row,
        # we'll never need an "insert before".) The Y of an item row is the Y
        # of the SAC plus 1 (label row #here2) plus the offset of the item.

        # Since we want the textbox to be after the "reference row" (formerly
        # focused row), we'll use the above formula (giving the label row an
        # imaginary item offset of -1), and add 1 to it to get the row after.

        k = self._point_of_ref_key
        if 'label_row' == k:  # #here2
            item_offset = -1
        else:
            item_offset = _item_offset_via_item_key(k)

        use_y = item_offset + 2  # one for label #here2. we have no Y

        # NOTE this should come from the injected class
        # As for the x,
        w = _piece_via_has_focus.width
        use_x = w

        # As for the width of the textbox, extend it all the way
        use_w = self._width - w

        del use_y  # whoops not used yet
        return use_x, use_w

    def receive_new_value_from_modal_(self, mixed):

        # Assert we have the space to add a new item because #here7
        assert self._current_number_of_items < self._max_number_of_items

        # Move our state back no matter what
        self._state.move_to_state_via_transition_name('from_adding_to_field_focus')  # noqa: E501 🤷

        # If they cancelled or it was blank, KISS: nope out of there
        was_blank = False
        if mixed is None:
            was_blank = True
        else:
            mixed = mixed.strip()
            was_blank = not len(mixed)

        if was_blank:
            return self._response_via_info('blank', 'was blank')

        # What will the key of our new item be?
        ref_k = self._point_of_ref_key
        del self._point_of_ref_key
        if 'label_row' == ref_k:
            reference_item_offset = -1
        else:
            reference_item_offset = _item_offset_via_item_key(ref_k)

        if True:  # if add (not edit existing)
            new_item_offset = reference_item_offset + 1
            new_k = _item_key_via_item_offset(new_item_offset)

        # Create the new item (row)
        new_item, emi = self._item_row_via_mixed_value(mixed)
        if new_item is None:
            xx("imagine new item validation failure")

        # Insert it, praying that the key it assigns is the one we assumed
        _insert_into_dictionary_shifting_keys(
            self._components, new_item_offset, new_item)

        # Re-init the focus controller with the new components
        # (but still point at old focus row because it still has focus)
        k = self._FC_curr_key
        assert ref_k == k
        self._reinit_focus_controller(ref_k)

        # Now change the focus to the newly created item
        return self._focus_controller.change_focus_to(new_k)

    # == TO

    def _DELETE(self):
        # The row with focus is being deleted. [#608.N] explains (sort of)
        # that, in order to give a visual indication of what UP and DOWN will
        # do, there must always be a component with focus. So we must move the
        # focus. As it works out, what should be the "obvious" behavior is
        # elaborate at best, if not not obvious. Our experimental current
        # working principle is, "minimize the distance the cursor moves".

        fc = self._focus_controller
        away_k = fc.key_of_currently_focused_component
        away_item_offset = _item_offset_via_item_key(away_k)
        curr_num = self._current_number_of_items
        bottom_item_offset = curr_num - 1

        # If you're deleting the item at the bottom of the list,
        if bottom_item_offset == away_item_offset:
            # Then move the cursor upwards on the screen by one:

            # If you're deleting the only item in the list
            if 1 == curr_num:
                # ..then land focus on the label row
                new_focus_k = 'label_row'
                self._state.move_to_state_via_transition_name('deleting_last')
            else:
                # ..otherwise land focus on the item above (the new bottom)
                new_focus_k = _item_key_via_item_offset(away_item_offset-1)

            new_focus_k_after = new_focus_k

        # When you're deleting a non-bottom item, you want to just keep
        # pointing at the same "slot" (the same screen row). BUT we move focus
        # before deleting the item (lessen focus manager confusion). So give
        # focus to the item that's currently below the to-delete item.
        else:
            new_focus_k = _item_key_via_item_offset(away_item_offset+1)
            new_focus_k_after = away_k

        # This sucks: change the focus
        resp = fc.change_focus_to(new_focus_k)

        _delete_from_dictionary_shifting_keys(self._components, away_k)
        self._reinit_focus_controller(new_focus_k_after)

        change, = resp.changes
        assert away_k == change[2]
        assert new_focus_k == change[3]
        muta_change = list(change)
        muta_change[2] = None
        muta_change[3] = new_focus_k_after
        change = tuple(muta_change)
        resp.changes = (change,)  # madman

        emi = _emi_via_info_line('deleted_item', 'Deleted 1 item.')
        assert resp.emissions is None  # ick
        resp.emissions = (emi,)  # eek
        return resp

    # ==

    def _MOVE_UP(self):
        return self._move_up_down('up', -1)

    def _MOVE_DOWN(self):
        return self._move_up_down('down', 1)

    def _move_up_down(self, adv, diff):
        ref_k = self._FC_curr_key
        focus_item_offset = _item_offset_via_item_key(ref_k)
        target_item_offset = focus_item_offset + diff
        num = self._current_number_of_items

        if num == target_item_offset:  # #here6
            reason = "can't move bottom item down"
            return self._response_via_info('wrong_way', reason)

        if -1 == target_item_offset:  # #here6
            reason = "can't move top item up"
            return self._response_via_info('wrong_way', reason)

        # OK please enjoy this one: the component that moved had focus before,
        # and (as an entirely obvious design choice) it should continue to
        # have focus after. Corollarily, the item it swapped places with didn't
        # have focus before and should continue not to have it after. Easy.
        # So as far as the components themselves are concerned, there's no
        # focusing to update. HOWEVER, the focus controller keeps track of
        # who has the focus by item key, and this key changed.

        # Also note we don't need to re-draw buttons until #here6

        target_k = _item_key_via_item_offset(target_item_offset)
        cx = self._components
        ref_item = cx[ref_k]
        target_item = cx[target_k]
        cx[target_k] = ref_item
        cx[ref_k] = target_item

        self._focus_controller.accept_new_key_of_focused_component__(target_k)

        # emi = _emi_via_info_line('moved_item', f"moved item {adv}")  nah
        return _response(changed_visually=(ref_k, target_k))

    # ==

    def _reinit_focus_controller(self, k):
        """
        The focus controller does stuff like index how long the list of items
        is so you know when you can't navigate any lower. When you change the
        composition of the list you have to rebuild the index (or maybe one
        day we won't index it, we'll just do it live)
        """
        self._init_focus_controller(k)

    def _init_focus_controller(self, already_k):
        from script_lib.curses_yikes.focus_controller_ import \
            vertical_splay_focus_controller_ as func
        self._focus_controller = func(
                self._components, current_k=already_k, TING_WING=self)

    def _response_via_info(self, cat, msg):
        emi = _emi_via_info_line(cat, msg)
        return _response(emissions=(emi,))

    def _this_response(self):
        return _response(changed_visually=(self._key,))

    def to_rows(self):
        for c in self._components.values():
            yield c.to_row()

        for _ in range(0, self._height - len(self._components)):
            yield self._blank_row

    # One-offs

    def _init_components(self, item_AAs, label_proto_d, klass):
        kvs = self._do_init_components(item_AAs, label_proto_d, klass)
        self._components = {k: v for k, v in kvs}

    def _do_init_components(self, item_AAs, label_proto_d, klass):
        yield 'label_row', _LabelRow(self._width, label_proto_d)

        c = klass.constructor_taking_mixed_value_via_width(self._width)
        self._item_row_via_mixed_value = c

        item_offset = -1
        for aa in (item_AAs or ()):
            item_offset += 1
            k = _item_key_via_item_offset(item_offset)
            ca, emi = c(aa.value)
            if ca is None:
                xx('hmm - decoding (unserializing (unmarshalling)) error')
            yield k, ca

    # Simple readers

    @property
    def _FC_curr_key(self):
        return self._focus_controller.key_of_currently_focused_component

    @property
    def _current_number_of_items(self):
        return len(self._components) - 1  # #here2

    @property
    def _label_row(self):
        return self._components['label_row']

    is_focusable = True


class _StateButNoFSA:

    def become_focused(self):
        assert self._has_focus is False
        self._has_focus = True

    def become_not_focused(self):
        assert self._has_focus is True
        self._has_focus = False

    _has_focus = False


# == Complicated thing goes here:


# == Anoynmous field

def _abstract_anonymous_text_field():

    class constructors:  # #class-as-namespace

        def abstract_area_via_value(val):
            assert isinstance(val, str)  # #[#022]
            min_w = left_w + 1 + len(val) + 1  # #here3
            return aa(min_w, val)

        def constructor_taking_mixed_value_via_width(w):
            return _anonymous_text_field(w)  # hi.

    aa = _nt('AA', ('minimum_width', 'value'))
    left_w = _piece_via_has_focus.width
    return constructors


def _anonymous_text_field(w):

    def build(x):
        leng = len(x)
        under_by = my_content_width - leng
        if under_by < 0:
            xx()
        filler = ' ' * under_by
        return AnonymousTextField(x, filler), None

    class AnonymousTextField(_StateButNoFSA):

        def __init__(self, x, filler):
            self.value_string = x
            self.rest = ''.join((' ', x, filler, ' '))  # #here3

        @property
        def FFSA_AND_STATE_NAME_ONCE_HAS_FOCUS_(self):
            ffsa = _FFSA(orderable_list_state_machine)
            return ffsa, 'field_focus'

        def to_row(self):
            pc = _piece_via_has_focus(self._has_focus)
            return ''.join((pc, self.rest))

        is_focusable = True

    my_width = w - _piece_via_has_focus.width
    my_content_width = my_width - 2  # #here3 "[value]" mebbe
    return build


# == Label row

class _LabelRow(_StateButNoFSA):

    def __init__(self, w, label_proto_d):
        self._render = _bake_label_renderer(w, label_proto_d)

    @property
    def FFSA_AND_STATE_NAME_ONCE_HAS_FOCUS_(self):
        ffsa = _FFSA(orderable_list_state_machine)
        return ffsa, 'entered'  # once you're "in" the SAC. #here4

    def to_row(self):
        return self._render(self._has_focus)

    is_focusable = True


def _bake_label_renderer(row_w, label_proto_d):

    def render(has_focus):
        pc = _piece_via_has_focus(has_focus)
        dct['left'] = pc
        final = ''.join(dct.values())
        assert row_w == len(final)
        return final

    dct = {k: v for k, v in label_proto_d.items()}
    real = dct
    dct = _StrictDict(dct)  # field names were established #here1
    dct['left'] = _piece_via_has_focus.blank_span
    content_w = sum(len(s) for s in real.values() if s)
    dct['left'] = None

    under_by = row_w - content_w
    assert -1 < under_by

    dct['right_filler'] = ' ' * under_by
    dct = real

    right = ''.join((dct.pop('label_and_colon'), dct.pop('right_filler')))
    dct['static_rest'] = right

    return render


# ==

def _hacky_filter(resp, sac_k):

    # Make a diminishing pool of the keys that changed visually
    cv = resp.changed_visually

    pool = {k: True for k in cv}

    # Put these magically meaningful things aside
    mid = {}
    for k in ('flash_area', 'buttons'):
        mid[k] = pool.pop(k, False)

    # Do you have any business things in there?
    yes = len(pool)

    # (assert they were all business things)
    pool.pop('label_row', None)
    assert all('item_' == k[0:5] for k in pool.keys())

    # Whether you need to redraw the whole SAC is based on that
    mid[sac_k] = yes

    out = tuple(k for k, v in mid.items() if v)
    resp.changed_visually = out or None  # the worst
    # (seems impossible that we would ever have none)
    return resp


# ==

def _insert_into_dictionary_shifting_keys(cx, offset, value):  # #testpoint
    all_keys = tuple(cx.keys())
    num_items_after = len(cx)  # #here2
    final_item_keys = tuple(f"item_{i}" for i in range(1, num_items_after+1))

    assert all_keys[1:] == final_item_keys[0:-1]

    for i in reversed(range(offset, num_items_after-1)):
        from_key = final_item_keys[i]
        to_key = final_item_keys[i+1]
        cx[to_key] = cx[from_key]  # assigns to new KEY the first time

    cx[final_item_keys[offset]] = value


def _delete_from_dictionary_shifting_keys(cx, key):  # #testpoint
    keys = tuple(cx.keys())
    here = keys.index(key)
    assert 0 != here  # #here2: N number of head items are special

    for key_offset in range(here, len(keys)-1):
        from_key = keys[key_offset+1]
        to_key = keys[key_offset]
        cx[to_key] = cx[from_key]

    cx.pop(keys[-1])


def _item_key_via_item_offset(item_offset):
    assert 0 <= item_offset
    return f"item_{item_offset+1}"


def _item_offset_via_item_key(item_key):
    import re
    md = re.match(r'item_([0-9]+)\Z', item_key)
    if not md:
        xx(f"oops: {item_key!r}")
    return int(md[1]) - 1  # #here2


# ==

def _FFSA(fsa_def):  # copy-paste. memoize the FFSA into its own func
    if not hasattr(fsa_def, '_FFSA_'):
        from ._formal_state_machine_collection import \
            build_formal_FSA_via_definition_function_ as func
        fsa_def._FFSA_ = func(__name__, fsa_def)
    return fsa_def._FFSA_


def _emi_via_info_line(cat, msg):
    return _emission(('info', 'expression', cat, lambda: (msg,)))


def xx(msg=None):
    raise RuntimeError(''.join(('cover me', *((': ', msg) if msg else ()))))


"""Appendix A:

- One big state machine for the auto buttons to index all the buttons we need


"""

# #born
