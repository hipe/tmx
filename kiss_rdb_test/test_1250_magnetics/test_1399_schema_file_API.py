"""DISCUSSION - This discussion will serve as a "real time" figuring out

of what we want from these probably two related modules this test will
serve.

👉 Normally a proper storage adapter would have its test suite in its own
dedicated node and not up here in with the mainline magnets. However, the
"recfiles" format is special because we use it to parse schema files and
those must come first before we can do anything interesting with collections.
As such, that part of the whole would-be recfiles storage adapter that serves
this effort is seen as having a higher [#010.6] regression precedence than
the suites for all other storage adapters.

👉 We want a minimally simple, pure-python solution for now, one that's
scaled down (and sideways) to our exact needs so we're rolling our own tiny
sub-implementaton. (In some future where we properly bridge to the GNU
recutils project, we would strongly consider refactoring the implementaton.)

👉 The flagship endgoal of this is the hackish config parser

👉 Before that: recfile scanner

👉 Then: schema scanner via recfile scanner

"""


from kiss_rdb_test.filesystem_spy import build_fake_filesystem
import modality_agnostic.test_support.common as em
from modality_agnostic.test_support.common import \
        dangerous_memoize_in_child_classes as shared_subject_in_child_classes
import unittest


class CommonCase(unittest.TestCase):

    # -- assertons against end state

    def emits_error_category(self, ec):
        es = self.end_state
        self.assertIsNone(es['result_value'])  # NOTE sneak this in somehwere
        chan = es['channel']
        expect = ('error', 'structure', ec)
        self.assertSequenceEqual(chan, expect)

    def emits_expectaton_of(self, surface_string):
        self.emits_component('expecting', surface_string)

    def emits_reason(self, reason):
        self.emits_component('reason', reason)

    def emits_component(self, key, expected_value):
        dct = self.end_state['payload']
        self.assertEqual(dct[key], expected_value)

    def emits_error_context(self, **expect_dct):
        dct = self.end_state['payload']
        for k, v in expect_dct.items():
            _actual = dct[k]  # ..
            self.assertEqual(_actual, v)
        self.assertEqual(dct['path'], same_path)

    # -- one-off assertions (no memoized end state)

    def scans_as_empty_file(self):
        scn = self.build_schema_scanner()
        tok = scn.next_field(_throwing_listener())
        self.assertTrue(tok.is_end_of_file)

    # -- setup

    @shared_subject_in_child_classes('_end_state', 'build_end_state')
    def end_state(self):
        pass

    def build_end_state(self):
        listener, emissions = em.listener_and_emissions_for(self, limit=1)
        rv = self.given_run(listener)
        dct = {}
        if len(emissions):
            dct['did_emit'] = True
            emi, = emissions
            chan, pay = emi.channel, emi.payloader
            dct['channel'] = chan
            dct['payload'] = pay()
        else:
            dct['did_emit'] = False
        dct['result_value'] = rv
        return dct

    def build_schema_scanner(self):
        scn = self.build_recfile_scanner()
        from kiss_rdb.magnetics_.schema_file_scanner_via_recfile_scanner import (  # noqa: E501
                schema_file_scanner_via_recfile_scanner)
        return schema_file_scanner_via_recfile_scanner(scn)

    def build_recfile_scanner(self):
        fs = build_fake_filesystem(('file', same_path, self.given_lines))
        fake_file = fs.open_file_for_reading(fs.first_path)
        from kiss_rdb.storage_adapters_.rec import ErsatzScanner
        return ErsatzScanner(fake_file)

    do_debug = False


class Case1395_literally_empty_file(CommonCase):

    def test_100_scans_as_empty(self):
        self.scans_as_empty_file()

    def given_lines(self):
        return iter(())


class Case1396_effectively_empty_file(CommonCase):

    def test_100_scans_as_empty(self):
        self.scans_as_empty_file()

    def given_lines(self):
        yield '# comment'
        yield ''


class Case1398_parse_error(CommonCase):

    def test_100_channel(self):
        self.emits_error_category('input_error')

    def test_200_expecting(self):
        self.emits_expectaton_of('colon')

    def test_300_error_context(self):
        self.emits_error_context(
                lineno=1,
                position=2,
                line='xx yy zz\n')

    def given_run(self, listener):
        return self.build_recfile_scanner().next_block(listener)

    def given_lines(self):
        yield 'xx yy zz'


class Case1399_fields_with_no_content_will_not_even_parse(CommonCase):
    """see discusson here"""
    #
    """
    We don't want to support even the possibility of this as a surface
    expession in the documents we parse. See [#873.5] no-value-ism.
    """
    # #midpoint-case

    def test_100_channel(self):
        self.emits_error_category('input_error')

    def test_200_expecting(self):
        self.emits_expectaton_of('some content')

    def test_300_error_context(self):
        self.emits_error_context(
                lineno=1,
                position=13,
                line='Some_Fellow: \n')

    def given_run(self, listener):
        return self.build_recfile_scanner().next_block(listener)

    def given_lines(self):
        yield 'Some_Fellow: '


