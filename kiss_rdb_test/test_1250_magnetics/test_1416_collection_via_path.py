"""DISCUSSION - This discussion is happening with a blank file and no idea

what we want in it. It's called "schema intro." The objective is to realize
true "storage adapter" injection for one-off style invocations of all of
CUD+RT.

👉 For the forseeable near future, each collection can be uniquely identified
by a *path* on the filesystem. (Yes we could get into thinking of it as
a "connection string" to some remote resource, but that's way out of scope.)

👉 We like the idea that given this "collecton path", we look and see if it
looks like it has an extension on the filename. If yes, we assume it's a
single-file collection *with no schema*. Otherwise, we assume it's a directory
with a `schema.rec` file.

👉 For now, we're not gonna go down the execution path of single-file
collections EXCEPT FOR what we just thought of: a recfile is a single-file
collection, and that's a thing we're gonna use to load schema-having
collections.

👉 We have to differentiate between whether we're resolving a schema
(from a path) or whether we're resolving a collection (again from a path);
Let's think about that: it's like the pseudocode we sketched above. But we
want to get it to fit in with our cases..

👉 We like the idea of creating collections, so like a collections collection
(or hub). Let's imagine this as "collection via path" but walk through it
as if it's a storage adapter.

👉 Indeed we can imagine a "hub collection" that's guaranteed to be
constructable that represents all possible hubs (on the filesystem?). You
"retrieve" a *hub* with a path to the hub. This could either succeed or fail
based on if the path exits. But why. Really it's the hub we want to start with.

👉 realizing we can't use the canon directly because it's based on identifers,
but still we can use it as a guide.
"""


from kiss_rdb_test.filesystem_spy import build_fake_filesystem
import modality_agnostic.test_support.common as em
from modality_agnostic.test_support.common import \
        dangerous_memoize_in_child_classes as shared_subject_in_child_classes
import unittest


class CommonCase(unittest.TestCase):

    # -- assertions against end state

    def emits_error_case(self, ec):
        self.emits_error_category('cannot_load_collection', ec)

    def emits_error_category(self, ec, *error_case):  # C/P, modified
        self._sneak_in_confirmation_of_no_result_value()
        chan = self.end_state['channel']
        expect = ('error', 'structure', ec, *error_case)
        self.assertSequenceEqual(chan, expect)

    def emits_reason(self, reason):
        self.emits_component('reason', reason)

    def emits_component(self, key, expected_value):
        dct = self.end_state['payload']
        self.assertEqual(dct[key], expected_value)

    def _sneak_in_confirmation_of_no_result_value(self):
        act = self.end_state_result
        self.assertIsNone(act)  # NOTE sneak this in somehwere

    @property
    def end_state_result(self):
        return self.end_state['end_state_result']

    def emits_error_context(self, **expect_dct):
        dct = self.end_state['payload']
        for k, v in expect_dct.items():
            _actual = dct[k]  # ..
            self.assertEqual(_actual, v)
        self.assertEqual(dct['path'], same_schema_path)

    # -- setup

    @property
    @shared_subject_in_child_classes
    def end_state(self):
        return self.build_end_state()

    def build_end_state(self):
        # The arguments to the SUT function: 1) coll path 2) listener 3) opn

        # Prepare the path argument
        # rather than memoize the filesystem for every case just for the
        # one case that does this one thing, we do this

        fs = self.given_fake_filesystem()
        assert fs
        if hasattr(self, 'given_path'):
            path = self.given_path()
        else:
            path = fs.first_path

        # Prepare the listener argument
        listener, emissions = em.listener_and_emissions_for(self, limit=1)

        # Prepare the `opn` argument
        def opn(path_arg, mode=None):
            if mode:
                msg = "we assume you aren't actually writing.."
                return pass_thru_cm((msg, path))
            return fs.open_file_for_reading(path_arg)

        # Execute
        rv = self.given_run(listener, path, opn)

        # Finish by assembling the result structure
        dct = {'end_state_result': rv}
        if len(emissions):
            dct['did_emit'] = True
            emi, = emissions
            dct['channel'], pay = emi.channel, emi.payloader
            dct['payload'] = pay()
        else:
            dct['did_emit'] = False
        return dct

    def given_run(self, listener, *coll_args):
        x = self.load_collection(*coll_args, listener)
        if x is not None:
            raise RuntimeError("ohai")
        return x

    def load_collection(self, path, opn, listener):
        return collectioner().collection_via_path(path, listener, opn=opn)

    do_debug = False


class Case1409_collection_not_found(CommonCase):

    def test_050_sanity_regressionpoint(self):
        self.assertIsNotNone(collectioner())

    def test_100_channel(self):
        self.emits_error_category(*error_category_for_no_schema_file())

    def test_200_reason(self):
        self.emits_reason(message_about_no_schema_for(self.given_path()))

    def given_path(self):
        return 'this-path/is-no-ent'

    def given_fake_filesystem(self):
        return build_fake_filesystem()  # the only one bwe


