from modality_agnostic.memoization import memoize


class CUD_BIG_SUCCESS_METHODS:

    def expect_reason(self, msg=None):
        reason = self.expect_request_error()['reason']
        if msg is None:
            return reason
        self.assertEqual(reason, msg)

    def expect_request_error(self):
        return self._expect_error('request_error')

    def expect_input_error(self):
        return self._expect_error('input_error')

    def _expect_error(self, s):
        chan, sct = self.expect_error_structure()
        self.assertEqual(chan, ('error', 'structure', s))
        return sct

    def expect_error_structure(self):
        from . import structured_emission as se_lib
        chan, payloader = se_lib.one_and_none(self.given_run, self)
        return chan, payloader()

    def expect_big_success(self):
        listener = None  # _DEBUGGING_LISTENER
        _mde = self.given_run(listener)

        def f():  # TO_BODY_BLOCK_LINES
            for blk in _mde.to_body_block_stream_as_MDE_():
                for line in blk.to_line_stream():
                    yield line

        _act = tuple(f())

        _big_s = self.expect_entity_body_lines()
        _exp = tuple(_unindent(_big_s))

        self.assertSequenceEqual(_act, _exp)

    def given_run(self, listener):  # formerly "run_CUD_attributes"

        this_listener = None  # _DEBUGGING_LISTENER

        from . import _common_state as lib

        _lines = _unindent(self.given_entity_body_lines())
        _tslo = lib.TSLO_via('A', 'meta')
        mde = lib.MDE_via_lines_and_table_start_line_object(
            _lines, _tslo, this_listener)
        assert(mde)

        req = request_via_tuples(self.given_request_tuples(), this_listener)
        assert(req)

        x = req.edit_mutable_document_entity_(
            mde, _default_business_schema(), listener)

        if x is not None:
            self.assertEqual(x, True)
            return mde


class CUD_Methods:

    # == DSL-ish for test assertions

    def entity_file_rewrite(self):
        return self.recorded_file_rewrites()[0]  # (per [#867.Q], is first)

    def index_file_rewrite(self):
        return self.recorded_file_rewrites()[1]  # (per [#867.Q], is second)

    # == setup

    # -- CUD expecting success

    def create_expecting_success(self, cuds):
        return self._recording_of_success(_function_for_create(cuds))

    def update_expecting_success(self, id_s, cuds):
        return self._recording_of_success(_function_for_update(id_s, cuds))

    def delete_expecting_success(self, id_s):
        return self._recording_of_success(_function_for_delete(id_s))

    # -- CUD expecting failure and recording

    def delete_expecting_failure_and_recordings(self, id_s):
        return self._struct_and_recording_of_fail(_function_for_delete(id_s))

    # -- CUD expecting failure

    def create_expecting_failure(self, wats, rng):
        return self._payload_of_failure(_function_for_create(wats, rng))

    def delete_expecting_failure(self, id_s):
        return self._payload_of_failure(_function_for_delete(id_s))

    # == THESE

    def _recording_of_success(self, f):

        col = self.subject_collection()
        fs = col._filesystem
        listener = self.listener()

        # --

        res = f(col, listener)
        self.assertTrue(res)  # :#here1

        return fs.FINISH_AS_HACKY_SPY()

    def _payload_of_failure(self, f):
        col = self.subject_collection()

        def use_f(listener):
            return f(col, listener)
        return self.run_this_expecting_failure(use_f)

    def _struct_and_recording_of_fail(self, f):

        col = self.subject_collection()
        fs = col._filesystem

        def use_f(listener):
            return f(col, listener)

        sct = self.run_this_expecting_failure(use_f)
        recs = fs.FINISH_AS_HACKY_SPY()
        return (sct, recs)

    def run_this_expecting_failure(self, f):  # #open #[867.H] DRY these
        count = 0
        only_emission = None

        def listener(*a):
            nonlocal count
            nonlocal only_emission
            count += 1
            if 1 < count:
                self.fail('too many emissions')
            only_emission = a

        res = f(listener)
        self.assertIsNone(res)  # [#867.R] provision: None not False :#here2
        self.assertEqual(count, 1)

        *chan, payloader = only_emission
        chan = tuple(chan)
        # ..

        mood, shape, error_type = chan
        self.assertEqual(mood, 'error')
        self.assertEqual(shape, 'structure')
        self.assertIn(error_type, ('input_error', 'request_error'))

        return payloader()


# == public functions

def request_via_tuples(tuples, listener):
    from kiss_rdb.magnetics_ import CUD_attributes_request_via_tuples as lib
    return lib.request_via_tuples(tuples, listener)


# == memoized

@memoize
def _default_business_schema():
    from kiss_rdb.magnetics_ import business_schema_via_definition as lib
    return lib.DEFAULT_BUSINESS_SCHEMA


# ==

def _function_for_create(cuds):

    def f(col, listener):
        return col.create_entity(cuds, listener)
    return f


def _function_for_update(id_s, cuds):
    def f(col, listener):
        return col.update_entity(id_s, cuds, listener)
    return f


def _function_for_delete(id_s):
    def f(col, listener):
        return col.delete_entity(id_s, listener)
    return f


# ==

def filesystem_expecting_no_rewrites():
    return _fs_lib().filesystem_expecting_no_rewrites()


def build_filesystem_expecting_num_file_rewrites(expected_num):
    return _fs_lib().build_filesystem_expecting_num_file_rewrites(expected_num)


def _fs_lib():
    from . import filesystem_spy as _
    return _


def _DEBUGGING_LISTENER(self):
    from . import structured_emission as lib
    return lib.debugging_listener()


def _unindent(big_string):
    from . import structured_emission as se_lib
    return se_lib.unindent(big_string)

# ==

# #abstracted.
