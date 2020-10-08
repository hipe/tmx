from modality_agnostic.test_support.common import lazy
import os.path as os_path


class ProducerCaseMethods:

    def build_pair_list_for_inspect_(self):

        ps = PS_via_mixed(self.given_producer_script())
        cached_doc_path = self.cached_document_path()
        listener = self.use_listener()
        if isinstance(cached_doc_path, tuple):
            opened = passthru_context_manager(cached_doc_path)  # (Case2016)
        else:
            opened = ps.open_traversal_stream(listener, cached_doc_path)
        with opened as dcts:
            _pairs = ps.stream_for_sync_via_stream(dcts)
            return tuple(_pairs)

    def build_dictionaries_tuple_from_traversal_(self):

        ps = PS_via_mixed(self.given_producer_script())
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


def PS_via_mixed(mixed):
    if isinstance(mixed, str):
        from data_pipes.format_adapters.producer_script import (
                producer_script_module_via_path)
        return producer_script_module_via_path(mixed, None)
    return FakeProducerScript(**mixed)


class FakeProducerScript:  # [#459.17] a fake producer script

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
        return passthru_context_manager(x)

    HELLO_I_AM_A_PRODUCER_SCRIPT__ = None


def production_collectioner():
    from data_pipes import meta_collection_ as func
    return func()


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


def passthru_context_manager(x):
    from data_pipes import ThePassThruContextManager as cm
    return cm(x)

# #history-A.2: no more sync-side entity mapping
# #history-A.1: upgraded to python 3.7, things changed
# #born.