class Case1410_has_strange_extension(CommonCase):

    def test_100_channel(self):
        self.emits_error_case('unrecognized_extname')

    def test_200_reason(self):
        self.emits_reason(
            "unrecognized extension '.fizzy'. "
            "known extension(s): ('.qkr', '.xtc')")

    def given_fake_filesystem(self):
        return build_fake_filesystem(('file', 'abc/xyz.fizzy'))


class Case1411_has_no_extension_and_is_not_directory(CommonCase):
    # (this used to be more detailed before #history.B-1 but not is better)

    def test_100_channel(self):
        self.emits_error_category(*error_category_for_no_schema_file())

    def test_200_reason(self):
        self.emits_reason(message_about_no_schema_for('abc/xyz'))

    def given_fake_filesystem(self):
        return build_fake_filesystem(('file', 'abc/xyz'))


class Case1413_is_directory_but_no_schema_file(CommonCase):

    def test_100_channel(self):
        self.emits_error_case('no_schema_file')

    def test_200_reason(self):
        self.emits_reason(f"No such file or directory: '{same_schema_path}'")

    def given_fake_filesystem(self):
        return build_fake_filesystem(('directory', 'abc/xyz'))


class Case1414_schema_file_invalid(CommonCase):

    def test_100_channel(self):
        self.emits_error_category('input_error')

    # NOTE no reason

    def test_300_whines_with_fully_contextualzed_parse_error(self):
        self.emits_error_context(
                expecting='colon',
                position=2,
                line='xx yy zz\n',
                lineno=1)

    def given_fake_filesystem(self):

        def these_lines():
            # yield '' adding 1 or more blank/comments covers a nearby spot
            # yield '#'
            yield 'xx yy zz'
            raise Exception('no see')

        return build_fake_filesystem(
                ('directory', 'abc/xyz'),
                ('file', same_schema_path, these_lines))


class _LiterallyOrActually(CommonCase):

    def whines_specifically_for(self, adverb):

        self.emits_error_case('first_field_of_schema_file_not_found')

        self.emits_component('path', same_schema_path)

        self.emits_reason(
            f'schema file is {adverb} empty - {same_schema_path}')

    def given_fake_filesystem(self):

        def these_lines():
            return iter(())

        return build_fake_filesystem(
                ('directory', 'abc/xyz'),
                ('file', same_schema_path, self.given_lines))


class Case1415_schema_file_literally_empty(_LiterallyOrActually):

    def test_100_whines_specifically(self):
        self.whines_specifically_for('literally')

    def given_lines(self):
        return iter(())


# #midpoint


class Case1417_schema_file_effectively_empty(_LiterallyOrActually):

    def test_100_whines_specifically(self):
        self.whines_specifically_for('effectively')

    def given_lines(self):
        yield ''
        yield '#'


class Case1418_schema_does_not_indicate_SA_in_first_field(CommonCase):

    def test_100_channel(self):
        self.emits_error_case('unexpected_first_field_of_schema_file')

    def test_200_reason(self):
        self.emits_component('expecting', '"storage_adapter" as field name')

    def test_300_error_context(self):
        self.emits_error_context(
            lineno=3,
            position=0,
            line="favorite_food: hommous\n")

    def given_fake_filesystem(self):
        def these_lines():
            yield '# comment'
            yield ''
            yield 'favorite_food: hommous'
            raise Exception('no see')
        return build_fake_filesystem(
                ('directory', 'abc/xyz'),
                ('file', same_schema_path, these_lines))


class Case1419_has_schema_that_indicates_SA_but_unknown_SA(CommonCase):

    def test_100_channel(self):
        self.emits_error_case('unknown_storage_adapter')

    def test_200_custom_stuff_for_long_reason(self):
        _reason = self.end_state['payload']['reason']
        line1, li2 = _reason.split('. ')
        self.assertEqual(line1, "unknown storage adapter 'xx yy'")
        self.assertEqual(
                li2,
                "known storage adapters: ('storo_adapto_1', 'storo_adapto_2')")

    def test_300_error_context(self):
        self.emits_error_context(
            lineno=3,
            position=17,
            line='storage_adapter: xx yy\n')

    def given_fake_filesystem(self):

        def these_lines():
            yield '# comment'
            yield ''
            yield 'storage_adapter: xx yy'
            raise Exception('no see')

        return build_fake_filesystem(
                ('directory', 'abc/xyz'),
                ('file', same_schema_path, these_lines))


