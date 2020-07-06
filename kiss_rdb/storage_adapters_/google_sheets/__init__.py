STORAGE_ADAPTER_CAN_LOAD_DIRECTORIES = False
STORAGE_ADAPTER_CAN_LOAD_SCHEMALESS_SINGLE_FILES = True
STORAGE_ADAPTER_ASSOCIATED_FILENAME_EXTENSIONS = ()
STORAGE_ADAPTER_IS_AVAILABLE = False
STORAGE_ADAPTER_UNAVAILABLE_REASON = "building backend (transactors) first"


class Collection:

    def __init__(self, transactor, schema):
        self._transactor = transactor
        self._schema = schema

    def values_get_all_native_records(self, listener):
        req = _GetAllRequest(listener, self._schema)
        return self._transactor.values_get(req)


class _GetAllRequest:

    def __init__(self, listener, schema):
        self.cel_range_string = schema.cel_range_string
        self.subsheet_name = schema.subsheet_name
        self.listener = listener


class LiveTransactor:

    def __init__(self, spreadsheet_ID, token_path, credentials_path):

        def build_sheet_API(listener):
            # if you modify these scopes, delete the file at token_path
            scopes = ['https://www.googleapis.com/auth/spreadsheets.readonly']
            creds = _credentials_via(
                    token_path, credentials_path, scopes, listener)
            service = _service_via_credentials(creds)
            return service.spreadsheets()

        self._build_sheet_API = build_sheet_API
        self._spreadsheet_ID = spreadsheet_ID
        self._single_use_mutex = None

    def values_get(self, req):
        del self._single_use_mutex

        left = req.subsheet_name
        right = req.cel_range_string
        full_range_name = f'{left}!{right}'

        sheet = self._build_sheet_API(req.listener)

        result = sheet.values().get(
                spreadsheetId=self._spreadsheet_ID,
                range=full_range_name).execute()

        return result.get('values', [])


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
        import pickle
        with open(token_path, 'rb') as token:
            creds = pickle.load(token)

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
            pickle.dump(creds, token)

    return creds


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

        direc = os_path.join(recs.path, 'values_get')

        pieces = []
        pieces.append(ss_ID_ID)
        pieces.append(req.subsheet_name.lower().replace(' ', '-'))

        frm, to = req.cel_range_string.split(':')
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


class Cypher:  # experimental

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


class Schema:

    def __init__(self, cel_range, subsheet_name):
        assert(_re_match('[A-Z]+[0-9]+:[A-Z]+$', cel_range))  # ..
        self.cel_range_string = cel_range
        self.subsheet_name = subsheet_name


def _re_match(rxs, s):  # ..
    import re
    return re.match(rxs, s)


def do_me():  # #todo
    raise NotImplementedError('do me')


_eol = "\n"

# #born.
