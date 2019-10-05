from modality_agnostic.memoization import lazy
import os.path as os_path


def build_end_state_commonly(self):  # (stowaway - relevant to FA's only)

    from modality_agnostic.test_support.listener_via_expectations import (
            # for_DEBUGGING,
            expecter_via_expected_emissions)

    exp = expecter_via_expected_emissions(self.expect_emissions())
    listener = exp.listener
    # listener = for_DEBUGGING

    _d = self.given()

    _cm = _sync_context_manager_via(**_d, listener=listener)

    with _cm as lines:
        lines = tuple(lines)

    _ = exp.actual_emission_index_via_finish()
    return _EndState(lines, _)


class ProducerCaseMethods:

    def build_YIKES_SYNC_(self):

        _producer_script = PS_path_or_PS_via(self.producer_script())
        _near_coll_id = self.near_collection_identifier()
        _listener = self.use_listener()

        _cm = _sync_context_manager_via(
                producer_script_path=_producer_script,
                near_collection=_near_coll_id,
                near_format='markdown-table',
                listener=_listener)

        with _cm as lines:
            lines = tuple(x for x in lines)

        return lines

    def build_pair_list_for_inspect_(self):

        ps = PS_via_mixed(self.producer_script())
        cached_doc_path = self.cached_document_path()
        listener = self.use_listener()
        if isinstance(cached_doc_path, tuple):
            opened = _pass_thru_context_manager(cached_doc_path)  # (Case2016)
        else:
            opened = ps.open_traversal_stream(listener, cached_doc_path)
        with opened as dcts:
            _pairs = ps.stream_for_sync_via_stream(dcts)
            return tuple(_pairs)

    def build_dictionaries_tuple_from_traversal_(self):

        ps = PS_via_mixed(self.producer_script())
        cached_doc_path = self.cached_document_path()
        listener = self.use_listener()
        _ = ps.open_traversal_stream(listener, cached_doc_path)
        with _ as dcts:
            return tuple(dcts)  # (much simplified at #history-A.2)

    def cached_document_path(self):
        return None

    def use_listener(self):
        from modality_agnostic import listening as _
        return _.throwing_listener

    def LISTENER_FOR_DEBUGGING(self):
        from modality_agnostic.test_support.listener_via_expectations import (
                for_DEBUGGING)
        return for_DEBUGGING


def PS_via_mixed(mixed):
    if isinstance(mixed, str):
        from data_pipes.format_adapters.producer_script import (
                producer_script_module_via_path)
        return producer_script_module_via_path(mixed, None)
    return FakeProducerScript(**mixed)


def PS_path_or_PS_via(mixed):
    if isinstance(mixed, str):
        return mixed
    return FakeProducerScript(**mixed)


def _sync_context_manager_via(**kwargs):
    from data_pipes.cli.sync import open_new_lines_via_sync
    return open_new_lines_via_sync(**kwargs)


class FakeProducerScript:
    def __init__(
            self, stream_for_sync_is_alphabetized_by_key_for_sync,
            stream_for_sync_via_stream, dictionaries, near_keyerer):

        self._dictionaries = dictionaries
        self.stream_for_sync_is_alphabetized_by_key_for_sync = stream_for_sync_is_alphabetized_by_key_for_sync  # noqa: E501
        self.stream_for_sync_via_stream = stream_for_sync_via_stream
        self.near_keyerer = near_keyerer

    def open_traversal_stream(self, listener, cached_document_path):
        x = self._dictionaries
        del self._dictionaries
        return _pass_thru_context_manager(x)

    HELLO_I_AM_A_PRODUCER_SCRIPT = None


class _EndState:
    def __init__(self, outputted_lines, aei):
        self.outputted_lines = outputted_lines
        self.actual_emission_index = aei


def executable_fixture(stem):
    return os_path.join(_top_test_dir(), 'fixture_executables', stem)


def html_fixture(tail):
    return os_path.join(fixture_files_directory(), '500-html', tail)


def markdown_fixture(tail):
    return os_path.join(fixture_files_directory(), '300-markdown', tail)


@lazy
def fixture_files_directory():
    return os_path.join(_top_test_dir(), 'fixture-files')


@lazy
def _top_test_dir():
    return os_path.dirname(__file__)


def _pass_thru_context_manager(x):
    from data_pipes import ThePassThruContextManager
    return ThePassThruContextManager(x)


def cover_me(s=None):
    msg = 'cover me'
    if s is not None:
        msg = '{}: {}'.format(msg, s)
    raise Exception(msg)


# #history-A.2: no more sync-side entity mapping
# #history-A.1: upgraded to python 3.7, things changed
# #born.
