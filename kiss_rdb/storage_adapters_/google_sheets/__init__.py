STORAGE_ADAPTER_CAN_LOAD_DIRECTORIES = False
STORAGE_ADAPTER_CAN_LOAD_SCHEMALESS_SINGLE_FILES = True
STORAGE_ADAPTER_ASSOCIATED_FILENAME_EXTENSIONS = ()
STORAGE_ADAPTER_IS_AVAILABLE = False
STORAGE_ADAPTER_UNAVAILABLE_REASON = "building backend (transactors) first"


SERIALIZED_OAUTH_TOKEN_PATH = 'token.pickle'  # will change
OAUTH_CREDENTIALS_PATH = 'credentials.json'  # will change


class Collection:

    def __init__(self, transactor, schema):
        self._transactor = transactor
        self._schema = schema

    def insert_records_at_top_natively(self, recs, listener):
        req = _InsertOrUpdateRequest(recs, listener, 'insert', self._schema)
        return self._transactor.insert_at_top(req)

    def values_get_all_native_records(self, listener):
        req = _GetAllRequest(listener, self._schema)
        return self._transactor.values_get(req)


class _CommonRequest:
    def _init_as_common_request(self, listener, schema):
        self.schema = schema
        self.listener = listener


class _InsertOrUpdateRequest(_CommonRequest):
    def __init__(self, records, listener, which, schema):
        assert('insert' == which)
        self.records = records
        self._init_as_common_request(listener, schema)


class _GetAllRequest(_CommonRequest):
    def __init__(self, listener, schema):
        self._init_as_common_request(listener, schema)


class LiveTransactor:

    def __init__(self, spreadsheet_ID, token_path, credentials_path):

        def build_sheet_API(listener):
            # if you modify these scopes, delete the file at token_path
            # scopes =['https://www.googleapis.com/auth/spreadsheets.readonly']

            scopes = ['https://www.googleapis.com/auth/spreadsheets']
            creds = _credentials_via(
                    token_path, credentials_path, scopes, listener)
            service = _service_via_credentials(creds)
            return service.spreadsheets()

        self._build_sheet_API = build_sheet_API
        self._spreadsheet_ID = spreadsheet_ID

    def insert_at_top(self, req):
        requests = self._build_requests_for_insert_at_top(req)
        spreadsheets = self._sheets_API(req.listener)
        return spreadsheets.batchUpdate(
                spreadsheetId=self._spreadsheet_ID,
                body={'requests': requests}).execute()

    def _build_requests_for_insert_at_top(self, req):  # #testpoint
        sch, recs = (getattr(req, k) for k in ('schema', 'records'))
        requests = []
        requests.append(_component_for_insert_dimension_request(recs, sch))
        requests.append(_component_for_update_cells_request(recs, sch))
        return requests

    def values_get(self, req):
        range_s = _full_range_string_via_schema(req.schema)
        spreadsheets = self._sheets_API(req.listener)
        result = spreadsheets.values().get(
                spreadsheetId=self._spreadsheet_ID, range=range_s,
                ).execute()
        return result.get('values', [])

    def _sheets_API(self, listener):
        if self._build_sheet_API is not None:
            f = self._build_sheet_API
            self._build_sheet_API = None
            self._sheets_API_value = f(listener)
        return self._sheets_API_value


def _component_for_insert_dimension_request(recs, schema):
    start, end = _start_end_row_index(len(recs), schema)  # #[#867.N]

    return {
        'insertDimension': {
            'range': {
                'sheetId': schema.sheet_ID,
                'startIndex': start,
                'endIndex': end,
                'dimension': 'ROWS',  # #[#867.N]
                },
            'inheritFromBefore': False,  # can't b true when insert at very top
            }
        }


def _component_for_update_cells_request(records, schema):
    assert('ROWS' == schema.dimension)

    num_fields = _effective_num_fields_with_sanity_check(records, schema)
    r = range(0, num_fields)

    cfs = schema.cell_formats or tuple(None for _ in r)

    assert(num_fields == len(cfs))  # per #here1. OK if change, but change here

    value_componenter_via_offset = \
        tuple(_value_componenter_via_cel_format(cfs[i]) for i in r)

    def row_component_for(rec):
        values = tuple(value_componenter_via_offset[i](rec[i]) for i in r)
        return {'values': values}

    row_components = tuple(row_component_for(rec) for rec in records)

    start_row_index, end_row_index = _start_end_row_index(len(records), schema)

    start_col_index, end_col_index = _start_end_col_index(schema)

    return {
        'updateCells': {
            'rows': row_components,
            'range': {
                'sheetId': schema.sheet_ID,
                'startRowIndex': start_row_index,
                'endRowIndex': end_row_index,
                'startColumnIndex': start_col_index,
                'endColumnIndex': end_col_index,
                },
            'fields': '*',  # #open [#873.21] understand this
            },
        }


