"""
in [#608.L] we develop what the selection controller is, its responsibilities
and how it exists independently of the input controller.
"""

from script_lib.curses_yikes import \
        MultiPurposeResponse_ as _multi_response


_input_response = _multi_response


def vertical_splay_selection_controller_(cx):
    return _func('vertical', cx)


def horizontal_splay_selection_controller_(cx):
    return _func('horizontal', cx)


def _func(vertical_or_horizontal, cx):
    # Whether the movement happens on the vertical (more common) or horizontal,
    # the algorithm is identical. Only the names of thing change (like which
    # keys). We use variable names that correspond to vertical b.c more common

    def main():
        assert_that_components_initial_state_is_right()
        return SelectionController()

    class SelectionController:

        def __init__(self):
            self._key_of_currently_selected_component = top_k

        def receive_directional_key_press(self, key):
            k = self._key_of_currently_selected_component
            return receive_directional_key_press(key, k)

        def apply_change(self, stack):
            k, k_ = apply_change(stack)
            self._key_of_currently_selected_component = k_
            return _input_response(changed_visually=(k, k_))

        @property
        def key_of_currently_selected_component(self):
            return self._key_of_currently_selected_component

    def receive_directional_key_press(key, currently_selected_component_k):

        meaning = meaning_via_key[key]

        # Ignore directional keypresses on wrong dimension, quietly
        if 'not_my_dimension' == meaning:
            return _do_nothing

        i = order_offset_via_key[currently_selected_component_k]

        # Make a request for moving the selection up or down, probably
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
        sn = comp_via_key[k_].state.state_name_via_transition_name('cursor_enter')  # noqa: E501
        changes = (
            ('selection_controller', 'change_selected', currently_selected_component_k, k_),  # noqa: E501
            ('buttons_controller', 'selected_changed', k_, sn))
        return _input_response(changes=changes)

    def apply_change(stack):
        typ = stack.pop()
        assert 'change_selected' == typ
        k_, k = stack  # before and after (but order reversed b.c stack)
        goodbye = comp_via_key[k]
        hello = comp_via_key[k_]
        goodbye.state.move_to_state_via_transition_name('cursor_exit')
        hello.state.move_to_state_via_transition_name('cursor_enter')
        return k, k_

    is_vertical_not_horizontal = ('horizontal', 'vertical').index(vertical_or_horizontal)  # noqa: E501

    if is_vertical_not_horizontal:
        meaning_via_key = {
            'KEY_UP': 'decrease_offset', 'KEY_DOWN': 'increase_offset',
            'KEY_LEFT': 'not_my_dimension', 'KEY_RIGHT': 'not_my_dimension'}
    else:
        meaning_via_key = {
            'KEY_LEFT': 'decrease_offset', 'KEY_RIGHT': 'increase_offset',
            'KEY_UP': 'not_my_dimension', 'KEY_DOWN': 'not_my_dimension'}

    def assert_that_components_initial_state_is_right():
        # Assert that the topmost interactable component is in the focus state
        top_c = comp_via_key[top_k]
        rest_c = (comp_via_key[keys_in_order[i]] for i in range(1, leng))
        sn = top_c.state.state_name
        if 'has_focus' != sn:
            xx(f"top compponent ({top_k!r}) must already have focus")

        # Assert that the remaining non-top components are in the initial state
        def must_be_in_initial_state(c):
            sn = c.state.state_name
            if 'initial' == sn:
                return True
            xx(f"Not in initial state: '{c.key}' (state: {sn!r})")
        assert all(must_be_in_initial_state(c) for c in rest_c)

    # Make a sub-dictionary of only those components that are interactable
    comp_via_key = {k: c for k, c in cx.items() if c.state is not None}
    leng = len(comp_via_key)

    # Derive a bunch of index-like values EACH OF WHICH is used as business ind
    keys_in_order = tuple(comp_via_key.keys())
    top_k = keys_in_order[0]
    order_offset_via_key = {keys_in_order[i]: i for i in range(0, leng)}
    order_offset_of_bottommost = leng - 1

    return main()


_do_nothing = _input_response()


def xx(msg=None):
    raise RuntimeError(''.join(('cover me', *((': ', msg) if msg else ()))))

# #broke-out
