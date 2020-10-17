def _help_lines():
    # (at #history-B.3 got rid of file-reading hack)
    from data_pipes.magnetics import entities_via_filter_by_tags as mod
    return mod.__doc__


def _formals():
    yield '-h', '--help', 'this screen'
    yield '<collection>', 'usually a filesystem path to the collection'
    yield '<query> [<query> [..]]', 'elements of your tag query'


def CLI_(sin, sout, serr, argv, rscser):
    """Filter the collection by looking for hashtag-like markup in certain
    of its cels., E.g.: "#critical" or \\( "#open" and not "#cosmetic" \\)
    """

    prog_name = (bash_argv := list(reversed(argv))).pop()
    from data_pipes.cli import formals_via_ as func, \
        write_help_into_, monitor_via_

    foz = func(_formals(), lambda: prog_name)
    vals, es = foz.terminal_parse(serr, bash_argv)
    if vals is None:
        return es

    if vals.get('help'):
        return write_help_into_(serr, CLI_.__doc__, foz)

    coll_path = vals.get('collection')
    query = vals.get('query')

    mon = monitor_via_(serr)
    listener = mon.listener

    from data_pipes import meta_collection_ as func
    mc = func()
    coll = mc.collection_via_path(coll_path, listener)

    ci = coll.COLLECTION_IMPLEMENTATION
    _ents = ci.to_entity_stream_as_storage_adapter_collection(listener)

    from data_pipes.magnetics.entities_via_filter_by_tags import \
        stats_future_and_results_via_entity_stream_and_query, prepare_query

    q = prepare_query(query, listener)
    if q is None:
        return mon.errno

    itr = stats_future_and_results_via_entity_stream_and_query(_ents, q)
    future = next(itr)

    from kiss_rdb.cli import (click, success_exit_code_)
    from kiss_rdb import dictionary_dumper_as_JSON_via_output_stream

    sout = click.utils._default_text_stdout()
    serr = click.utils._default_text_stderr()

    dump = dictionary_dumper_as_JSON_via_output_stream(sout)
    first = True
    for entity in itr:
        if first:
            first = False
        else:
            sout.write(',\n')
        dump(entity.to_dictionary_two_deep_as_storage_adapter_entity())
    if not first:
        sout.write('\n')
    for line in __summarize_search_stats(future()):
        serr.write(line)

    return success_exit_code_


def __summarize_search_stats(o):  # deleted coverage at #history-A.3

    did_not_match = o['count_of_items_that_did_not_match']
    matched = o['count_of_items_that_matched']
    no_taggings = o['count_of_items_that_did_not_have_taggings']
    taggings = o['count_of_items_that_had_taggings']
    # --
    total = no_taggings + taggings

    _noma = 'nothing matched'

    def o(msg):  # common format, but don't assume it's a given
        return f'({msg}.)\n'

    if 0 == total:
        yield o(f'{_noma} because collection was empty')
    elif 0 == matched:
        if 0 == taggings:
            yield o(f'{_noma}')
            yield o(f'of {total} seen item(s), none had taggings')
        elif 0 == no_taggings:
            yield o(f'{_noma} of {taggings} item(s) seen (all with taggings)')
        else:
            yield o(f'{_noma}')
            yield o(f'{taggings} item(s) with taggings and {no_taggings} without')  # noqa: E501
    elif 0 == did_not_match:
        yield o(f'all {total} item(s) matched')
    else:
        yield o(f'{matched} match(es) of {total} item(s) seen')

# #history-B.3
# #re-housed #abstracted
