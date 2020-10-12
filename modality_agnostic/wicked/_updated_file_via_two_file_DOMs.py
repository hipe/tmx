def update_files_(listener, files, is_dry, edit_in_place_extension, hub):
    def main():
        resolve_target_managed_files_from_arguments()
        parse_argument_files()
        parse_template_files()
        resolve_a_plan_for_each_file()
        update_each_file_DOM()
        resolve_the_patch_units_of_work()
        if the_edit_in_place_extension_says_go_ahead_and_write_files():
            write_the_files()
            return _the_empty_iterator()
        return the_diff_lines()

    def write_tuple(attr):  # #decorator
        def decorator(orig_f):
            def use_f():
                setattr(self, attr, tuple(orig_f()))
            return use_f
        return decorator

    def write_the_files():
        if '' == edit_in_place_extension:
            _whine_about_no_backup_plan(listener)
            raise _Stop()
        _write_files(
            edit_in_place_extension, self.patch_units_of_work,
            throwing_listener, is_dry)

    def the_diff_lines():
        for uow in self.patch_units_of_work:
            for line in uow.diff_lines:
                yield line

    def the_edit_in_place_extension_says_go_ahead_and_write_files():
        return edit_in_place_extension is not None

    @write_tuple('patch_units_of_work')
    def resolve_the_patch_units_of_work():
        return _patch_units_of_work_via(
            self.file_diff_ingredientses, relativize_path, listener)

    @write_tuple('file_diff_ingredientses')
    def update_each_file_DOM():
        from ._file_DOM_via_lines import updated_file_blocks_via_ as func
        for plan, cDOM, uow in self.file_plan_and_cDOM_and_UOWs:
            updated_blocks = func(plan, throwing_listener)
            new_DOM = file_DOM_via_blocks(updated_blocks, uow.absolute_path)
            yield new_DOM, cDOM, uow

    @write_tuple('file_plan_and_cDOM_and_UOWs')
    def resolve_a_plan_for_each_file():
        from ._file_DOM_via_lines import \
            plan_via_client_and_template_blocks_ as plan_via
        template_DOM_via_templ_path = self.template_DOM_via_template_path
        for cDOM, uow in self.client_file_plan_ingredients:
            template_path = uow.template_path
            tDOM = template_DOM_via_templ_path[template_path]
            plan = plan_via(cDOM.blocks, tDOM.blocks, throwing_listener)
            yield plan, cDOM, uow

    def parse_template_files():
        # Many client files probably point at one template file. Don't parse
        # any participating template file more than once (at the top level)

        # Get the unique list of template paths
        dct = {uow.template_path: None for uow in uows()}

        # Parse each participating template file
        for path in dct.keys():
            with open(path) as lines:
                dct[path] = file_DOM_via_lines(lines, path)
        self.template_DOM_via_template_path = dct

    @write_tuple('client_file_plan_ingredients')
    def parse_argument_files():
        for uow in uows():
            path, opened = uow.absolute_path, None
            try:
                opened = open(path)
            except FileNotFoundError as err:
                e = err
            if opened is None:
                _whine_about_file_not_found(listener, e)
                raise _Stop()
            with opened as lines:
                file_DOM = file_DOM_via_lines(lines, path)
            yield file_DOM, uow

    def uows():
        return self.target_managed_files

    def resolve_target_managed_files_from_arguments():
        self.target_managed_files = some(_resolve_files(files, hub, listener))

    def some(x):
        if x is None:
            raise _Stop()
        return x

    def throwing_listener(sev, *rest):
        listener(sev, *rest)
        if 'error' == sev:
            raise _Stop()

    from script_lib import build_path_relativizer as func
    relativize_path = func()

    from ._file_DOM_via_lines import \
        file_DOM_via_lines_ as file_DOM_via_lines, \
        file_DOM_via_blocks_ as file_DOM_via_blocks

    class self:  # #class-as-namespace
        pass

    try:
        return main()
    except _Stop:
        return _the_empty_iterator()


def _patch_units_of_work_via(file_diff_ingredientses, relativize, listener):
    def patch_UOW(nDOM, cDOM, uow):
        # --
        before_lines = tuple(cDOM.to_lines())
        after_lines = tuple(nDOM.to_lines())
        path_tail = relativize(uow.absolute_path)
        do_create = False  # :[#503.B] provision: touch the path yourself
        return patch_UOW_via(before_lines, after_lines, path_tail, do_create)

    patch_UOW_via = _patchlib().patch_unit_of_work_via
    return (patch_UOW(fd, cd, uow) for fd, cd, uow in file_diff_ingredientses)


def _resolve_files(files, hub, listener):

    # If argument list was empty, all files
    if not len(files):
        return hub.file_units_of_work

    # Make a diminishing pool of the arguments
    rang = range(0, len(files))
    result_slots = [None for i in rang]

    # First, do the trick where we treat every arg as a needle against the whol
    matched_none, matched_multiple, matches = [], [], []
    for i in rang:
        file_arg = files[i]
        matches.clear()
        for formal in hub.file_units_of_work:
            if file_arg not in formal.tail:
                continue
            matches.append(formal)
        leng = len(matches)
        if 1 == leng:
            formal, = matches
            result_slots[i] = formal
            continue
        if 0 == leng:
            matched_none.append(i)
            continue
        assert 1 < leng
        matched_multiple.append((i, tuple(matches)))

    if matched_none:
        these = tuple(files[i] for i in matched_none)
        return _whine_about_matched_none(listener, these, hub)

    if matched_multiple:
        these = tuple(files[i] for i in matched_multiple)
        return _whine_about_ambiguous(listener, these, hub)

    assert all(result_slots)
    return tuple(result_slots)


