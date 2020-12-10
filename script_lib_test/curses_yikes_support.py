class start_long_story:

    def __init__(self, tc, h, w, aa, controller_key=None):
        self._area = concretize(h, w, aa)
        self._TC = tc
        self._cont_key = controller_key

        self._do_output_this_one_thing = True
        self._do_debug and self.DEBUG_DUMP("before input controller")
        self._IC = input_controller_via_CCA(self._area)
        self._do_debug and self.DEBUG_DUMP("after input controller")

        self._is_ready = True

    # == FOCUS HACK

    def FOCUS_HACK(self, tup):
        # (we're calling it a hack but as far as we can tell it's changing
        # focus through all the proper channels)

        assert 1 == len(self._IC._controller_stack)
        sac_k, comp_k = tup  # for now

        # Get the directive to change the focus
        resp = self._IC._DC.change_focus_if_necessary_to(sac_k)

        # It's a patch that turns into calls to several subsystems
        self._apply_recursive(resp)

        # YUCK assume hitting enter means "step in to SAC"
        self.press_key('\n')
        self.expect_this_button_was_pressed('[enter] to edit')
        self._apply_recursive(self._release())

        comp = self._area.COMPONENT_AT(sac_k)

        # Get the directive to change the focus (again)
        resp = comp._focus_controller.change_focus_if_necessary_to(comp_k)

        # (again)
        self._apply_recursive(resp)

    # == Enter Text

    def enter_text(self, text):

        # Sneak in thing
        resp = self._release()
        changes = expect_only_changes(resp)
        change, = changes
        exp = 'input_controller', 'apply_business_buttonpress'
        act = change[0:2]
        self._TC.assertSequenceEqual(act, exp)
        self._hold_via_changes(changes)

        # Response is a request to enter into emacs mode
        resp = self._release()
        changes = expect_only_changes(resp)
        change, = changes
        exp = 'host_directive', 'enter_text_field_modal', self._cont_key
        act = change[0:3]
        self._TC.assertSequenceEqual(act, exp)

        sac = self._area.COMPONENT_AT(self._cont_key)
        resp = sac.receive_new_value_from_modal_(text)
        changes = expect_only_changes(resp)
        change, = changes
        exp = 'input_controller', 'change_focus'  # OR NOT
        act = change[0:len(exp)]
        self._TC.assertSequenceEqual(exp, act, exp)

        # Visual changes: SAC area and maybe buttons area
        resp = self._IC.apply_changes(changes)
        cv = expect_only_changed_visually(resp)
        pool = {k: None for k in cv}
        pool.pop(self._cont_key)
        pool.pop('buttons', None)
        assert not pool

    # == Press Button

    def press_key(self, keycode):
        self._hold(self._IC.receive_keypress(keycode))

    def expect_this_button_was_pressed(self, label):
        resp = self._release()
        changes = expect_only_changes(resp)
        act, = changes
        exp = 'input_controller', 'apply_business_buttonpress', label
        self._TC.assertSequenceEqual(act, exp)
        self._hold_via_changes(changes)

    def expect_buttons_change_and(self, who):
        resp = self._release()
        changes, cv = expect_only(resp, 'changes', 'changed_visually')
        exp = {'buttons', who}
        act = resp.changed_visually
        assert_set_equals(act, exp)
        self._hold_via_changes(changes)

    # ==

    def expect_emissions_and_apply_changes(self):
        changes, emis = expect_only(self._release(), 'changes', 'emissions')
        self._hold_via_changes(changes)

    def expect_only_change_with_head(self, *head):
        resp = self._release()
        changes = expect_only_changes(resp)
        change, = changes
        act = change[0:len(head)]
        self._TC.assertSequenceEqual(act, head)
        self._hold_via_changes(changes)

    def expect_only_these_areas_changed(self, *these):
        resp = self._release()
        changes = expect_only_changes(resp)  # change focus
        resp = self._IC.apply_changes(changes)
        cv = expect_only_changed_visually(resp)
        assert_set_equals(cv, set(these))

    def expect_only_changed_visually(self, *these):
        resp = self._release()
        cv = expect_only_changed_visually(resp)
        assert_set_equals(cv, set(these))

    # == Confirm line output, does not change state

    def expect_to_see_button(self, label):
        self.DEBUG_DUMP(f"You should see button: {label!r}")
        if self._is_ready:
            return  # meh
        resp = self._release()  # not sure
        expect_only_changed_visually(resp)

    def expecting_to_see_line_containing(self, needle):
        assert self._do_debug
        self.DEBUG_DUMP(f"expect to see line containing {needle!r}")

    def expect_to_see_adjacent_lines_containing(self, *needles):
        assert self._do_debug
        self.DEBUG_DUMP(f"expect to see adjacent lines: {needles!r}")

    # ==

    def screenshot(self):  # EXPERMENTAL
        if self._is_ready:
            emis, cv = None, None
        else:
            def add_cv(k):
                cv[k] = None
            emis, cv = [], {}
            accum = {'emissions': emis.append, 'changed_visually': add_cv}
            for k, v in self._do_apply_recursive(self._release()):
                accum[k](v)
            emis = tuple(emis) if emis else None
            cv = tuple(cv.keys()) if cv else None

        rows = tuple(self._area.to_rows())
        return _Screenshot(rows, emis, cv)

    def _apply_recursive(self, resp):
        while True:
            changes = resp.changes
            if not changes:
                break
            resp = self._IC.apply_changes(changes)

    def _do_apply_recursive(self, resp):
        while True:
            if resp.emissions:
                for emi in resp.emissions:
                    yield 'emissions', emi
            if (cv := resp.changed_visually):
                for k in cv:
                    yield 'changed_visually', k
            if (changes := resp.changes):
                resp = self._IC.apply_changes(changes)
                continue
            break

    def _hold_via_changes(self, changes):
        self._hold(self._IC.apply_changes(changes))

    def _hold(self, resp):
        if not self._is_ready:
            raise RuntimeError("oops, not expecting input. process response")
        self._is_ready = False
        self._response = resp

    def _release(self):
        assert not self._is_ready
        self._is_ready = True
        res = self._response
        self._response = None
        return res

    def DEBUG_DUMP(self, msg):
        o = print

        if self._do_output_this_one_thing:
            self._do_output_this_one_thing = False
            o('')

        o(f"\n{msg}:")
        for line in self._area.to_rows():
            o(line)

    @property
    def _do_debug(self):
        return self._TC.do_debug


