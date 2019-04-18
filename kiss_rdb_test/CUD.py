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
    from kiss_rdb_test import filesystem_spy as _
    return _


# ==

# #abstracted.