class Case1400_yes_parse_field(CommonCase):

    def test_100_money(self):
        listener = _throwing_listener()
        scn = self.build_schema_scanner()
        field = scn.next_field(listener)
        blk = scn.next_field(listener)
        self.assertTrue(blk.is_end_of_file)
        assert(field.field_name == 'cha_cha')
        assert(field.field_value_string == 'la la')

    def given_lines(self):
        yield 'cha_cha: la la'


# room for troubleshooting:
# Case1395
# Case1396


class Case1403_flush_as_config_but_unrecognized_names(CommonCase):

    def test_100_channel(self):
        self.emits_error_category('unrecognized_config_attribute')

    def test_200_this_one_field_we_dont_ever_see(self):
        self.emits_component('reason_tail', "'fing_fang'")

    def test_300_error_context(self):
        self.emits_error_context(
                lineno=5,
                position=0,
                line='fing_fang: ff\n')

    def given_run(self, listener):
        scn = self.build_schema_scanner()
        return scn.flush_to_config(
                listener,
                bing_bang='allowed',
                ding_dang='required')

    def given_lines(self):
        yield '# comment'
        yield ''
        yield 'ding_dang: dd'
        yield 'bing_bang: bb'
        yield 'fing_fang: ff'
        yield 'no see'


class Case1404_flush_as_config_but_collision_across_records(CommonCase):

    def test_100_channel(self):
        self.emits_error_category(
                'config_field_names_cannot_occur_more_than_once_in_a_file')

    def test_200_reason(self):
        self.emits_reason("'One_mama' appears at least twice")

    def test_300_error_context(self):
        self.emits_error_context(
                lineno=4,
                position=0,
                line='One_mama: x\n')

    def given_run(self, listener):
        scn = self.build_schema_scanner()
        return scn.flush_to_config(
                listener,
                One_mama='allowed',
                Two_mama='allowed')

    def given_lines(self):
        yield 'One_mama: x'
        yield 'Two_mama: y'
        yield ''
        yield 'One_mama: x'
        yield 'no see'


class Case1406_flush_as_config_but_missing_requireds(CommonCase):

    def test_100_channel(self):
        self.emits_error_category('missing_required_config_fields')

    def test_200_reason(self):
        self.emits_component(
                'reason_tail', "'Field_A', 'Field_C', 'Field_E'")

    def test_300_error_context(self):
        self.emits_error_context()  # path

    def given_run(self, listener):
        scn = self.build_schema_scanner()
        return scn.flush_to_config(
                listener,
                Field_A='required',
                Field_B='allowed',
                Field_C='required',
                Field_D='allowed',
                Field_E='required',
                Field_F='allowed',
                Field_G='required')

    def given_lines(self):
        yield '# comment'
        yield ''
        yield 'Field_B: bb'
        yield 'Field_G: gg'


class Case1407_flush_as_config_money(CommonCase):

    def test_100_all_the_fields_are_there_plus_values(self):
        self.assertFalse(self.end_state['did_emit'])
        dct = self.result_value()
        assert('aa' == dct['Field_A'])
        assert('cc' == dct['Field_C'])
        assert('ee' == dct['Field_E'])
        assert('ff' == dct['Field_F'])
        assert('gg' == dct['Field_G'])

    def test_200_there_are_no_entries_for_those_formal_fields_not_passed(self):
        dct = self.result_value()
        self.assertIn('Field_A', dct)  # sanity check for the next tests
        self.assertNotIn('Field_B', dct)
        self.assertNotIn('Field_D', dct)

    def test_300_order_of_result_is_document_order_FOR_NOW(self):
        # we don't feel strongly about this one but might as well lock it
        _actual = tuple(s[-1] for s in self.result_value().keys())
        self.assertSequenceEqual(_actual, ('G', 'F', 'E', 'C', 'A'))

    def result_value(self):
        return self.end_state['result_value']

    def given_run(self, listener):
        scn = self.build_schema_scanner()
        return scn.flush_to_config(
                listener,
                Field_A='required',
                Field_B='allowed',
                Field_C='required',
                Field_D='allowed',
                Field_E='required',
                Field_F='allowed',
                Field_G='required')

    def given_lines(self):
        yield 'Field_G: gg'
        yield 'Field_F: ff'
        yield 'Field_E: ee'
        yield 'Field_C: cc'
        yield 'Field_A: aa'


def _throwing_listener():
    from modality_agnostic import listening
    return listening.throwing_listener


same_path = 'xx/yy.file'


if __name__ == '__main__':
    unittest.main()

# #born.
