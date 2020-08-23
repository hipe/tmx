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

        from kiss_rdb.storage_adapters_.eno.blocks_via_path_ import \
            _new_file_blocks, emitter_via_monitor__

        coll = collection_via_collection_path_('/dev/null')
        mon = coll.monitor_via_listener_(listener)
        emi = emitter_via_monitor__(mon)
        edits, order = self.given_edit()
        lines = (*self.given_lines(), *ugh)

        blks = _new_file_blocks(edits, coll, order, emi, lines=lines)

        catch_this = emi.stopper_exception_class
        try:
            for block in blks:
                for line in block.to_lines():
                    output_lines.append(line)
        except catch_this:
            return None, tuple(emissions)

        for i in reversed(range(0, len(ugh))):
            if ugh[i] == output_lines[-1]:
                output_lines.pop()
            else:
                break

        assert(not(len(emissions)))
        return tuple(output_lines), None

    do_debug = False


class Case4805_delete_attribute(CommonCase):

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


class Case4808_create(CommonCase):

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


class Case4811_update_attribute(CommonCase):
    # doesn't change order

    def test_100(self):
        self.expect_success()

    def given_edit(self):
        edit = {'city_of_origin': ('update_attribute', 'Stewartsville')}
        return {'ABC': ('update_entity', edit)}, order

    def expect_lines(self):
        yield ABC_line
        yield 'city_of_origin: Stewartsville\n'
        yield 'height: whatever\n'

    def given_lines(self):
        yield ABC_line
        yield 'city_of_origin: wherever\n'
        yield 'height: whatever\n'


class Case4812_update_multiline(CommonCase):

    def test_100(self):
        self.expect_success()

    def given_edit(self):
        edit = {'body_hello': ('update_attribute', "new line 1\nnew line 2")}
        return {'ABC': ('update_entity', edit)}, ('body_hello',)

    def expect_lines(self):
        yield ABC_line
        yield '-- body_hello\n'
        yield 'new line 1\n'
        yield 'new line 2\n'
        yield '\n'  # this is gonna be a thing now, everywhere
        yield '-- body_hello\n'

    def given_lines(self):
        yield ABC_line
        yield '-- body_hello\n'
        yield 'orig line 1\n'
        yield 'orig line 2\n'
        yield 'orig line 3\n'
        yield '-- body_hello\n'


class Case4814_cant_delete_entity_because_touching_comments(CommonCase):

    def test_100(self):
        (chan, lines), = self.build_end_emissions()
        line1, line2 = lines
        self.assertIn("Won't delete entity 'DEF' because", line1)
        self.assertIn('comments in "slot A"', line1)
        self.assertIn('> comment about below', line2)

    def given_edit(self):
        return {'DEF': ('delete_entity',)}, order

    def given_lines(self):
        yield ABC_line
        yield 'foo: bar\n'
        yield '> comment about above\n'
        yield '\n'
        yield '> comment about below (but parsed as part of above)\n'
        yield '# entity: DEF: attributes\n'


class Case4817_cant_delete_entity_because_slot_B(CommonCase):

    def test_100(self):
        (chan, lines), = self.build_end_emissions()
        line1, line2 = lines
        self.assertIn("it has associated comments", line1)
        self.assertIn('> literally any comment', line2)

    def given_edit(self):
        return {'ABC': ('delete_entity',)}, order

    def given_lines(self):
        yield ABC_line
        yield '> literally any comment'


class Case4820_delete_entity_preserves_slot_A_comment(CommonCase):

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


class Case4823_create_when_collision(CommonCase):

    def test_100(self):
        (chan, lines), = self.build_end_emissions()
        line, = lines
        self.assertEqual(line, "can't create entity 'ABC', entity already exists")  # noqa: E501

    def given_edit(self):
        return {'ABC': ('create_entity', None)}, order

    def given_lines(self):
        yield ABC_line
        yield '> nothing.\n'


class Case4826_create_into_pseudo_empty(CommonCase):

    def test_100(self):
        self.expect_success()

    def given_edit(self):
        these = {'foo': 'bar'}
        return {'ABC': ('create_entity', these)}, order

    def expect_lines(self):
        yield ABC_line
        yield 'foo: bar\n'

    def given_lines(self):
        return ()


class Case4829_create_insert_at_top(CommonCase):

    def test_100(self):
        self.expect_success()

    def given_edit(self):
        these = {'foo': 'bar'}
        return {'ABC': ('create_entity', these)}, order

    def expect_lines(self):
        yield ABC_line
        yield 'foo: bar\n'
        yield '\n'
        yield '# entity: ABD: attributes\n'

    def given_lines(self):
        yield '# entity: ABD: attributes\n'


class Case4832_create_insert_in_middle(CommonCase):

    def test_100(self):
        self.expect_success()

    def given_edit(self):
        these = {'foo': 'bar'}
        return {'ABC': ('create_entity', these)}, order

    def expect_lines(self):
        yield '# entity: ABA: attributes\n'
        yield 'fiz: biz\n'
        yield '> some comment with above\n'
        yield '\n'
        yield ABC_line
        yield 'foo: bar\n'
        yield '\n'
        yield '> some comment with below\n'
        yield '# entity: ABD: attributes\n'

    def given_lines(self):
        yield '# entity: ABA: attributes\n'
        yield 'fiz: biz\n'
        yield '> some comment with above\n'
        yield '\n'
        yield '> some comment with below\n'
        yield '# entity: ABD: attributes\n'


class Case4835_create_append_at_end(CommonCase):  # DO ME

    def test_100(self):
        self.expect_success()

    def given_edit(self):
        these = {'foo': 'bar'}
        return {'ABC': ('create_entity', these)}, order

    def expect_lines(self):
        yield '# entity: ABA: attributes\n'
        yield '\n'
        yield ABC_line
        yield 'foo: bar\n'

    def given_lines(self):
        yield '# entity: ABA: attributes\n'


def collection_via_collection_path_(dir_path):
    from kiss_rdb.storage_adapters_.eno import eno_collection_via_
    return eno_collection_via_(dir_path, rng=None)


ABC_line = '# entity: ABC: attributes\n'
ugh = ('\n', '# document-meta\n')


order = ('height', 'city_of_origin', 'foo', 'biff')


if __name__ == '__main__':
    unittest.main()

# #born.
