from script_lib.curses_yikes import \
        StateMachineBasedInteractableComponent_ as _InteractableComponent, \
        StateButNoFSA_ as _StateButNoFSA, \
        piece_via_has_focus_ as _piece_via_has_focus, \
        button_pages_via_FFSA_ as _button_pages_via_FFSA, \
        label_via_key_ as _label_via_key, \
        EmacsFieldDirective_ as _EmacsFieldDirective, \
        MutableChangeFocusDirective_ as _mutable_change_focus_direc, \
        MultiPurposeResponse_ as _response, \
        Emission_ as _emission, \
        MutableStruct_ as _StrictDict


def orderable_list_state_machine():
    yield 'initial', 'cursor_enter', 'has_focus'

    yield 'has_focus', 'cursor_exit', 'initial'
    yield 'has_focus', '[enter] to edit', 'entered', 'call', '_ENTER'

    yield 'entered', 'do[n]e', 'initial', 'call', '_DONE'
    yield 'entered', 'key_down_probably', 'field_focus'

    yield 'field_focus', 'move-[u]p', 'field_focus', 'call', '_MOVE_UP'
    yield 'field_focus', 'move-[d]own', 'field_focus', 'call', '_MOVE_DOWN'

    # yield 'field_focus', '[e]dit', 'editing', 'call', '_EDIT'
    yield 'field_focus', '[x]delete', 'field_focus', 'call', '_DELETE'
    yield 'field_focus', 'deleting_last', 'has_focus'
    yield 'field_focus', 'key_up_probably', 'entered'
    yield 'field_focus', 'do[n]e-editing-list', 'initial', 'call', '_DONE'


# item_CC = item constructor constructor
# item_C = item constructor (like a class but other functions too)


class __Abstract_Orderable_List__:

    def __init__(self, k, *more, value=None):
        self._key = k
        kw = {k: None for k in ('label', 'item_class')}
        stack = list(reversed(more))
        while stack:
            kw[(k := stack.pop())]  # validate name
            kw[k] = stack.pop()
        kw['val'] = value
        self._do_init(**kw)

    def _do_init(self, item_class, label, val):
        self._init_label_and_increase_minimum_width(label)
        self._item_CC = _produce_some_item_CC(item_class)
        self._init_item_abstract_areas(val)  # after resolving item class
        self._inject_glizzy_into_state_machine_lets_go()

    def _init_item_abstract_areas(self, val):
        if val:
            itr = self._item_AAs_WHILE_increasing_min_width(val)
            self._item_AAs = tuple(itr)
        else:
            self._item_AAs = None

    def _item_AAs_WHILE_increasing_min_width(self, val):
        for mixed in val:
            item_AA = self._item_CC.abstract_area_via_value(mixed)
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
        item_CC = self._item_CC
        state = self._FFSA.to_state_machine()
        return _ConcreteOrderableList(
            state, h, w, item_AAs, self._label_row_proto, self._key, item_CC)

    def minimum_height_via_width(self, _):
        return 3  # one for the label row, 2 for 2 items. no point in list if n

    def to_button_pages(self):
        # (we want this to change very soon)
        return _button_pages_via_FFSA(self._FFSA)

    def _inject_glizzy_into_state_machine_lets_go(self):
        my_ffsa = _FFSA(orderable_list_state_machine)
        their_ffsa = self._item_CC.FFSA_for_injection
        self._FFSA = my_ffsa.__class__.HOLY_SMOKES_MERGE_FFSAs(my_ffsa, their_ffsa)  # noqa: E501

    component_type_key = __name__, '__orderable_list__'  # unique but no see

    # minimum_width = len("👉 [foo bar baz]: [biffo bazzo waffo]")  # ..
    two_pass_run_behavior = 'break'
    can_fill_vertically = True  # maybe hard-code this to off at first..
    is_interactable = True
    defer_until_after_interactables_are_indexed = False


KLASS = __Abstract_Orderable_List__


