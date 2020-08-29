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
            stop(f"directory cannot already exist - {coll_path}")

        def make_sure_dirname_exists():
            self.coll_path = os_path.abspath(coll_path)
            dirname = os_path.dirname(self.coll_path)
            assert(dirname != self.coll_path)
            if os_path.exists(dirname):
                self.dirname = dirname
                return
            stop(f"directory must exist - {dirname}")

        stop = _stopper_via_listener(listener)
        from os import path as os_path

        try:
            return main()
        except _Stop:
            pass


def _work(dirname, coll_dir, listener, is_dry):
    from ._big_patchfile_via_entities_uows import \
        APPLY_BIG_PATCHFILE_WITH_DIRECTIVES_
    raw_lines = _these_special_lines_raw()
    var_values = {'COLLECTION_DIR': coll_dir}
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
diff --git a/<VAR: COLLECTION_DIR>/schema.rec b/<VAR: COLLECTION_DIR>/schema.rec
new file mode 100644
--- /dev/null
+++ b/<VAR: COLLECTION_DIR>/schema.rec
@@ -0,0 +1,4 @@
+storage_adapter: eno
+storage_schema: 32x32x32
+
+# #born
"""
# #born
