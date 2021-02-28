from modality_agnostic.test_support.common import \
    dangerous_memoize_in_child_classes as shared_subject_in_child_classes, \
    listener_and_emissions_for
from unittest import TestCase as unittest_TestCase, main as unittest_main


class CommonCase(unittest_TestCase):

    @property
    @shared_subject_in_child_classes
    def end_state(self):
        return self.build_end_state()

    def build_end_state_for_AST_via_lines(self):
        func = subject_function_for_via_lines()
        return func(self.given_lines())


class Case4860_410_via_lines(CommonCase):

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


class BigCase(unittest_TestCase):

    @property
    def the_one_emission(self):
        act, emis = self.end_state
        assert act is None
        emi, = emis
        return emi

    def expect_success(self):
        act, emis = self.build_end_state()
        assert 0 == len(emis)
        exp = tuple(self.expected_SQL_lines())
        self.assertSequenceEqual(act, exp)

    @property
    @shared_subject_in_child_classes
    def end_state(self):
        return self.build_end_state()

    def build_end_state(self):

        listener, emissions = listener_and_emissions_for(self)

        GV_lines = unindent_big_string(self.given_graph_viz_indented_big_string())  # noqa: E501
        DB_lines = unindent_big_string(self.given_sqlite_schema_indented_big_string())  # noqa: E501

        from kiss_rdb.storage_adapters.sqlite3.connection_via_graph_viz_lines \
            import _abs_schema_via_graph_viz as GV_abs_sch_via

        from kiss_rdb.storage_adapters_.sqlite3._abstract_schema_to_and_fro \
            import abstract_schema_via_sqlite_SQL_lines as DB_abs_sch_via

        GV_absch = GV_abs_sch_via(GV_lines, listener=None)
        DB_absch = DB_abs_sch_via(DB_lines)

        d = DB_absch.schema_diff_to(GV_absch)
        if d is None:
            return (), emissions

        from kiss_rdb.storage_adapters.sqlite3.connection_via_graph_viz_lines \
            import _SQL_lineses as subject_function

        res = subject_function(
            d, '/pretend/db.sqlite3', pretend_FH_just_for_name, listener,
            create_tables_if_not_exist=True, strange_tables_are_OK=False)

        if hasattr(res, '__next__'):
            # (it's a "lineses")
            res = tuple(line for lines in res for line in lines)
        return res, emissions

    do_debug = False


class Case4860_415_up_to_date(BigCase):

    def test_010_expect_success(self):
        self.expect_success()

    def expected_SQL_lines(_):
        return ()

    def given_graph_viz_indented_big_string(_):
        return """
        digraph g {

        rankdir=LR

        node1[label="artist|
        <artist_ID> artist_ID int primary key|
        <artist_title> artist_title text" shape=record]

        node2[label="track|
        <track_ID> track_ID int primary key|
        <track_title> track_title text|
        <artist_ID> artist_ID int" shape=record]

        node1:artist_ID->node2:artist_ID[arrowhead=odot]

        }

        /*
        # #born omg sweet holy moly
        */
        """

    def given_sqlite_schema_indented_big_string(_):
        return """
        CREATE TABLE artist (
          artist_ID INTEGER PRIMARY KEY,
          artist_title TEXT NOT NULL);
        CREATE TABLE track (
          track_ID INTEGER PRIMARY KEY,
          track_title TEXT NOT NULL,
          artist_ID INTEGER NOT NULL REFERENCES artist);
        """


class Case4860_419_add_a_table(BigCase):

    def test_010_expect_success(self):
        self.expect_success()

    def expected_SQL_lines(_):
        return unindent_big_string("""
        CREATE TABLE track (
          track_ID INTEGER PRIMARY KEY,
          track_title TEXT NOT NULL,
          artist_ID INTEGER NOT NULL REFERENCES artist);
        """)

    def given_graph_viz_indented_big_string(_):
        return """
        digraph g {

        rankdir=LR

        node1[label="artist|
        <artist_ID> artist_ID int primary key|
        <artist_title> artist_title text" shape=record]

        node2[label="track|
        <track_ID> track_ID int primary key|
        <track_title> track_title text|
        <artist_ID> artist_ID int" shape=record]

        node1:artist_ID->node2:artist_ID[arrowhead=odot]
        }
        """

    def given_sqlite_schema_indented_big_string(_):
        return """
        CREATE TABLE artist (
          artist_ID INTEGER PRIMARY KEY,
          artist_title TEXT NOT NULL);
        """