class _ConcreteOrderableList(_InteractableComponent):

    def __init__(self, state, h, w, item_AAs, label_proto_d, k, item_CC):
        self._state = state
        self._height, self._width, self._key = h, w, k

        # Populate the components from the existing item values list
        self._init_components(item_AAs, label_proto_d, item_CC)

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
        self._the_proxy = None

    # == BEGIN we want the buttonpress function of parent class, but, as
    #    a compound area, our visual representation is entirely a function of
    #    that of our children. So us gaining and losing focus is a matter of
    #    giving and revoking focus to our top-child or ..

    def become_focused(self):  # OVERRIDE (compare)
        self._label_row.become_focused()  # #here5
        self._state.move_to_state_via_transition_name('cursor_enter')  # 🤷

    def become_not_focused(self):  # OVERRIDE (compare)
        if self._focus_controller is not None:  # #here8
            self._focus_controller = None  # EEEK ok hopefully
        self._label_row.become_not_focused()
        if 'initial' == self._state_name:
            return
        self._state.move_to_state_via_transition_name('cursor_exit')

    # == END

    # == BEGIN managing one state to rule them all

    def apply_change_focus(self, k, k_):
        # Again, we have to do more than the focus controller because we have
        # "one state to rule them all"

        # Figure out what state transition to take based on component names
        from_type, item_offset = _component_type_via_component_key(k)
        to_type, item_offset = _component_type_via_component_key(k_)
        m = self._method_name_via(from_type, to_type)
        getattr(self, m)()

        # The easy part: do what the focus controller does
        if k:
            # (if a component was deleted, k is None (maybe))
            self._components[k].become_not_focused()
        self._components[k_].become_focused()

    def _method_name_via(self, from_type, to_type):
        if 'label_row' == from_type:
            _assert_equal('item_row', to_type)
            return '_when_label_row_to_item_row'
        if 'item_row' == from_type:
            if 'item_row' == to_type:
                return '_when_item_row_to_item_row'
            _assert_equal('label_row', to_type)
            return '_when_item_row_to_label_row'
        assert 'nothing' == from_type  # when deleted
        if 'label_row' == to_type:
            return '_when_item_row_to_label_row'
        _assert_equal('item_row', to_type)
        return '_when_nothing_to_item_row'

    def _when_label_row_to_item_row(self):
        if self._is_entering:
            return
        self._assert_state('entered')
        self._move_to_state_over('key_down_probably')

    def _when_item_row_to_item_row(self):
        if self._is_entering:
            return
        self._assert_state('field_focus')

    def _when_item_row_to_label_row(self):
        if 'initial' == self._state_name:
            return
        self._assert_state('field_focus')
        self._move_to_state_over('key_up_probably')

    def _when_nothing_to_label_row(self):
        self._assert_state('field_focus')
        xx('give me a case please')

    def _when_nothing_to_item_row(self):
        self._assert_state('field_focus')
        # leave state as-is

    @property
    def _is_entering(self):
        i = self._state_name.find('entering_')
        return 0 == i

    # == END

    def _ENTER(self):
        # Entering into an SOC, push a new controller (us) on to the stack
        change = 'input_controller', 'push_receiver', self._key
        return _response(changes=(change,))

    def _DONE(self):
        # You're going to pop out. leave your label row as focused because
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

        # == Process Business Buttonpresses (BBP's)
        #    Unlike the default behavior (where every business buttonpress
        #    gets routed to the focued component, which propbably changes its
        #    own state (possibly leading to button changes)), Here we have
        #    "one state to rule them all", (we are one controller) so we don't
        #    take into account which of our components has focus on BBP's

        def recv_busi_bp(label):
            return self.receive_business_buttonpress(label)

        def apply_busi_bp(label, *more):
            return self.apply_business_buttonpress(label, *more)

        yield 'receive_BBP', recv_busi_bp

        yield 'apply_BBP', apply_busi_bp

        # == END

        yield 'component_button_page_key_once_has_focus', 'entered'

    # == BEGIN add ("emacs")

    """Adding a new item is a complicated series of two-strokes:

    1. "[a]dd" button (or similar) is pressed, whose transition (modeled by
    the injected item class) probably indicates this "_EMACS" action

    2. When the button press patch is applied, this action is probably executed
    which results in a patch with two changes: 1. make the WIP space and
    2. show the emacs field. (This second patch is itself a two-stroke,
    requiring coordinate translation to screen coordinates.)

    3. MORE
    """

    def _EMACS(self, *args_for_plugin):

        # #eventually :#here6 we will have hide/disable buttons. The button
        # for adding an item should be suspended when the list is full.
        # But today is not that day, so check it manually :#here3:

        # #open [#607.I]: at history-B.4 it became true that this check can
        # no longer happen here because if you're a poly-option, you want this
        # check before you `_EMACS` for the name but not before the value (b.c
        # the WIP row has already been added when you're doing the value.)
        # .#open [#607.I] this check needs to happen somewhere.
        # Also this will be affected by disappearing buttons [#607.K]
        if False and self._max_number_of_items == self._current_number_of_items:  # noqa: E501
            return self._response_via_info('list_full', 'oops! list is full')

        return self._item_C.emacs(self._proxy, *args_for_plugin)

    def _insert_WIP_row(self, new_k):

        # Again (#here3) assert we have the space to add a new item
        assert self._current_number_of_items < self._max_number_of_items

        # Ask the injected item class to create the blank item component
        new_item_offset = _item_offset_via_item_key(new_k)
        new_item = self._item_C.create_WIP_item_component()

        # Insert it, praying that the key it assigns is the one we assumed
        _insert_into_dictionary_shifting_keys(
            self._components, new_item_offset, new_item)

        # Re-init the focus controller with the new components
        # (but still point at old focus row because it still has focus)
        self._reinit_focus_controller(self._FC_curr_key)

        # Now change the focus to the newly created item
        # (note this usually leads to buttons change on first add)
        return self._focus_controller.change_focus_to(new_k)

    def receive_new_value_from_modal_(self, comp_k, text, *plugin_args):
        c = self._components[comp_k]
        p = self._proxy
        return c.receive_new_value_from_parent_(p, text, *plugin_args)

    # == END add

    def _DELETE(self):
        # The row with focus is being deleted. [#608.P] explains (sort of)
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

        # Take focus away from the component being deleted (just because) and
        # give it to the component we decied above (either item or label row)
        resp = fc.change_focus_to(new_focus_k)

        # The main thing: mutate our dictionary of components (shift & pop)
        _delete_from_dictionary_shifting_keys(self._components, away_k)

        # Re-create the focus index, telling it who already has focus
        self._reinit_focus_controller(new_focus_k_after)

        # Tedious: we need to send back a "change focus" patch so buttons
        # change and screen areas taint themselves for redraw etc BUT this
        # patch as it is is now irrelevant because it refers to the state of
        # things before the delete. Make the patch correctly refer to the
        # way things are now, after the delete:

        change, = resp.changes
        o = _mutable_change_focus_direc(*change)

        _assert_equal(new_focus_k, o['hello_component_key'])
        _assert_equal(away_k, o['goodbye_component_key'])

        # Actually, say you're changing from NO focus (because you deleted it)
        o['goodbye_component_key'] = None

        # Actually, make the new focus be THIS key (slots shifted around)
        o['hello_component_key'] = new_focus_k_after

        change = tuple(o._values.values())
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
                self._components,
                current_key=already_k,
                component_key_in_the_context_of_buttons=self._key,
                custom_apply_change_focus=self.apply_change_focus)

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

    @property
    def _proxy(self):
        if self._the_proxy is None:
            self._the_proxy = self._build_proxy()
        return self._the_proxy

    def _build_proxy(self):
        class ProxyToParent:

            def experiment_transition(_, tname, *item_k):
                change = 'input_controller', 'traverse_transition', tname, *item_k  # noqa: E501
                return _response(changes=(change,))

            def build_change_for_show_EMACS_field(
                    _, new_k, x, w, *args_for_plugin):
                return _build_change_for_show_EMACS_field(
                        self._key, new_k, x, w, args_for_plugin)

            def build_change_for_insert_WIP_row(_, new_k):
                return 'child_component', self._key, '_insert_WIP_row', new_k

            @property
            def item_key_of_eventual_item(_):
                # For now, assume "[a]dd" or "add [a]fter"
                k = self._FC_curr_key
                if 'label_row' == k:
                    return 'item_1'
                return _item_key_via_item_offset(_item_offset_via_item_key(k) + 1)  # noqa: E501

            @property
            def STATE_NAME(_):  # useful in development
                return self._state_name

        return ProxyToParent()

    # Our own personal state machine API

    def _assert_state(self, sn):
        act = self._state_name
        _assert_equal(sn, act)

    def _move_to_state_over(self, tn):
        self._state.move_to_state_via_transition_name(tn)

    # One-offs

    def _init_components(self, item_AAs, label_proto_d, item_CC):
        kvs = self._do_init_components(item_AAs, label_proto_d, item_CC)
        self._components = {k: v for k, v in kvs}

    def _do_init_components(self, item_AAs, label_proto_d, item_CC):
        yield 'label_row', _LabelRow(self._width, label_proto_d)

        item_C = item_CC.constructor_taking_mixed_value_via_width(self._width)
        self._item_C = item_C

        item_offset = -1
        for aa in (item_AAs or ()):
            item_offset += 1
            k = _item_key_via_item_offset(item_offset)
            ca, emi = item_C.unserialize(aa.value)
            if ca is None:
                xx('hmm - decoding (unserializing (unmarshalling)) error')
            yield k, ca

    # Simple readers

    def to_form_value(self):
        return tuple(self._to_form_values())

    def _to_form_values(self):
        keys = iter((dct := self._components).keys())
        assert 'label_row' == next(keys)
        return (dct[k].to_form_value() for k in keys)

    @property
    def _FC_curr_key(self):
        return self._focus_controller.key_of_currently_focused_component

    @property
    def _current_number_of_items(self):
        return len(self._components) - 1  # #here2

    @property
    def _label_row(self):
        return self._components['label_row']

    @property
    def _state_name(self):
        return self._state.state_name

    is_focusable = True


