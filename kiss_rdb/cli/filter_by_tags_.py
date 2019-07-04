def help_lines():

    """(this worked but we couldn't use it because click does not appear to
    give you a facility to resolve the help string lazily. We absolutely do
    not want this to be evaluated at every CLI invocaton. Also, instead of
    reading this file, try loading it as a module and reading its docstring.)
    """

    from os.path import (dirname as dn, join)  # os_path
    _ = join(dn(dn(__file__)), 'magnetics_', 'entities_via_filter_by_tags.py')
    import re
    rx = re.compile(r'^"""')
    with open(_) as lines:
        md = rx.match(next(lines))
        yield md.string[md.span()[1]:-1]
        while True:
            line = next(lines)
            md = rx.match(line)
            if md is None:
                yield line[:-1]
                continue
            yield line[md.span()[1]:-1]
            break


def filter_by_tags(ctx, collection, query):

    # begin boilerplate-esque
    cf = ctx.obj  # "cf" = common functions
    mon = cf.build_monitor()
    listener = mon.listener
    _inj = cf.release_these_injections('filesystem')
    coll = cf.collection_via_unsanitized_argument(collection, listener, **_inj)
    if coll is None:
        return mon.some_error_code()
    # end

    _ents = coll._impl.to_entity_stream_as_storage_adapter_collection(listener)

    from kiss_rdb.magnetics_.entities_via_filter_by_tags import (
            stats_future_and_results_via_entity_stream_and_query,
            prepare_query)

    if not len(query):
        raise Exception('cover me - no query')

    q = prepare_query(query, listener)
    if q is None:
        return mon.some_error_code()

    itr = stats_future_and_results_via_entity_stream_and_query(_ents, q)
    future = next(itr)

    from kiss_rdb.cli import (
            click, dict_dumper_via_output_stream_, success_exit_code_)

    sout = click.utils._default_text_stdout()
    serr = click.utils._default_text_stderr()

    dump = dict_dumper_via_output_stream_(sout)
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

# #re-housed #abstracted