def _value_componenter_via_cel_format(cf):

    def value_component_via(x):
        dct = {}
        if x is None:  # sparseness
            return dct  # for now we don't apply any formats. might change
        write_value_component(dct, x)
        if cf is not None:  # this check can be precomputed but it's not worth
            _write_user_entered_format_component(dct, cf)
        return dct

    if cf and (f := cf.get('numberFormat')) and f['type'] in _date_timey_types:
        write_value_component = _write_value_component_when_datetimey(f)
    else:
        write_value_component = _write_value_component_normally

    return value_component_via


_date_timey_types = {'DATE', 'TIME', 'DATE_TIME'}


def _write_value_component_when_datetimey(number_format_component):
    # "Dates, Times and DateTimes are represented as doubles in serial number format" from  # noqa: E501
    # https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/cells#CellData  # noqa: E501

    def write_value_component(dct, x):
        use_x = convert(x)
        _ = _user_entered_value_component_via(use_x, 'numberValue')
        _write_user_entered_value_component(dct, _)

    typ, pattern = (number_format_component[k] for k in ('type', 'pattern'))

    import datetime as dt  # heavily modified adaptation of SO #9574793 below

    if typ == 'DATE':
        now = dt.datetime.now()  # what year is it
        excel_serial_date_epoch_start = dt.date(1899, 12, 30)

        def convert(x):
            if '' == x:
                return None  # .. #cover-me visual confirmed from live
            mine = dt.datetime.strptime(x, '%m-%d')  # ..
            use = dt.date(now.year, mine.month, mine.day)
            delta = use - excel_serial_date_epoch_start
            return float(delta.days)

    elif typ == 'TIME':
        def convert(x):
            if '' == x:
                return None  # .. #cover-me visual confirmed from live
            mine = dt.datetime.strptime(x, '%H:%M')  # ..
            previous_midnight = dt.datetime(mine.year, mine.month, mine.day)
            delta = mine - previous_midnight
            return delta.seconds / 86400.0  # year etc is 1900, is that okay?

    else:
        assert('DATE_TIME' == typ)
        do_me()

    return write_value_component


def _write_value_component_normally(dct, x):
    _ = _extended_value_key_via_type_of(x)
    _ = _user_entered_value_component_via(x, _)
    _write_user_entered_value_component(dct, _)


def _write_user_entered_format_component(dct, cf):
    dct['userEnteredFormat'] = cf


def _write_user_entered_value_component(dct, uevc):
    dct['userEnteredValue'] = uevc


def _user_entered_value_component_via(x, extended_value_key):
    return {extended_value_key: x}


def _extended_value_key_via_type_of(x):
    typ = type(x)
    if str == typ:
        return 'stringValue'
    if int == typ or float == typ:
        return 'numberValue'
    if bool == typ:
        return 'boolValue'
    do_me()


def _effective_num_fields_with_sanity_check(records, schema):
    # we don't yet know what our API design will be for handling sparseness
    # in incoming records, so for now we err on the side of strictness

    num_new_records = len(records)
    assert(num_new_records)  # don't get this far inserting zero records

    requisite_length = schema.number_of_fields

    for i in range(0, num_new_records):
        assert(requisite_length == len(records[i]))  # for now

    return requisite_length


def _service_via_credentials(creds):
    from googleapiclient.discovery import build
    return build('sheets', 'v4', credentials=creds)


def _credentials_via(token_path, creds_path, scopes, listener):

    # (most of this logic (and some comments) are directly from the example)

    creds = None

    # load the stored credentials if they exist
    from os import path as os_path
    if os_path.exists(token_path):
        listener('debug', 'expression', 'load_token_with_pickle', None)
        with open(token_path, 'rb') as token:
            creds = _pickle().load(token)

    # if no creds to load or they're invalid, let the user log in
    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            listener('debug', 'expression', 'refreshing_credentials', None)
            from google.auth.transport.requests import Request
            creds.refresh(Request())
        else:
            listener('debug', 'expression', 'using_credentials', None)
            from google_auth_oauthlib.flow import InstalledAppFlow
            flow = InstalledAppFlow.from_client_secrets_file(
                    creds_path, scopes)
            creds = flow.run_local_server(port=0)

        # store the credentials so it can be re-used above
        with open(token_path, 'wb') as token:
            listener('debug', 'expression', 'writing_credentials', None)
            _pickle().dump(creds, token)

    return creds