# == Label row

class _LabelRow(_StateButNoFSA):

    def __init__(self, w, label_proto_d):
        self._render = _bake_label_renderer(w, label_proto_d)

    def to_row(self):
        return self._render(self._has_focus)

    @property
    def component_buttons_page_key_when_has_focus(_):
        # when the SOA is not entered yet, the label row will get focus but
        # this is not that. is this for when the SOA is entered.
        return 'entered'

    is_focusable = True


def _bake_label_renderer(row_w, label_proto_d):

    def render(has_focus):
        pc = _piece_via_has_focus(has_focus)
        dct['left'] = pc
        final = ''.join(dct.values())
        _assert_equal(row_w, len(final))
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

def _build_change_for_show_EMACS_field(sac_k, new_k, x, w, args_for_plugin):

    # The Y of the emacs field: start with the SAC Y (not pictured,
    # translated-in elsewhere) and add ONE for the #here2 label row and
    # add ONE for each of the zero or more items above this WIP one
    emacs_y = 1 + _item_offset_via_item_key(new_k)

    direc = _EmacsFieldDirective.via(
            component_path=(sac_k, new_k),
            emacs_field_height=1,
            emacs_field_width=w,
            emacs_field_y=emacs_y,
            emacs_field_x=x)
    return 'parent_area', 'translate_area', 'host_directive', \
           'enter_emacs_modal', *tuple(direc), *args_for_plugin


