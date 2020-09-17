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
from modality_agnostic.test_support.common import (
        dangerous_memoize_in_child_classes as shared_subject_in_child_classes,
        lazy)
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
        es = self.end_state
        self.assertIsNone(es['result_value'])  # NOTE sneak this in somehwere

    def emits_error_context(self, **expect_dct):
        dct = self.end_state['payload']
        for k, v in expect_dct.items():
            _actual = dct[k]  # ..
            self.assertEqual(_actual, v)
        self.assertEqual(dct['path'], same_schema_path)

    # -- setup

    @shared_subject_in_child_classes('_end_state', 'build_end_state')
    def end_state(self):
        pass  # see the decorator

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
        def opn(path_arg):
            # (path_arg is never coll path it's schema file path under path)
            return fs.open_file_for_reading(path_arg)

        # Execute
        rv = collectioner().collection_via_path(path, listener, opn)

        # Finish by assembling the result structure
        dct = {'result_value': rv}
        if len(emissions):
            dct['did_emit'] = True
            emi, = emissions
            dct['channel'], pay = emi.channel, emi.payloader
            dct['payload'] = pay()
        else:
            dct['did_emit'] = False
        return dct

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


class Case1422_directory_based_money(CommonCase):

    def test_100_full_round_trip_works(self):
        ae = self.assertEqual
        es = self.build_end_state()
        self.assertFalse(es['did_emit'])
        rv = es['result_value']
        rv = unwrap_collection(rv)
        ae(rv['message for the test'], 'hello from storage adapter 1')
        ae(rv['also this'], "it's me, this one test")

    def given_fake_filesystem(self):

        def these_lines():
            yield '# comment'
            yield ''
            yield 'storage_adapter: storo_adapto_1'
            yield ''
            yield '# comment 2'
            yield ''
            yield 'valley_for_storo_1: it\'s me, this one test'
            yield ''
            yield 'valley_for_storo_1_B: true'
            yield ''

        return build_fake_filesystem(
                ('directory', 'abc/xyz'),
                ('file', same_schema_path, these_lines))


class Case1423_single_file_based_money(CommonCase):

    def test_100_the_SA_can_emit(self):
        es = self.end_state
        self.assertSequenceEqual(
                es['channel'], ('info', 'structure', 'hi_from_SA_2'))
        self.assertEqual(es['payload']['message'], 'SA2')

    def test_200_the_SA_can_result(self):
        _rv = self.end_state['result_value']
        _rv = unwrap_collection(_rv)
        self.assertEqual(_rv, (
            "hello from storo adapto 2. you know you want this - abc/xyz.xtc"))

    def given_fake_filesystem(self):
        return build_fake_filesystem(('file', 'abc/xyz.xtc'))


# == Support Test Assertions

def error_category_for_no_schema_file():
    return 'cannot_load_collection', 'no_schema_file'


def message_about_no_schema_for(coll_path):
    return f"No such file or directory: '{coll_path}/schema.rec'"


# == Support Test Setup

@lazy
def collectioner():
    from kiss_rdb.magnetics_.collection_via_path import (
            collectioner_via_storage_adapters_module)

    # #wish look into module reflection

    import os.path as os_path
    dn = os_path.dirname
    _ = os_path.join(dn(dn(__file__)), 'fixture_code', '_1416_SAs', '_33_SAs')

    return collectioner_via_storage_adapters_module(
            module_name='kiss_rdb_test.fixture_code._1416_SAs._33_SAs',
            module_directory=_)


def unwrap_collection(coll):
    return coll._impl  # ick/meh


same_schema_path = 'abc/xyz/schema.rec'


if __name__ == '__main__':
    unittest.main()

# #history-B.1
# #born.