class Case1421_schema_indicates_SA_thats_single_file_only(CommonCase):

    def test_100_channel(self):
        self.emits_error_case('storage_adapter_is_not_directory_based')

    def test_200_custom_stuff_for_long_reason(self):
        _reason = self.end_state['payload']['reason']
        import re
        head, mid, ta = re.split(r'[.,][ ]', _reason)
        ae = self.assertEqual
        ae(head, "the 'storo_adapto_2' storage adapter is single-file only")
        ae(mid, 'so the collection cannot have a directory and a schema file')
        ae(ta, "the collection should be in a file ending in '.xtc' or '.qkr'")

    def test_300_error_context(self):
        self.emits_error_context(
            lineno=2,
            position=21,
            line='storage_adapter:     storo_adapto_2\n')

    def given_fake_filesystem(self):

        def these_lines():
            yield ''
            yield 'storage_adapter:     storo_adapto_2'  # #wish1
            raise Exception('no see')

        return build_fake_filesystem(
                ('directory', 'abc/xyz'),
                ('file', same_schema_path, these_lines))


class Case1422_single_file_based_money(CommonCase):

    # full overhaul at #history-B.4 for magnetic fields

    def test_100_you_can_touch_the_module(self):
        coll = self.end_state_result[0]
        assert 'storo_adapto_2' == coll.storage_adapter.key
        mod = coll.storage_adapter.module
        act = mod.OHAI
        assert "hello from storo adapto 2" == act

    def test_200_create_produces_adapters_choice_but_should_be_an_entity(self):
        wat = self.end_state_result[1]
        ohai, k, v = wat
        assert 'ohai_i_am_adapto_2_who_created_this_guy' == ohai
        assert 'felloo1' == k
        assert 'furry' == v['fim']

    def test_300_retrieve_produces_the_entity(self):
        ent = self.end_state_result[2]
        assert 'felloo1' == ent.identifier
        v = ent.core_attributes_dictionary_as_storage_adapter_entity['fim']
        assert 'furry' == v

    def given_fake_filesystem(self):
        lines = iter(('see but ignore\n',))
        return build_fake_filesystem(('file', 'abc/xyz.xtc', lambda: lines))

    def given_run(self, listener, *coll_args):
        return tuple(self.result_value_values_from_run(coll_args, listener))

    def result_value_values_from_run(self, coll_args, listener):
        coll = self.load_collection(*coll_args, listener)
        if coll is None:
            return
        yield coll
        wat = coll.create_entity({'fim': 'furry'}, listener)
        if not wat:
            return
        k = wat[1]
        yield wat
        wat = coll.retrieve_entity(k, listener)
        yield wat


class Case1423_directory_based_money(CommonCase):

    def test_100_you_can_touch_the_module(self):
        coll = self.end_state_result[0]
        assert 'storo_adapto_1' == coll.storage_adapter.key
        mod = coll.storage_adapter.module
        act = mod.OHAI
        assert "hello from storo adapto 1" == act

    def test_200_create_produces_adapters_choice_but_should_be_an_entity(self):
        wat = self.end_state_result[1]
        ohai, k, v = wat
        assert 'ohai_i_am_adapto_2_who_created_this_guy' == ohai
        assert 'Q001' == k
        assert 'furry' == v['fim']

    def test_300_retrieve_produces_the_entity_which_in_reality_should_be(self):
        wat = self.end_state_result[2]
        ohai, whatev = wat
        assert 'this_is_supposed_to_be_wrapped' == ohai
        assert 'furry' == whatev['fim']

    def given_fake_filesystem(self):

        def these_lines():
            yield '# comment'
            yield ''
            yield 'storage_adapter: storo_adapto_1'
            yield ''
            yield '# comment 2'
            yield ''
            yield 'idens_must_start_with_letter: Q'
            yield ''
            yield 'number_of_digits_in_idens: 3'
            yield ''

        return build_fake_filesystem(
                ('directory', 'abc/xyz'),
                ('file', same_schema_path, these_lines))

    def given_run(self, listener, *coll_args):
        return tuple(self.result_value_values_from_run(coll_args, listener))

    def result_value_values_from_run(self, coll_args, listener):
        coll = self.load_collection(*coll_args, listener)
        if coll is None:
            return
        yield coll
        wat = coll.create_entity({'fim': 'furry'}, listener)
        if not wat:
            return
        yield wat
        k = wat[1]
        wat = coll.retrieve_entity(k, listener)
        yield wat


# == Support Test Assertions

def error_category_for_no_schema_file():
    return 'cannot_load_collection', 'no_schema_file'


def message_about_no_schema_for(coll_path):
    return f"No such file or directory: '{coll_path}/schema.rec'"


# == Support Test Setup

def collectioner():
    from kiss_rdb_test.common_initial_state import didactic_collectioner as fun
    return fun()


def unwrap_collection(coll):
    return coll


def pass_thru_cm(x):  # #[#510.12] (lol)
    from contextlib import nullcontext as func
    return func(x)


same_schema_path = 'abc/xyz/schema.rec'


if __name__ == '__main__':
    unittest.main()

# #history-B.4
# #history-B.1
# #born.
