import unittest


class CommonCase(unittest.TestCase):

    # @dangerous_memoize_in_child_classes('_ES', 'build_end_state')
    # def end_state(self):

    def go_money(self):
        act = self.build_end_lines()
        exp = tuple(self.expect_lines())
        self.assertSequenceEqual(act, exp)

    def build_end_lines(self):
        output_lines = []

        def listener(sev, shape, cat, *rest):
            *chan_tail, f = rest
            chan = (sev, shape, cat, *chan_tail)
            if 'structure' == shape:
                lines = (repr(f()),)
            else:
                assert('expression' == shape)
                lines = tuple(f())
            print(f"ohai: {repr(chan)} lines: {repr(lines)}")
            # raise RuntimeError('where')

        coll = collection_via_collection_path_('/dev/null')
        mon = coll.monitor_via_listener_(listener)
        edits, order = self.given_edit()
        lines = (*self.given_lines(), *ugh)

        from kiss_rdb.storage_adapters_.eno.blocks_via_path_ import \
            _new_file_blocks
        blks = _new_file_blocks(edits, coll, order, mon, lines=lines)

        for block in blks:
            for line in block.to_lines():
                output_lines.append(line)

        for i in reversed(range(0, len(ugh))):
            if ugh[i] == output_lines[-1]:
                output_lines.pop()
            else:
                break

        return tuple(output_lines)

    do_debug = False


class Case_XXXX_delete(CommonCase):

    def test_100(self):
        self.go_money()

    def given_edit(self):
        return {'ABC': {'flavor': ('delete_attribute',)}}, ('flavor',)

    def expect_lines(self):
        yield '# entity: ABC: attributes\n'

    def given_lines(self):
        yield '# entity: ABC: attributes\n'
        yield 'flavor: red\n'


class Case_XXXX_create(CommonCase):

    def test_100(self):
        self.go_money()

    def given_edit(self):
        order = ('wahoo', 'flavor')
        return {'ABC': {'wahoo': ('create_attribute', 'yippie')}}, order

    def expect_lines(self):
        yield ABC_line
        yield 'wahoo: yippie\n'
        yield 'flavor: red\n'

    def given_lines(self):
        yield ABC_line
        yield 'flavor: red\n'


class Case_XXXX_update(CommonCase):
    # doesn't change order

    def test_100(self):
        self.go_money()

    def given_edit(self):
        return {'ABC': {'city_of_origin': ('update_attribute', 'Stewartsville')}}, order  # noqa: E501

    def expect_lines(self):
        yield ABC_line
        yield 'city_of_origin: Stewartsville\n'
        yield 'height: whatever\n'

    def given_lines(self):
        yield ABC_line
        yield 'city_of_origin: wherever\n'
        yield 'height: whatever\n'


def collection_via_collection_path_(dir_path):
    from kiss_rdb.storage_adapters_.eno import collection_via_collection_path_
    return collection_via_collection_path_(dir_path)


ABC_line = '# entity: ABC: attributes\n'
ugh = ('\n', '# document-meta\n')


order = ('height', 'city_of_origin')


if __name__ == '__main__':
    unittest.main()

# #born.