# ==

def _insert_into_dictionary_shifting_keys(cx, offset, value):  # #testpoint
    all_keys = tuple(cx.keys())
    num_items_after = len(cx)  # #here2
    final_item_keys = tuple(f"item_{i}" for i in range(1, num_items_after+1))

    _assert_equal(all_keys[1:], final_item_keys[0:-1])

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


def _component_type_via_component_key(k):
    if 'label_row' == k:
        return 'label_row', None
    if k is None:
        return 'nothing', None
    return 'item_row', _item_offset_via_item_key(k)


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

def _produce_some_item_CC(item_class_argument):

    if item_class_argument is None:
        # Make old tests work, also let definitions stay pretty and terse
        item_class_argument = 'anonymous_text_field'

    if not isinstance(item_class_argument, str):
        xx(f"yes it would be interesting if you could inject classes here - {item_class_argument!r}")  # noqa: E501

    from . import _injectable_item_classes as glizzy_module

    # (could make this more dynamic, but why)

    if 'poly_option' == item_class_argument:
        return glizzy_module.poly_option_constructor_constructor_()

    if 'anonymous_text_field' == item_class_argument:
        return glizzy_module.anonymous_text_field_constructor_constructor_()

    xx(f"not a recognized item class: {item_class_argument!r}")


# ==

def _FFSA(fsa_def):  # copy-paste. memoize the FFSA into its own func
    if not hasattr(fsa_def, '_FFSA_'):
        from modality_agnostic.magnetics.formal_state_machine_via_definition \
            import build_formal_FSA_via_definition_function as func
        fsa_def._FFSA_ = func(__name__, fsa_def)
    return fsa_def._FFSA_


def _emi_via_info_line(cat, msg):
    return _emission(('info', 'expression', cat, lambda: (msg,)))


def _assert_equal(x1, x2):
    if x1 == x2:
        return
    raise RuntimeError(f"oops: {x1!r} != {x2!r}")


def xx(msg=None):
    raise RuntimeError(''.join(('cover me', *((': ', msg) if msg else ()))))


"""Appendix A:

- One big state machine for the auto buttons to index all the buttons we need


"""

"""Appendix B: :#here2:

We always only ever consist consist of a label (which takes up eactly ONE row)
plus ONE ROW PER ITEM for our ZERO OR MORE items

Hence our current number of items is always:

    the number of components minus one

Our item capacity is determined entirely by the available verticality
with the straightforward formula implied by the above.

This arithmetic relationship is repeated over and over here..
"""

# #history-B.4
# #born
