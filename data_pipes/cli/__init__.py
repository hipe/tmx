def SPLAY_FORMAT_ADAPTERS(stdout, stderr):
    """if the user passes the string "help" for the argument, display

    help for that format and terminate early. otherwise, do nothing.
    """

    o = stderr.write
    o('the filename extension can imply a format adapter.\n')
    o('(or you can specify an adapter explicitly by name.)\n')
    o('known format adapters (and associated extensions):\n')

    out = stdout.write  # imagine piping output (! errput) (Case3067DP)
    count = 0

    from kiss_rdb import collectionerer
    _ = collectionerer().splay_storage_adapters__()

    for (k, ref) in _:
        _storage_adapter = ref()
        mod = _storage_adapter.module
        if mod.STORAGE_ADAPTER_CAN_LOAD_SCHEMALESS_SINGLE_FILES:
            _these = mod.STORAGE_ADAPTER_ASSOCIATED_FILENAME_EXTENSIONS
            _these = ', '.join(_these)
            _surface = f'({_these})'
        else:
            _surface = '(schema-based)'
        out(f'    {k} {_surface}\n')
        count += 1
    o(f'({count} total.)\n')
    return 0  # _exitstatus_for_success

# #history-A.5: lost almost all the stuff
# #history-A.4: become not executable any more
# #history-A.3: no more sync-side stream-mapping
# #history-A.2 can be temporary. as referenced.
# #history-A.1: begin become library, will eventually support "map for sync"
# #born.