def _pickle():
    import pickle
    return pickle


# ==== BEGIN EXPERIMENTAL HIGHER-LEVEL RECORDING API ====

def EXPERIMENT_RECORD(
        directory_for_recordings, spreadsheet_ID_ID, sheet_name, cell_range):

    cypher = build_live_cypher()
    si = SpreadsheetIdentifierEXPERIMENTAL(
            spreadsheet_ID_ID=spreadsheet_ID_ID)
    ss_ID = cypher.spreadsheet_ID_via_identifier(si)
    tr1 = _live_transactor_via(ss_ID)

    recs = Recordings(directory_for_recordings)
    tr2 = RecordingWritingTransactor(spreadsheet_ID_ID, tr1, recs)

    sch = Schema(sheet_name, cell_range)
    col = Collection(tr2, sch)

    return col.values_get_all_native_records(_debugging_listener())


def EXPERIMENT_READ(
        directory_for_recordings, spreadsheet_ID_ID, sheet_name, cell_range):

    cypher = build_live_cypher()
    si = SpreadsheetIdentifierEXPERIMENTAL(
            spreadsheet_ID_ID=spreadsheet_ID_ID)
    recs = Recordings(directory_for_recordings)
    tra = RecordingReadingTransactor(recs, si, cypher)
    sch = Schema(sheet_name, cell_range)
    col = Collection(tra, sch)

    return col.values_get_all_native_records(_debugging_listener())


def _live_transactor_via(ss_ID):
    return LiveTransactor(
            ss_ID, SERIALIZED_OAUTH_TOKEN_PATH, OAUTH_CREDENTIALS_PATH)


def _debugging_listener():
    from modality_agnostic.test_support.listener_via_expectations import \
        for_DEBUGGING as listener
    return listener


# ==== END


class RecordingWritingTransactor:

    def __init__(self, ss_ID_ID, tra, recs):
        self._transactor = tra
        self._ss_ID_ID = ss_ID_ID
        self._recordings = recs

    def values_get(self, req):
        lib = _recordings_lib()
        path = lib.path_via(req, self._ss_ID_ID, self._recordings)

        itr = self._transactor.values_get(req)

        if itr is None:
            do_me()

        with lib.open_recording(path, req.listener) as writer:
            for x in itr:
                writer.write_line_via_record(x)
                yield x


class RecordingReadingTransactor:

    def __init__(self, recordings, ss_iden, cypher):
        self._ss_ID_ID = cypher.spreadsheet_ID_ID_via_identifier(ss_iden)
        self._recordings = recordings

    def values_get(self, req):
        lib = _recordings_lib()
        path = lib.path_via(req, self._ss_ID_ID, self._recordings)
        return lib.values_via_path(path)


class Recordings:

    def __init__(self, path):
        self.path = path


def _recordings_lib():
    import json
    from os import path as os_path

    def _open_recording(path, listener):

        class Session:

            def __init__(self):
                pass

            def __enter__(self):
                return state.entered()

            def __exit__(self, *three):
                return state.exit(three)

        class State:

            def __init__(self):
                self._enter_mutex = None
                self._exit_mutex = None

            def entered(self):
                del self._enter_mutex

                def lineser():
                    yield f"opening for writing - {path}"
                listener('debug', 'expression', 'opening', lineser)

                self.opened = open(path, 'w')
                write_opening_lines()
                return Writer()

            def exit(self, three):
                del self._exit_mutex

                def lineser():
                    yield "closing recording file"
                listener('debug', 'expression', 'closing', lineser)

                write_closing_lines()
                x = self.opened.__exit__(*three)
                del self.opened
                return x

        class Writer:

            def write_line_via_record(self, xx):
                def lineser():
                    yield f"writing record for {xx}"
                listener('debug', 'expression', 'writing_line', lineser)
                line_content = json.dumps(xx)
                assert(eol not in line_content)
                state.opened.write(line_content)
                state.opened.write(eol)

        def write_opening_lines():
            import datetime
            s = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')
            w = state.opened.write
            w(f"# this file was machine-generated on {s}\n")
            w("# maybe don't edit this file directly unless "
              "you really know what you're doing\n")
            state.opened.write("\n")

        def write_closing_lines():
            state.opened.write(eol)
            state.opened.write("# #born.\n")

        state = State()
        return Session()

    def _values_via_path(path):
        with open(path, 'r') as lines:
            for value in _values_via_lines(lines):
                yield value

    def _values_via_lines(lines):
        for line in lines:
            if '#' == line[0]:
                continue
            if _eol == line:
                continue
            yield json.loads(line)

    def _path_via(req, ss_ID_ID, recs):
        sch = req.schema

        direc = os_path.join(recs.path, 'values_get')

        pieces = []
        pieces.append(ss_ID_ID)
        pieces.append(sch.sheet_name.lower().replace(' ', '-'))

        frm, to = sch.cell_range_string.split(':')
        pieces.append(f'{frm}-{to}')

        filename_head = '--'.join(pieces)

        filename = f'{filename_head}.json_lines'

        return os_path.join(direc, filename)

    eol = _eol

    class LIB:  # #as-namespace
        open_recording = _open_recording
        values_via_path = _values_via_path
        path_via = _path_via

    return LIB


