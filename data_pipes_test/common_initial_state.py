from modality_agnostic.memoization import lazy
import os.path as os_path


def build_end_state_commonly(self):  # (stowaway - relevant to FA's only)

    import modality_agnostic.test_support.listener_via_expectations as lib

    exp = lib(self.expect_emissions())

    _d = self.given()

    _cm = _sync_context_manager_via(**_d, listener=exp.listener)

    with _cm as lines:
        lines = tuple(x for x in lines)

    _ = exp.actual_emission_index_via_finish()
    return _EndState(lines, _)


class ProducerCaseMethods:

    def build_YIKES_SYNC_(self):

        _far_coll_id = _norm_path(self.far_collection_identifier())
        _near_coll_id = self.near_collection_identifier()
        _listener = self.use_listener()

        _cm = _sync_context_manager_via(
                far_collection=_far_coll_id,
                near_collection=_near_coll_id,
                near_format='markdown_table',
                listener=_listener)

        with _cm as lines:
            lines = tuple(x for x in lines)

        return lines

    def build_pair_list_for_inspect_(self):

        _cdp = self.cached_document_path()
        _ci = _norm_path(self.far_collection_identifier())
        _listener = self.use_listener()
        _f = _this_stream_lib()._traversal_stream_for_sync

        pairs = _f(
                cached_document_path=_cdp,
                collection_identifier=_ci,
                listener=_listener)

        slowly = []
        for (key, dct) in pairs:
            slowly.append((key, dct))

        return slowly

    def build_raw_list_(self):

        _cdp = self.cached_document_path()
        _ci = _norm_path(self.far_collection_identifier())
        _listener = self.use_listener()

        open_traversal_stream = _this_stream_lib().open_traversal_stream_TEMPORARY_LOCATION  # noqa: E501

        _ = open_traversal_stream(
                cached_document_path=_cdp,
                collection_identifier=_ci,
                intention=None,
                listener=_listener)

        slowly = []

        def visit(dct):
            slowly.append(dct)

        with _ as dcts:
            trav_params = next(dcts)  # ..
            metadata_row_dict = trav_params.to_dictionary()
            visit(metadata_row_dict)
            for dct in dcts:
                visit(dct)

        return slowly

    def cached_document_path(self):
        return None

    def use_listener(self):
        # return self.LISTENER_FOR_DEBUGGING()
        return _the_no_op_listener

    def LISTENER_FOR_DEBUGGING(self):
        import modality_agnostic.test_support.listener_via_expectations as _
        return _.for_DEBUGGING


def _norm_path(path):
    return path  # ..


def _the_no_op_listener(*_):
    pass


def _sync_context_manager_via(**kwargs):
    import data_pipes.cli.sync as _
    return _.OpenNewLines_via_Sync_(**kwargs)


class _EndState:
    def __init__(self, outputted_lines, aei):
        self.outputted_lines = outputted_lines
        self.actual_emission_index = aei


def executable_fixture(stem):
    return os_path.join(_top_test_dir(), 'fixture_executables', stem)


def html_fixture(tail):
    return os_path.join(_fixture_files(), '500-html', tail)


def markdown_fixture(tail):
    return os_path.join(_fixture_files(), '300-markdown', tail)


@lazy
def _fixture_files():
    return os_path.join(_top_test_dir(), 'fixture-files')


@lazy
def _top_test_dir():
    return os_path.dirname(__file__)


def _this_stream_lib():
    from data_pipes import common_producer_script
    return common_producer_script.common_CLI_library()


def pop_property(self, prop):
    x = getattr(self, prop)
    delattr(self, prop)
    return x


def cover_me(s=None):
    msg = 'cover me'
    if s is not None:
        msg = '{}: {}'.format(msg, s)
    raise Exception(msg)


# #history-A.1: upgraded to python 3.7, things changed
# #born.