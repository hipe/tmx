"""
in [#608.L] we develop what the focus controller is, its responsibilities
and how it exists independently of the input controller.
"""

from script_lib.curses_yikes import \
        MultiPurposeResponse_ as _multi_response


_input_response = _multi_response


def vertical_splay_focus_controller_(cx, **kw):
    return _func('vertical', cx, **kw)


def horizontal_splay_focus_controller_(cx, **kw):
    return _func('horizontal', cx, **kw)


def _func(vertical_or_horizontal, cx, current_k=None, TING_WING=None):
    # Whether the movement happens on the vertical (more common) or horizontal,
    # the algorithm is identical. Only the names of thing change (like which
    # keys). We use variable names that correspond to vertical b.c more common

    class FocusController:

        def __init__(self):
            self._key_of_currently_focused_component = current_k

        def receive_directional_key_press(self, key):
            k = self._key_of_currently_focused_component
            return receive_directional_key_press(key, k)

        def change_focus_if_necessary_to(self, k_):
            k = self._key_of_currently_focused_component
            if k == k_:
                return _do_nothing
            return change_focus(k, k_)

        def change_focus_to(self, k_):
            k = self._key_of_currently_focused_component
            assert k != k_
            return change_focus(k, k_)

        def apply_change_focus(self, k, k_):
            apply_change_focus(k, k_)
            self._key_of_currently_focused_component = k_

        def BUTTON_CHANGE_EXPERIMENT_FOR_AFTER_FRAME_PUSH(self):
            k = self._key_of_currently_focused_component
            return BUTTON_CHANGE_EXPERIMENT_FOR_AFTER_FRAME_PUSH(k)

        def accept_new_key_of_focused_component__(self, k_):
            # (if you know what you're doing)
            self._key_of_currently_focused_component = k_

        @property
        def key_of_currently_focused_component(self):
            return self._key_of_currently_focused_component

        @property
        def key_of_topmost_focusable_component(self):
            return keys_in_order[0]

        @property
        def FOCUSABLE_COMPONENTS__(self):
            # (oops we don't have this in the input controller)
            return comp_via_key

        @property
        def CHA_CHA_CHA__(self):
            return cx

    def receive_directional_key_press(key, currently_focused_component_k):

        meaning = meaning_via_key[key]

        # Ignore directional keypresses on wrong dimension, quietly
        if 'not_my_dimension' == meaning:
            return _do_nothing

        i = order_offset_via_key[currently_focused_component_k]

        # Make a request for moving the focus up or down, probably
        if 'increase_offset' == meaning:
            # Ignore it if KEY_DOWN and already at bottommost, quietly
            if order_offset_of_bottommost == i:
                return _do_nothing
            add_me = 1
        else:
            # Ignore it if KEY_UP and already at topmost, quietly
            assert 'decrease_offset' == meaning
            if 0 == i:
                return _do_nothing
            add_me = -1

        desired_order_offset = i + add_me
        k_ = keys_in_order[desired_order_offset]
        return change_focus(currently_focused_component_k, k_)

    def change_focus(k, k_):
        c = cx[k_]
        ffsa, sn = c.FFSA_AND_STATE_NAME_ONCE_HAS_FOCUS_
        changes = (('input_controller', 'change_focus', k, k_, ffsa, sn),)
        return _input_response(changes=changes)

    def BUTTON_CHANGE_EXPERIMENT_FOR_AFTER_FRAME_PUSH(k):
        c = cx[k]
        ffsa, sn = c.FFSA_AND_STATE_NAME_ONCE_HAS_FOCUS_
        changes = (('input_controller', 'change_buttons', k, ffsa, sn),)
        return _input_response(changes=changes)

    def apply_change_focus(k, k_):
        if TING_WING:
            TING_WING.apply_change_focus(k, k_)
            return
        if k is not None:
            goodbye = comp_via_key[k]
        hello = comp_via_key[k_]
        if k is not None:
            goodbye.become_not_focused()
        hello.become_focused()

    is_vertical_not_horizontal = ('horizontal', 'vertical').index(vertical_or_horizontal)  # noqa: E501

    if is_vertical_not_horizontal:
        meaning_via_key = {
            'KEY_UP': 'decrease_offset', 'KEY_DOWN': 'increase_offset',
            'KEY_LEFT': 'not_my_dimension', 'KEY_RIGHT': 'not_my_dimension'}
    else:
        meaning_via_key = {
            'KEY_LEFT': 'decrease_offset', 'KEY_RIGHT': 'increase_offset',
            'KEY_UP': 'not_my_dimension', 'KEY_DOWN': 'not_my_dimension'}
    # Make a sub-dictionary of only those components that are focusable
    comp_via_key = {k: c for k, c in cx.items() if c.is_focusable}
    leng = len(comp_via_key)

    # Derive a bunch of index-like values EACH OF WHICH is used as business ind
    keys_in_order = tuple(comp_via_key.keys())
    order_offset_via_key = {keys_in_order[i]: i for i in range(0, leng)}
    order_offset_of_bottommost = leng - 1

    return FocusController()


_do_nothing = _input_response()


def xx(msg=None):
    raise RuntimeError(''.join(('cover me', *((': ', msg) if msg else ()))))

# #broke-out
