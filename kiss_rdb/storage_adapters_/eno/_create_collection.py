class CreateCollection:

    def execute(self, coll_path, listener, is_dry):

        def main():
            make_sure_dirname_exists()
            make_sure_collection_path_doesnt_exist()
            make_sure_collection_dir_looks_right()
            return _work(self.dirname, self.collection_dir, listener, is_dry)

        def make_sure_collection_dir_looks_right():
            entry = self.coll_path[len(self.dirname) + len(os_path.sep):]
            these = r'^[-a-zA-Z_0-9]+$'
            import re
            if re.match(these, entry):
                self.collection_dir = entry
                return
            stop('please use only these characters in collection names:'
                 f' /{these}/. had: {repr(entry)}')

        def make_sure_collection_path_doesnt_exist():
            if not os_path.exists(self.coll_path):
                return
            # (Case4852_075)
            stop(f"directory cannot already exist - {coll_path}")

        def make_sure_dirname_exists():
            self.coll_path = os_path.abspath(coll_path)
            dirname = os_path.dirname(self.coll_path)
            assert(dirname != self.coll_path)
            if os_path.exists(dirname):
                self.dirname = dirname
                return
            stop(f"directory must exist - {dirname}")  # (Case4852_050)

        stop = _stopper_via_listener(listener)
        from os import path as os_path

        try:
            return main()
        except _Stop:
            pass


def _work(dirname, coll_dir, listener, is_dry):
    ok = _apply_big_patchfile(dirname, coll_dir, listener, is_dry)
    if not ok:
        raise _Stop()

    # Now we have made the changes on the filesystem.
    # Do we want mutable or read-only collection? If mutable, we
    # need all those special arguments like rng...

    from kiss_rdb.storage_adapters_ import eno as sa_mod

    kw = {'do_load_schema_from_filesystem': (not is_dry)}

    from kiss_rdb.magnetics_.collection_via_path import \
        collection_via_storage_adapter_module_and_path_ as func

    return func(sa_mod, coll_dir, listener, kw)


def _apply_big_patchfile(dirname, coll_dir, listener, is_dry):
    from ._big_patchfile_via_entities_uows import \
        APPLY_BIG_PATCHFILE_WITH_DIRECTIVES_
    raw_lines = _these_special_lines_raw()
    from kiss_rdb import SCHEMA_FILE_ENTRY_ as schema_rec
    var_values = {'COLLECTION_DIR': coll_dir, 'SCHEMA_ENTRY': schema_rec}
    return APPLY_BIG_PATCHFILE_WITH_DIRECTIVES_(
            raw_lines, var_values, dirname, listener, is_dry)


def _these_special_lines_raw():
    with open(__file__) as lines:
        for line in lines:
            if '# == PATCH_STARTS_HERE\n' == line:
                break
        assert('"""\n' == next(lines))
        line = next(lines)
        while True:
            yield line
            line = next(lines)
            if '"""\n' == line:
                found = True
                break
        assert(found)


def _stopper_via_listener(listener):
    def stop(msg):
        def msgr():
            yield f"cannot create collection: {msg}"
        listener('error', 'expression', 'cannot_create_collection', msgr)
        raise _Stop()
    return stop


def xx(msg=None):
    tail = f": {msg}" if msg else ''
    raise RuntimeError(f"write me{tail}")


class _Stop(RuntimeError):
    pass


# == PATCH_STARTS_HERE
"""
diff --git a/<VAR: COLLECTION_DIR>/.identifiers.txt b/<VAR: COLLECTION_DIR>/.identifiers.txt
new file mode 100644
--- /dev/null
+++ b/<VAR: COLLECTION_DIR>/.identifiers.txt
@@ -0,0 +1 @@
+
diff --git a/<VAR: COLLECTION_DIR>/entities/erase-me.txt b/<VAR: COLLECTION_DIR>/entities/erase-me.txt
new file mode 100644
--- /dev/null
+++ b/<VAR: COLLECTION_DIR>/entities/erase-me.txt
@@ -0,0 +1 @@
+<DIRECTIVE: ERASE_THIS_FILE_AFTER_APPLYING_THE_PATCH>
+
diff --git a/<VAR: COLLECTION_DIR>/<VAR: SCHEMA_ENTRY> b/<VAR: COLLECTION_DIR>/<VAR: SCHEMA_ENTRY>
new file mode 100644
--- /dev/null
+++ b/<VAR: COLLECTION_DIR>/<VAR: SCHEMA_ENTRY>
@@ -0,0 +1,4 @@
+storage_adapter: eno
+storage_schema: 32x32x32
+
+# #born
"""
# #born