# ==

class _Screenshot:  # EXPERIMENTAL

    def __init__(self, rows, emis, cvs):
        self.rows = rows
        self.emissions = emis
        self.changed_visually = cvs

        self._the_row_index = None

    @property
    def content_with_focus(self):
        return self.classified_row_with_focus.content  # ..

    @property
    def content_strings(self):
        return self._row_index.content_strings

    @property
    def classified_row_with_focus(self):
        return self._row_index.classified_row_with_focus

    def classified_row_at(self, offset):
        return self._row_index.classified_row_at(offset)

    @property
    def button_labels(self):
        return self._row_index.button_labels

    @property
    def _row_index(self):
        if self._the_row_index is None:
            self._the_row_index = _RowIndex(self.rows)
        return self._the_row_index

    def DUMP(self, msg=None):
        if msg:
            print(''.join(('\n\n', msg, ':')))
        for row in self.rows:
            print(row)


class _RowIndex:

    def __init__(self, rows):
        re = _re()
        _looks_like_button_line = re.compile(r'\[[a-z]+\]').search  # meh
        _looks_like_blank_line = re.compile(r'[ ]+\Z').match

        rows = list(rows)
        button_rows = []
        while _looks_like_button_line(rows[-1]):
            button_rows.append(rows.pop())
        self._do_index_buttons = True
        self._button_rows = button_rows

        blank_lines_count = 0
        while _looks_like_blank_line(rows[-1]):
            rows.pop()
            blank_lines_count += 1

        offset_of_cr_with_focus = None
        crs = []
        for row in rows:
            offset = len(crs)
            cr = _ClassifiedRow(row, offset+1)
            if cr.has_focus:
                if offset_of_cr_with_focus is not None:
                    xx('multiple rows with focus')
                offset_of_cr_with_focus = offset
            crs.append(cr)

        self._offset_of_CR_with_focus = offset_of_cr_with_focus
        self._classified_rows = tuple(crs)
        self._content_strings = None

    @property
    def content_strings(self):
        if self._content_strings is None:
            self._content_strings = tuple(self._do_content_strings())
        return self._content_strings

    def _do_content_strings(self):
        crs = self._classified_rows
        sig = ''.join(cr.shortcode for cr in crs)
        if not _re().match(r'N?LC*\Z', sig):
            xx(f'oops: {sig!r}')
        return (cr.content for cr in crs if cr.looks_like_item)

    @property
    def classified_row_with_focus(self):
        return self.classified_row_at(self._offset_of_CR_with_focus)

    def classified_row_at(self, offset):
        return self._classified_rows[offset]

    @property
    def button_labels(self):
        if self._do_index_buttons:
            self._do_index_buttons = False
            self._button_labels = set(self._index_buttons())
        return self._button_labels

    def _index_buttons(self):
        re = _re()
        rows = self._button_rows
        del self._button_rows
        for row in rows:
            for md in re.finditer('[^ ]+', row):
                label = md[0]
                assert '[' in label
                yield label


