from modality_agnostic.test_support.common import \
    dangerous_memoize_in_child_classes as shared_subject_in_child_classes
from unittest import TestCase as unittest_TestCase, main as unittest_main


class CommonCase(unittest_TestCase):

    @property
    @shared_subject_in_child_classes
    def end_state(self):
        return self.build_end_state()

    def build_end_state_for_AST_via_lines(self):
        func = subject_function_for_via_lines()
        return func(self.given_lines())


class CaseNNNN_NNN_via_lines(CommonCase):

    def test_030_table_names_OK(self):
        act = tuple(t.table_name for t in tables_of(self.end_state))
        exp = 'artist', 'track'
        self.assertSequenceEqual(act, exp)

    def test_040_column_names_OK(self):
        t1, t2 = tables_of(self.end_state)
        act1 = tuple(c.column_name for c in columns_of(t1))
        act2 = tuple(c.column_name for c in columns_of(t2))

        exp1 = 'artist_ID', 'desc'
        exp2 = 'track_ID', 'desc', 'artist_ID'

        self.assertSequenceEqual(act1, exp1)
        self.assertSequenceEqual(act2, exp2)

    def build_end_state(self):
        print("build ONCE")
        return self.build_end_state_for_AST_via_lines()

    def given_lines(_):
        yield "CREATE TABLE artist (\n"
        yield "artist_ID INTEGER PRIMARY KEY,\n"
        yield "desc TEXT NOT NULL);\n"
        yield "\n"
        yield "CREATE TABLE track (\n"
        yield "track_ID INTEGER PRIMARY KEY,\n"
        yield "desc TEXT NOT NULL,\n"
        yield "artist_ID INTEGER NOT NULL REFERENCES artist\n"
        yield ");\n"


def tables_of(sch):
    return sch.to_tables()


def columns_of(tab):
    return tab.to_columns()


def subject_function_for_via_lines():
    return subject_module().abstract_schema_via_sqlite_SQL_lines


def subject_function_for_to_lines():
    return subject_module().sqlite_SQL_lines_via_abstract_schema


def subject_module():
    import kiss_rdb.storage_adapters_.sqlite3.\
        _abstract_schema_to_and_fro as mod
    return mod


if __name__ == '__main__':
    from sys import argv
    if 1 < len(argv) and '--show-sql' == argv[1]:
        from sys import modules, stdout
        which = argv[2]
        cls = getattr(modules['__main__'], which)
        w = stdout.write
        for line in cls().given_lines():
            w(line)
        exit(0)
    unittest_main()

# #born
