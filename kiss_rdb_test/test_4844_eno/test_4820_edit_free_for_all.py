import unittest


class CommonCase(unittest.TestCase):

    # @dangerous_memoize_in_child_classes('_ES', 'build_end_state')
    # def end_state(self):

    def expect_success(self):
        act = self.build_end_lines()
        self.assertIsNotNone(act)
        exp = tuple(self.expect_lines())
        self.assertSequenceEqual(act, exp)

    def build_end_lines(self):
        return self.build_end_lines_and_emissions()[0]

    def build_end_emissions(self):
        return self.build_end_lines_and_emissions()[1]

    def build_end_lines_and_emissions(self):

        output_lines = []
        emissions = []

        def listener(sev, shape, cat, *rest):
            *chan_tail, f = rest
            chan = (sev, shape, cat, *chan_tail)
            if 'structure' == shape:
                lines = (repr(f()),)
            else:
                assert('expression' == shape)
                lines = tuple(f())
            emissions.append((chan, lines))

        coll = collection_via_collection_path_('/dev/null')
        mon = coll.monitor_via_listener_(listener)
        edits, order = self.given_edit()
        lines = (*self.given_lines(), *ugh)

        from kiss_rdb.storage_adapters_.eno.blocks_via_path_ import \
            _new_file_blocks, _Stop

        blks = _new_file_blocks(edits, coll, order, mon, lines=lines)

        try:
            for block in blks:
                for line in block.to_lines():
                    output_lines.append(line)
        except _Stop:
            return None, tuple(emissions)

        for i in reversed(range(0, len(ugh))):
            if ugh[i] == output_lines[-1]:
                output_lines.pop()
            else:
                break

        assert(not(len(emissions)))
        return tuple(output_lines), None

    do_debug = False


class Case_XXXX_delete_attribute(CommonCase):

    def test_100(self):
        self.expect_success()

    def given_edit(self):
        edits = {'flavor': ('delete_attribute',)}
        return {'ABC': ('update_entity', edits)}, ('flavor',)

    def expect_lines(self):
        yield '# entity: ABC: attributes\n'

    def given_lines(self):
        yield '# entity: ABC: attributes\n'
        yield 'flavor: red\n'


class Case_XXXX_create(CommonCase):

    def test_100(self):
        self.expect_success()

    def given_edit(self):
        edits = {'wahoo': ('create_attribute', 'yippie')}
        order = ('wahoo', 'flavor')
        return {'ABC': ('update_entity', edits)}, order

    def expect_lines(self):
        yield ABC_line
        yield 'wahoo: yippie\n'
        yield 'flavor: red\n'

    def given_lines(self):
        yield ABC_line
        yield 'flavor: red\n'


class Case_XXXX_update_attribute(CommonCase):
    # doesn't change order

    def test_100(self):
        self.expect_success()

    def given_edit(self):
        edit = {'city_of_origin': ('update_attribute', 'Stewartsville')}
        return {'ABC': ('update_entity', edit)}, order  # noqa: E501

    def expect_lines(self):
        yield ABC_line
        yield 'city_of_origin: Stewartsville\n'
        yield 'height: whatever\n'

    def given_lines(self):
        yield ABC_line
        yield 'city_of_origin: wherever\n'
        yield 'height: whatever\n'


class CaseXXXX_cant_delete_entity_because_touching_comments(CommonCase):

    def test_100(self):
        (chan, lines), = self.build_end_emissions()
        line1, line2 = lines
        self.assertIn("can't delete an entity because the entity above", line1)
        self.assertIn('> comment about above', line2)

    def given_edit(self):
        return {'DEF': ('delete_entity',)}, order

    def given_lines(self):
        yield ABC_line
        yield 'foo: bar\n'
        yield '> comment about above\n'
        yield '\n'
        yield '> comment about below (but parsed as part of above)\n'
        yield '# entity: DEF: attributes\n'


class CaseXXXX_cant_delete_entity_because_slot_B(CommonCase):

    def test_100(self):
        (chan, lines), = self.build_end_emissions()
        line1, line2 = lines
        self.assertIn("it has associated comments", line1)
        self.assertIn('> literally any comment', line2)

    def given_edit(self):
        return {'ABC': ('delete_entity',)}, order

    def given_lines(self):
        yield ABC_line
        yield '\n'
        yield '> literally any comment'


class Case_XXXX_delete_entity_preserves_slot_A_comment(CommonCase):

    def test_100(self):
        self.expect_success()

    def given_edit(self):
        return {'DEF': ('delete_entity',)}, None

    def expect_lines(self):
        yield ABC_line
        yield 'foo: bar A\n'
        yield '\n'
        yield '> what about this comment\n'
        yield '# entity: GHJ: attributes\n'
        yield 'foo: bar G\n'

    def given_lines(self):
        yield ABC_line
        yield 'foo: bar A\n'
        yield '\n'
        yield '# entity: DEF: attributes\n'
        yield 'foo: bar D\n'
        yield '> this comment is with thing\n'
        yield '\n'
        yield '> what about this comment\n'
        yield '# entity: GHJ: attributes\n'
        yield 'foo: bar G\n'


def collection_via_collection_path_(dir_path):
    from kiss_rdb.storage_adapters_.eno import collection_via_collection_path_
    return collection_via_collection_path_(dir_path)


ABC_line = '# entity: ABC: attributes\n'
ugh = ('\n', '# document-meta\n')


order = ('height', 'city_of_origin')


if __name__ == '__main__':
    unittest.main()

# #born.
