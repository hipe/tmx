_PATCH_EXE_NAME = 'patch'


def build_big_patchfile__(eidr, entities_uows, order, coll, listener):
    from .blocks_via_path_ import emitter_via_monitor__
    emi = emitter_via_monitor__(coll.monitor_via_listener_(listener))
    catch_this = emi.stopper_exception_class
    try:
        return _build_big_patchfile(eidr, entities_uows, coll, order, emi)
    except catch_this:
        pass


def _build_big_patchfile(eidr, entities_uows, coll, order, emi):
    from .blocks_via_path_ import file_units_of_work_via__

    file_uows = file_units_of_work_via__(entities_uows, coll, emi)

    # ==
    from os.path import isabs

    def relativize_path(path):
        if (memo := relativize_path.memo) is None:
            from os import getcwd, path as os_path
            head = os_path.join(getcwd(), '')
            leng = len(head)
            relativize_path.memo = (head, leng)
        else:
            head, leng = memo
        assert(head == path[0:leng])  # ..
        tail = path[leng:]
        assert(not isabs(tail))
        return tail
    relativize_path.memo = None
    # ==

    if eidr and isabs(path := eidr['index_file_path']):
        use = {k: v for k, v in eidr.items()}
        use['index_file_path'] = relativize_path(path)
        eidr = use

    this_patch = _patch_file_for_index_file(**eidr) if eidr else None

    def patch_via(path, file_uow):
        if isabs(path):
            path = relativize_path(path)
        return _make_patch(file_uow, coll, order, emi, path=path)

    tup = tuple(patch_via(path, fu) for path, fu in file_uows if emi.OK)
    if not emi.OK:
        return

    if this_patch is not None:
        tup = (this_patch, *tup)

    class big_patchfile:  # #class-as-namespace

        def APPLY_PATCHES(listener, is_dry=False):
            return _APPLY_PATCHES(tup, listener, is_dry=is_dry)

        patches = tup

    return big_patchfile


def _patch_file_for_index_file(
        to_index_file_new_lines, index_file_existing_lines, index_file_path):
    new_lines = tuple(to_index_file_new_lines())
    return _patch_unit_of_work(
        before_lines=index_file_existing_lines, after_lines=new_lines,
        path_tail=index_file_path, do_create=False)


def _make_patch(fuow, coll, order, emi, **bot):
    from .blocks_via_path_ import new_file_lines__

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


def _patch_unit_of_work(before_lines, after_lines, path_tail, do_create):
    assert(isinstance(before_lines, tuple))  # #[#011]
    assert(isinstance(after_lines, tuple))  # #[#011]

    if do_create:
        assert(not len(before_lines))
        pathA = '/dev/null'
    else:
        pathA = f'a/{path_tail}'

    pathB = f'b/{path_tail}'

    from difflib import unified_diff
    _diff_lines = tuple(unified_diff(before_lines, after_lines, pathA, pathB))

    class patch_unit_of_work:  # #class-as-namespace
        diff_lines = _diff_lines
        do_create_file = do_create

    return patch_unit_of_work


def _APPLY_PATCHES(patches, listener, is_dry):
    from tempfile import NamedTemporaryFile

    with NamedTemporaryFile('w+') as fp:
        for patch in patches:
            for line in patch.diff_lines:
                fp.write(line)
        fp.flush()
        ok = _apply_big_patchfile(fp.name, listener, is_dry)
        if not ok:
            fp.seek(0)
            dst = 'z/_LAST_PATCH_.diff'
            with open(dst, 'w+') as dst_fp:  # from shutil import copyfile meh
                for line in fp:
                    dst_fp.write(line)
            msg = f"(wrote this copy of patchfile for debugging: {dst})"
            listener('info', 'expression', 'wrote', lambda: (msg,))
    return ok


def _apply_big_patchfile(patchfile_path, listener, is_dry):

    def serr(msg):
        if '\n' == msg[-1]:  # lines coming from the subprocess
            msg = msg[0:-1]
        listener('info', 'expression', 'from_patchfile', lambda: (msg,))

    import subprocess as sp

    args = [_PATCH_EXE_NAME]
    if is_dry:
        line = "(executing patch with --dry-run ON)"
        listener('info', 'expression', 'dry_run', lambda: (line,))
        args.append('--dry-run')

    args += ('--strip', '1', '--input', patchfile_path)

    opened = sp.Popen(
            args=args,
            stdin=sp.DEVNULL,
            stdout=sp.PIPE,
            stderr=sp.PIPE,
            text=True,  # don't give me binary, give me utf-8 strings
            )

    with opened as proc:

        stay = True
        while stay:
            stay = False
            for line in proc.stdout:
                serr(f"GOT THIS STDOUT LINE: {line}")
                stay = True
                break
            for line in proc.stderr:
                serr(f"GOT THIS STDERR LINE: {line}")
                stay = True
                break

        proc.wait()  # not terminate. maybe timeout one day
        es = proc.returncode

    if 0 == es:
        return True
    serr(f"EXITSTATUS: {repr(es)}\n")


def xx(msg=None):
    raise RuntimeError(f"write me{f': {msg}' if msg else ''}")

# #abstracted
