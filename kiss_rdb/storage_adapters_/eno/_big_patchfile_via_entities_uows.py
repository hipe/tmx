

def build_big_patchfile__(ifc, ent_uows, reser, coll, order, listener):
    from ._blocks_via_path import emitter_via_monitor__
    emi = emitter_via_monitor__(coll.monitor_via_listener_(listener))
    catch_this = emi.stopper_exception_class
    try:
        return _build_big_patchfile(ifc, ent_uows, reser, coll, order, emi)
    except catch_this:
        pass


def _build_big_patchfile(ifc, entities_uows, reser, coll, order, emi):
    from ._blocks_via_path import file_units_of_work_via__
    file_uows = file_units_of_work_via__(entities_uows, coll, emi)

    from script_lib import build_path_relativizer as build
    relativize_path = build()
    from os.path import isabs

    # ==

    if ifc and isabs(path := ifc['index_file_path']):
        use = {k: v for k, v in ifc.items()}
        use['index_file_path'] = relativize_path(path)
        ifc = use

    ifc_patch = _patch_file_for_index_file(**ifc) if ifc else None

    def patch_via(path, file_uow):
        if isabs(path):
            path = relativize_path(path)
        return _make_patch(file_uow, coll, order, emi, path=path)

    tup = tuple(patch_via(path, fu) for path, fu in file_uows if emi.OK)
    if not emi.OK:
        return

    if ifc_patch is not None:
        tup = (ifc_patch, *tup)

    class big_patchfile:  # #class-as-namespace

        def APPLY_PATCHES(listener, is_dry=False):
            return _APPLY_PATCHES(tup, reser, listener, is_dry=is_dry)

        patches = tup

    return big_patchfile


def _patch_file_for_index_file(
        to_index_file_new_lines, index_file_existing_lines, index_file_path):
    new_lines = tuple(to_index_file_new_lines())
    return _patch_unit_of_work(
        before_lines=index_file_existing_lines, after_lines=new_lines,
        path_tail=index_file_path, do_create=False)


def _make_patch(fuow, coll, order, emi, **bot):
    from ._blocks_via_path import new_file_lines__

    body_of_text_via_ = coll.body_of_text_via_
    bot = body_of_text_via_(**bot)
    tail = bot.path or 'some-imaginary-file.dot'

    # somewhere (here?) ..
    do_create_file = False
    if fuow.maybe_create_file and bot.path is not None:
        from os.path import exists  # os.{stat|path.{exists|isfile|isdir}}
        do_create_file = not exists(bot.path)  # HIT THE FILESYSTEM
    if do_create_file:
        fake_lines = (
            '# document-meta\n', '-- string_as_comment\n',
            '# #born\n', '-- string_as_comment\n')
        bot = body_of_text_via_(lines=fake_lines, path=bot.path)
        before_lines = ()
    else:
        before_lines = bot.lines

    new_file_lines = new_file_lines__(
            fuow.dictionary, coll, order, emi, body_of_text=bot)
    new_file_lines = tuple(new_file_lines)

    return _patch_unit_of_work(
            before_lines, new_file_lines, tail, do_create_file)


def _APPLY_PATCHES(patches, reser, listener, is_dry):
    def lineser():
        for patch in patches:
            for line in patch.diff_lines:
                yield line
    return _apply_big_patchfile_via_lines(lineser(), reser, listener, is_dry)


def APPLY_BIG_PATCHFILE_WITH_DIRECTIVES_(
        raw_lines, var_vals, dirname, listener, is_dry):  # noqa: E501
    full_direcs = []
    lines = _lines_and_full_direcs_via_template(full_direcs.append, raw_lines, var_vals)  # noqa: E501
    ok = _apply_big_patchfile_via_lines(lines, lambda: True, listener, is_dry, dirname)  # noqa: E501
    if not ok:
        return
    for direc_name, direc_value in full_direcs:
        assert('ERASE_THIS_FILE_AFTER_APPLYING_THE_PATCH' == direc_name)
        if True:
            from os import path as os_path, remove as os_remove
            remove_me = os_path.join(dirname, direc_value)
            os_remove(remove_me)
    return ok


def _lines_and_full_direcs_via_template(recv_full_direc, raw_lines, var_vals):
    direcs = []
    detemplatize_line = _line_detemplatizer_via(var_vals)
    recv_direc = direcs.append
    import re
    curr_path_re = re.compile(r'^\+\+\+ b/(.+)')
    last_path = None
    for raw_line in raw_lines:
        line = detemplatize_line(recv_direc, raw_line)
        yield line  # look
        md = curr_path_re.match(line)
        if md is not None:
            last_path = md[1]
        if not len(direcs):
            continue
        direc, = direcs  # (while it works)
        direcs.clear()
        assert('ERASE_THIS_FILE_AFTER_APPLYING_THE_PATCH' == direc)
        if True:
            assert(last_path)
            recv_full_direc((direc, last_path))
            continue


def _line_detemplatizer_via(var_values):
    def detemplatize_line(receive_directive, line):
        return ''.join(line_pieces(receive_directive, line))

    def line_pieces(receive_directive, line):
        begin = 0
        itr = re.finditer(r'<(?P<direc_name>[A-Z]+): (?P<direc_value>[A-Z_]+)>', line)  # noqa: E501
        for md in itr:
            match_begin, match_end = md.span()
            if begin < match_begin:
                yield line[begin:match_begin]
            begin = match_end
            direc_name, direc_value = md.groups()
            if 'VAR' == direc_name:
                yield var_values[direc_value]
                continue
            assert('DIRECTIVE' == direc_name)
            if True:
                receive_directive(direc_value)
                yield direc_value

        if begin < len(line):
            yield line[begin:]

    import re
    return detemplatize_line


def _patch_unit_of_work(before_lines, after_lines, path_tail, do_create):
    func = _patchlib().patch_unit_of_work_via
    return func(before_lines, after_lines, path_tail, do_create)


def _apply_big_patchfile_via_lines(lines, reser, listener, is_dry, cwd=None):
    # (used for here and used by neighbor for creating collections!)

    func = _patchlib().apply_patch_via_lines
    ok = func(lines, is_dry, listener, cwd)
    if ok:
        return reser()


def _patchlib():
    import text_lib.diff_and_patch as module
    return module

# #history: lost apply patch function
# #abstracted