class Case4860_432_when_missing_column(BigCase):

    def test_010_expect_failure(self):
        act = self.the_one_emission.channel
        exp = 'error', 'expression', same, 'tables_different'
        self.assertSequenceEqual(act, exp)

    def test_020_messages(self):
        act = tuple(self.the_one_emission.to_messages())
        exp = tuple(self.expected_message_lines())
        self.assertSequenceEqual(act, exp)

    def expected_message_lines(_):
        yield "Database and visual schema are different in table(s): ('artist')"  # noqa: E501
        yield 'database: /pretend/db.sqlite3'
        yield 'dotfile: /pretend/my-schema.dot'
        yield "Table 'artist' is missing this column: 'number_of_start'.\n"

    def given_graph_viz_indented_big_string(_):
        return """
        digraph g {

        rankdir=LR

        node1[label="artist|
        <artist_ID> artist_ID int primary key|
        <qq> number_of_start int|
        <artist_title> artist_title text" shape=record]
        }
        """

    def given_sqlite_schema_indented_big_string(_):
        return """
        CREATE TABLE artist (
          artist_ID INTEGER PRIMARY KEY,
          artist_title TEXT NOT NULL);
        """


# BEGIN FOCUS:

class Case4860_436_when_extra_table(BigCase):

    def test_010_expect_failure(self):
        act = self.the_one_emission.channel
        exp = 'error', 'expression', same, 'strange_tables'
        self.assertSequenceEqual(act, exp)

    def test_020_messages(self):
        act = tuple(self.the_one_emission.to_messages())
        exp = tuple(self.expected_message_lines())
        self.assertSequenceEqual(act, exp)

    def expected_message_lines(_):
        yield '`strange_tables_are_OK` is set to false and'
        yield "database has unrecognized table(s): ('genre')"
        yield "Either drop these tables (IF YOU'RE SURE) or change dotfile."
        yield 'database: /pretend/db.sqlite3'
        yield 'dotfile: /pretend/my-schema.dot'

    def given_graph_viz_indented_big_string(_):
        return """
        digraph g {

        rankdir=LR

        node1[label="artist|
        <artist_ID> artist_ID int primary key|
        <artist_title> artist_title text" shape=record]

        node2[label="track|
        <track_ID> track_ID int primary key|
        <track_title> track_title text|
        <artist_ID> artist_ID int" shape=record]

        node1:artist_ID->node2:artist_ID[arrowhead=odot]
        }
        """

    def given_sqlite_schema_indented_big_string(_):
        return """
        CREATE TABLE artist (
          artist_ID INTEGER PRIMARY KEY,
          artist_title TEXT NOT NULL);
        CREATE TABLE track (
          track_ID INTEGER PRIMARY KEY,
          track_title TEXT NOT NULL,
          artist_ID INTEGER NOT NULL REFERENCES artist);
        CREATE TABLE genre (
          track_ID INTEGER PRIMARY KEY,
          name TEXT NOT NULL);
        """

# END FOCUS


class Case4860_440_when_a_single_column_attrib(BigCase):

    def test_010_expect_failure(self):
        act = self.the_one_emission.channel
        exp = 'error', 'expression', same, 'tables_different'
        self.assertSequenceEqual(act, exp)

    def test_020_messages(self):
        act = tuple(self.the_one_emission.to_messages())
        exp = tuple(self.expected_message_lines())
        self.assertSequenceEqual(act, exp)

    def expected_message_lines(_):
        yield "Database and visual schema are different in table(s): ('track')"
        yield 'database: /pretend/db.sqlite3'
        yield 'dotfile: /pretend/my-schema.dot'
        yield "Table 'track' is out of sync in the 'track_title' column:\n"
        yield "For column 'track_title', 'column_type_storage_class' is 'text' but should be 'int'.\n"  # noqa: E501

    def given_graph_viz_indented_big_string(_):
        return """
        digraph g {

        rankdir=LR

        node2[label="track|
        <track_ID> track_ID int primary key|
        <track_title> track_title int" shape=record]
        }
        """

    def given_sqlite_schema_indented_big_string(_):
        return """
        CREATE TABLE track (
          track_ID INTEGER PRIMARY KEY,
          track_title TEXT NOT NULL);
        """


def tables_of(sch):
    return sch.to_tables()


def columns_of(tab):
    return tab.to_columns()


def unindent_big_string(big_string):
    import re
    rx = re.compile(r'[ ]+\Z')
    lines = big_string.splitlines(keepends=True)
    assert '\n' == lines[0]
    assert rx.match(lines[-1])
    margin = lines.pop()
    this_many = len(margin)
    for i in range(1, len(lines)):
        raw = lines[i]
        if '\n' == raw:
            yield raw
            continue
        head = raw[:this_many]
        tail = raw[this_many:]
        assert rx.match(head)
        yield tail


class _Pretend_FH_Just_for_Name():
    def __init__(self):
        self.name = '/pretend/my-schema.dot'


pretend_FH_just_for_name = _Pretend_FH_Just_for_Name()
same = 'schema_out_of_sync'


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