class _ClassifiedRow:

    def __init__(self, row, lineno):
        left = row[0:3]  # ..
        rest = row[3:]  # ..
        self.has_focus = not all(' ' == s for s in left)

        assert ' ' != rest[1]  # ..
        content = rest.strip()

        self.looks_like_nav_area = False
        self.looks_like_label_row = False
        self.looks_like_item = False  # .. this is so .. .. overly familiar

        if '>' in content:
            self.shortcode = 'N'
            self.looks_like_nav_area = True
        elif ':' == content[-1]:
            self.shortcode = 'L'
            self.looks_like_label_row = True
        else:
            self.shortcode = 'C'
            self.content = content
            self.looks_like_item = True

        self.lineno = lineno


# == For Assertion

def buttons_top_row(cca):
    rows = tuple(cca.HARNESS_AT('buttons').to_rows())  # ..
    return rows[0]


# ==

def expect_only_changed_visually(resp):
    return expect_only(resp, 'changed_visually')


def expect_only_changes(resp):
    return expect_only(resp, 'changes')


def expect_only_emissions(resp):
    return expect_only(resp, 'emissions')


def expect_only(resp, *attrs):
    exp = {'emissions': False, 'changes': False, 'changed_visually': None}
    for attr in attrs:
        exp[attr]  # validate name
        exp[attr] = True
    leng = len(attrs)
    results = [None for _ in range(0, leng)]
    for attr, yn in exp.items():
        x = getattr(resp, attr)
        if yn:
            if x is None:
                raise RuntimeError(f"expected but did not have '{attr}'")
            results[attrs.index(attr)] = x
        elif x is not None:
            raise RuntimeError(f"expected not to be set: '{attr}'")
    if 1 == leng:
        res, = results
        return res
    return results


def assert_set_equals(cv, st):
    act = set(cv)
    if act == st:
        return
    reason = f"not equal: {cv!r} {st!r}"
    raise RuntimeError(reason)

# ==


# == For Setup

def run_compound_area_via_definition(defn):
    func = _curses_adapter_module().run_compound_area_via_definition
    return func(defn)


def open_curses_session():
    return _top_module().build_this_crazy_context_manager_()


def input_controller_via_CCA(cca):  # cca = concrete compound area
    from script_lib.curses_yikes.compound_area_via_children import \
        input_controller_via_CCA_ as func
    return func(cca)


def concretize(h, w, aa, listener=None):
    return aa.concretize_via_available_height_and_width(h, w, listener)


def function_for_building_abstract_compound_areas():
    from script_lib.curses_yikes import compound_area_via_children as modul
    return modul.abstract_compound_area_via_children_


def common_exception_class():
    return _top_module().MyException_


def _curses_adapter_module():
    import script_lib.curses_yikes.curses_adapter as module
    return module


def _top_module():
    from script_lib import curses_yikes as module
    return module


def _re():
    import re as mod
    return mod


def xx(msg=None):
    raise RuntimeError(''.join(('cover me', *((': ', msg) if msg else ()))))

# #history-B.4 spike "long story" facility and screenshots
# #born
