from modality_agnostic.memoization import lazy


@lazy
def transactor_lib():
    from kiss_rdb.storage_adapters_ import google_sheets as lib

    # components needed to build transactors

    from kiss_rdb_test.common_initial_state import functions_for
    fixtures = functions_for('google_sheets')
    fixture_directories_directory = fixtures.fixture_directories_directory
    recs = lib.Recordings(fixture_directories_directory)

    import os
    cypher = lib.Cypher(os.environ)

    class Lib:

        def native_records_via(self, listener, tra, sheet_name=None):
            if sheet_name is None:
                sch = common_schema
            else:
                sch = self.build_schema(
                        sheet_name=sheet_name, cell_range='A2:E')

            col = self.collection_via(tra, sch)
            return col.values_get_all_native_records(listener)

        def collection_via(_, transactor, schema):
            return lib.Collection(transactor, schema)

        @property
        def common_schema(_):
            return common_schema

        def build_schema(_, **kwargs):
            return lib.Schema(**kwargs)

        def live_transactor(_, ss_ID_ID):
            ss_iden = lib.SpreadsheetIdentifierEXPERIMENTAL(
                    spreadsheet_ID_ID=ss_ID_ID)
            ss_ID = cypher.spreadsheet_ID_via_identifier(ss_iden)
            return lib.LiveTransactor(
                    spreadsheet_ID=ss_ID,
                    token_path=lib.SERIALIZED_OAUTH_TOKEN_PATH,
                    credentials_path=lib.OAUTH_CREDENTIALS_PATH)

        def write_recordings_transactor_via_transactor(_, ss_ID_ID, tra):
            return lib.RecordingWritingTransactor(ss_ID_ID, tra, recs)

        def read_recording_transactor(_, ss_ID_ID):
            ss_ID = lib.SpreadsheetIdentifierEXPERIMENTAL(
                    spreadsheet_ID_ID=ss_ID_ID)
            return lib.RecordingReadingTransactor(recs, ss_ID, cypher)

        def in_memory_stub_transactor_via_function(_, f):
            ss_ID = lib.SpreadsheetIdentifierEXPERIMENTAL(
                    spreadsheet_ID_ID='spreadsheet-ID-AA')
            return lib.InMemoryStubTransactor(f, ss_ID, cypher)

        def wahoo(_, itr):
            for x in itr:
                print(f'wahoo: {x}')
            print('done.')

        @property
        def asset_lib(self):
            return lib

    res = Lib()

    common_schema = res.build_schema(
            sheet_name='sheet uno',
            cell_range='A2:E')

    return res

# #born.