class InMemoryStubTransactor:

    def __init__(self, function, ss_iden, cypher):

        def values_get(req):
            _ss_ID_ID = cypher.spreadsheet_ID_ID_via_identifier(ss_iden)
            return function('values_get', _ss_ID_ID, req)

        self._values_get = values_get

    def values_get(self, req):
        return self._values_get(req)


def build_live_cypher():
    from os import environ
    return Cypher(environ)


class Cypher:  # experimental: implement resolving ss ID's from env vars

    def __init__(self, environ):
        self._environ = environ

    def spreadsheet_ID_ID_via_identifier(self, ss_iden):
        if ('ID_ID' == ss_iden.identifier_type):
            return ss_iden.spreadsheet_ID_ID

        assert('ID' == ss_iden.identifier_type)
        do_me()

    def spreadsheet_ID_via_identifier(self, ss_iden):
        if ('ID' == ss_iden.identifier_type):
            return ss_iden.spreadsheet_ID

        assert('ID_ID' == ss_iden.identifier_type)
        s = ss_iden.spreadsheet_ID_ID
        md = _re_match('spreadsheet-ID-([A-Z]+)$', s)
        assert(md)  # ..

        env_name = f'TMX_SPREADSHEET_ID_{md[1]}'

        if (env_name not in self._environ):
            raise RuntimeError(f'set this env variable: {env_name}')

        return self._environ[env_name]


class SpreadsheetIdentifierEXPERIMENTAL:

    def __init__(self, spreadsheet_ID_ID=None, spreadsheet_ID=None):
        if spreadsheet_ID is None:
            if spreadsheet_ID_ID is None:
                raise RuntimeError("must have one")
            else:
                self.identifier_type = 'ID_ID'
        elif spreadsheet_ID_ID is None:
            self.identifier_type = 'ID'
        else:
            raise RuntimeError("can't have both")

        # NOTE we might make this two classes instead

        self.spreadsheet_ID_ID = spreadsheet_ID_ID
        self.spreadsheet_ID = spreadsheet_ID


def _full_range_string_via_schema(sch):
    left = sch.sheet_name
    right = sch.cell_range_string
    return f'{left}!{right}'


def _start_end_col_index(schema):
    return schema.start_column_index, schema.end_column_index


def _start_end_row_index(num_records, schema):
    return (i := schema.start_row_index), i + num_records


class Schema:

    def __init__(self, sheet_name, cell_range, cell_formats=None):

        md = _re_match('([A-Z])([0-9]+):([A-Z])$', cell_range)

        left_col, top_row, right_col = md.groups()

        self.start_column_index = ord(left_col) - _sixty_five
        self.end_column_index = (ord(right_col) - _sixty_five) + 1

        assert(self.end_column_index > self.start_column_index)

        self.number_of_fields = self.end_column_index - self.start_column_index

        top_row_i = int(top_row)
        assert(0 < top_row_i)
        self.start_row_index = top_row_i - 1

        self.cell_formats = cell_formats
        if cell_formats is not None:  # #here1
            assert(self.number_of_fields == len(cell_formats))  # for now

        self.cell_range_string = cell_range
        self.sheet_name = sheet_name

    @property
    def dimension(self):
        return 'ROWS'

    @property
    def sheet_ID(self):
        return 0  # ..


_sixty_five = ord('A')


def _re_match(rxs, s):  # ..
    import re
    return re.match(rxs, s)


def do_me():  # #todo
    raise NotImplementedError('do me')


_eol = "\n"

# #born.
