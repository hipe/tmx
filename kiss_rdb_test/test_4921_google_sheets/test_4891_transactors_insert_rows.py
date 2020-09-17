from modality_agnostic.test_support.common import \
        dangerous_memoize as shared_subject, lazy
import unittest


CommonCase = unittest.TestCase


class Case4881_build_schema_with_cell_format(CommonCase):

    def test_100_builds(self):
        assert(schema_one())

    def test_200_cell_formats_look_like_this(self):
        o = schema_one().cell_formats
        x = o[0]['numberFormat']
        self.assertEqual(x['type'], 'DATE')
        self.assertEqual(x['pattern'][0:5], 'mm-dd')
        self.assertIsNone(o[2])


class Case4886_mock_a_real_life_insert(CommonCase):

    def test_100_result_is_transactor_result(self):
        self.assertEqual(self.end_state.result, "ohai i'm transactor")

    def test_200_lots_of_details_of_the_batch_requests(self):
        # the main objective of this is to "lock down" our somewhat complex
        # transaction that worked against a live sheet. We are hesitant to
        # refactor this out into smaller dedicated tests because of A) how
        # low-level they are vis-a-vis the google sheets API and B) how much
        # under active development the target use case is at writing

        reqs = self.end_state.requests

        # two requests
        self.assertEqual(len(reqs), 2)

        # one request for insert dimension, one for update cels
        def only_key(dct):
            only, = dct.keys()  # an implicit assertion
            return only

        names = tuple(only_key(dct) for dct in reqs)
        self.assertSequenceEqual(names, ('insertDimension', 'updateCells'))

        # touch some of the things of the update request
        uc = reqs[1]['updateCells']
        o = uc['range']
        _ = ('sheetId', 'startColumnIndex', 'endColumnIndex', 'startRowIndex')
        _4 = tuple(o[k] for k in _)
        self.assertSequenceEqual(_4, (0, 0, 3, 1))

        # the request to update cells is two rows long
        rows = uc['rows']
        self.assertEqual(len(rows), 2)

        # sparseness is handled by an empty
        def yes_or_nos_for_row(row):
            for dct in row['values']:
                assert(isinstance(dct, dict))
                yield 0 != len(dct)

        grid = tuple(tuple(yes_or_nos_for_row(row)) for row in rows)
        self.assertSequenceEqual(grid[0], (False, True, True))
        self.assertSequenceEqual(grid[1], (True, True, True))

    @shared_subject
    def end_state(self):
        lib = this_lib()
        sch = schema_one()
        tra = lib.asset_lib.LiveTransactor(None, None, None)  # wahoo

        class mock_tra:  # #as-namespace
            def insert_at_top(req):
                state.append(tra._build_requests_for_insert_at_top(req))
                return "ohai i'm transactor"

        col = lib.collection_via(mock_tra, sch)
        row = (None,   '14:56', 'ABC DEF')
        ro2 = ('05-03', '3:33', '323.45')
        roz = (row, ro2)
        state = []
        res = col.insert_records_at_top_natively(roz, None)

        class end_result:  # #as_namespace
            result = res
            requests, = state

        return end_result


def write_to_your_own_thing_as_main():
    lib = this_lib()
    sch = schema_one()
    tra = lib.live_transactor('spreadsheet-ID-AD')  # see head of previous file
    col = lib.collection_via(tra, sch)
    row = (None,       None, 'ABC DEF')
    ro2 = ('07-06', '13:14', '567.89')
    roz = (row, ro2)
    res = col.insert_records_at_top_natively(roz, debugging_listener)
    print(f"wow batch update response: {res}")


@lazy
def schema_one():
    cell_formats=(
        {
            'numberFormat': {
                'type': 'DATE',
                'pattern': 'mm-dd "yuppus"',
                }
            },
        {
            'numberFormat': {
                'type': 'TIME',
                'pattern': 'hh:mm "yessieree"',
                }

            },

        None)

    return this_lib().build_schema(
            sheet_name='no see this sheet name',
            cell_range='A2:C',
            cell_formats=cell_formats)


def this_lib():
    from kiss_rdb_test.google_sheets import transactor_lib
    return transactor_lib()


def debugging_listener(*args):
    from modality_agnostic.test_support.common import debugging_listener
    debugging_listener()(*args)


if __name__ == '__main__':
    # visual tests against live sheets:
    # write_to_your_own_thing_as_main()

    unittest.main()

# #born.