def _write_files(ext, patch_units_of_work, listener, is_dry):
    import re
    if not re.match(r'^[a-z]+(?:\.[a-z]+)*$', ext):
        msg = f"For now, use an extension like 'foo.bak', not {ext!r}"
        listener('error', 'expression', 'nervous_about_extension', lambda: (msg,))  # noqa: E501
        return

    # Make a temporary directory
    # For each unit of work, copy the production file into the temporary
    # directory, giving it names like file1, file2 etc. Make a modified
    # patch unit of work pointing to this file instead. Keep track of these
    # mapping of filenames.
    # CD into the directory and apply the big patch
    # for each resulting file, copy the dopy and fopy the loppy

    def loud_dry_rename(src, dst):
        msg = f"mv {src} {dst}"
        listener('debug', 'expression', 'rename_file', lambda: (msg,))
        if not is_dry:
            rename(src, dst)

    def loud_copyfile(src, dst):
        msg = f"cp {src} {dst}"
        listener('debug', 'expression', 'copy_file', lambda: (msg,))
        copyfile(src, dst, follow_symlinks=False)

    apply_patch = _patchlib().apply_patch_via_lines
    from os.path import join as path_join
    from shutil import copyfile
    from os import rename

    leng = len(patch_units_of_work)
    rang = range(0, leng)
    patch_units_of_work = list(patch_units_of_work)  # #here1

    tmp_names = tuple(f'file{i}' for i in range(1, leng+1))

    from tempfile import TemporaryDirectory as open_tmp_dir
    with open_tmp_dir() as tmp_dir:

        big_patch_lines = []
        tmp_paths = tuple(path_join(tmp_dir, path) for path in tmp_names)

        # Make the new unit of work with the same diff lines but diff path tail
        for i in rang:
            tmp_name = tmp_names[i]
            tmp_path = tmp_paths[i]

            uow = patch_units_of_work[i]

            if 0 == len(uow.diff_lines):
                patch_units_of_work[i] = None  # #here1
                _notice_about_no_change(listener, uow)
                continue

            otr = uow.replace_path_tail(tmp_name)

            loud_copyfile(uow.path_tail, tmp_path)

            for line in otr.diff_lines:
                big_patch_lines.append(line)

        # Apply the big patch
        apply_patch(big_patch_lines, is_dry, listener, tmp_dir)

        # Copy the files back over to the PRODUCTION files!
        for i in rang:
            uow = patch_units_of_work[i]
            if uow is None:  # #here1
                continue
            prod_path = uow.path_tail
            bak_path = '.'.join((prod_path, ext))

            tmp_name = tmp_names[i]
            tmp_path = tmp_paths[i]

            loud_copyfile(prod_path, bak_path)
            loud_dry_rename(tmp_path, uow.path_tail)


# ==

def _notice_about_no_change(listener, uow):
    def lines():
        yield f"No change in file, skipping - {path}"
    path = uow.path_tail
    listener('notice', 'expression', 'no_change_in_file', lines)


def _whine_about_no_backup_plan(listener):
    def lines():
        yield "Currently we don't support edit-in place without making a backup file"  # noqa: E501
        yield "use `-i` with an argument"  # ick/meh
    listener('error', 'expression', 'no_backup_extension', lines)


def _whine_about_file_not_found(listener, e):
    msgs = [str(e)]
    msgs.append("Fow now, create the file yourself with (for example) `touch` [#503.B]")  # noqa: E501
    listener('error', 'expression', 'file_not_found', lambda: msgs)


def _whine_about_ambiguous(listener, pairs, hub):
    def lines():
        ox = _oxlib()
        for arg, uows in pairs:
            yield f"Found multiple managed files matching {arg!r}"
            pcs = tuple(f.tail for f in uows)
            or_these = ox.oxford_OR(ox.keys_map(pcs))
            yield f"Did you mean {or_these}?"
    listener('error', 'expression', 'ambigous_targets', lines)


def _whine_about_matched_none(listener, args, hub):
    def lines():
        ox = _oxlib()
        for arg in args:
            yield f"Found no managed file(s) matching {arg!r}"
        pcs = tuple(f.tail for f in hub.file_units_of_work)
        or_these = ox.oxford_OR(ox.keys_map(pcs))
        yield f"Did you mean {or_these}?"
    listener('error', 'expression', 'targets_not_found', lines)


# ==

def _the_empty_iterator():
    return iter(())


class _Stop(RuntimeError):
    pass


def _patchlib():
    import text_lib.diff_and_patch as module
    return module


def _oxlib():
    from text_lib.magnetics import via_words as module
    return module


def xx(msg=None):
    raise RuntimeError(msg or "wee")

# #born
