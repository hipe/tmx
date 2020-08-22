from kiss_rdb_test.common_initial_state import functions_for
from modality_agnostic.memoization import \
        dangerous_memoize as shared_subject
import unittest


class CommonCase(unittest.TestCase):

    def build_big_patchfile(self):
        bpf, emis = self.build_patchfiles_and_emissions()
        assert(0 == len(emis))
        return bpf

    def build_patchfiles_and_emissions(self):

        emissions = []

        def listener(sev, shape, cat, *rest):
            *chan_tail, f = rest
            chan = (sev, shape, cat, *chan_tail)
            if 'structure' == shape:
                lines = (repr(f()),)
            else:
                assert('expression' == shape)
                lines = tuple(f())

            if self.do_debug:
                from sys import stderr
                stderr.write(repr((chan, lines)))
                stderr.write('\n')

            emissions.append((chan, lines))

        def rng(pool_size):
            return pool_size - 1  # ..

        fixture_directory_for = functions_for('eno').fixture_directory_for
        directory = fixture_directory_for('050-canon-main')
        coll = collection_via_collection_path_(directory, rng)

        eidr = coll.RESERVE_NEW_ENTITY_IDENTIFIER(listener)
        eidr = eidr.to_dictionary()

        def o(*ent_cud):
            ents_uows.append(ent_cud)
        ents_uows = []

        o('create_entity', 'VLF', 'create_attribute', 'heading', '«heading»')
        o('create_entity', 'VLF', 'create_attribute', 'body', '«body»')
        o('update_entity', '2HJ', 'create_attribute', 'children', ('VLF'))
        o('create_entity', 'VLF', 'create_attribute', 'parent', '2HJ')

        o = {}
        o['eidr'] = eidr
        o['entities_uows'] = tuple(ents_uows)
        o['order'] = ('parent', 'heading', 'body', 'children')
        o['listener'] = listener

        bpf = coll._build_big_patchfile(**o)
        return bpf, tuple(emissions)

    do_debug = True


def against(offset):
    def decorator(orig_f):
        def use_f(self):
            several = self.against_these()
            actual = several[offset]
            acts = list(reversed(actual))

            for directives in orig_f(self):
                direc_stack = list(reversed(directives))
                typ = direc_stack.pop()
                if 'ignore_line' == typ:
                    acts.pop()
                    continue
                if 'equal' == typ:
                    expected, = direc_stack
                    self.assertEqual(acts.pop(), expected)
                    continue
                if 'search' == typ:
                    rxs, = direc_stack
                    self.assertRegex(acts.pop(), rxs)
                    continue
                if 'this_many_more_lines' == typ:
                    this_many, = direc_stack
                    self.assertEqual(len(acts), this_many)
                    break
                if 'skip_to_last_this_many' == typ:
                    this_many, = direc_stack
                    acts = acts[0:this_many]
                    continue
                assert()
        return use_f
    return decorator


class Case4850_SOMETHING(CommonCase):

    @against(1)
    def test_100_patch_to_create_file_looks_right(self):
        yield 'equal', '--- /dev/null\n'
        yield 'search', r'^\+\+\+ b'
        yield 'equal', '@@ -0,0 +1,9 @@\n'
        yield 'equal', '+# entity: VLF: attributes\n'
        yield 'this_many_more_lines', 8

    @against(2)
    def test_200_patch_to_alter_file_looks_right(self):
        yield 'ignore_line',
        yield 'ignore_line',
        yield 'equal', '@@ -1,5 +1,6 @@\n'
        yield 'equal', ' # entity: 2HJ: attributes\n'
        yield 'equal', ' \n'
        yield 'equal', '+children: VLF\n'
        yield 'this_many_more_lines', 3

    @against(0)
    def test_300_patch_for_index_file_looks_right(self):
        yield 'search', r'\.entity-index\.txt$'
        yield 'search', r'\.entity-index\.txt$'
        yield 'skip_to_last_this_many', 2
        yield 'equal', '+ Z\n'
        yield 'equal', '+Z (                                                              Z)\n'  # noqa: E501

    @shared_subject
    def against_these(self):
        bpf = self.build_big_patchfile()
        one, two, three = bpf.patches
        return tuple(o.diff_lines for o in (one, two, three))


def collection_via_collection_path_(dir_path, rng):
    from kiss_rdb.storage_adapters_.eno import eno_collection_via_
    return eno_collection_via_(dir_path, rng=rng)


if __name__ == '__main__':
    unittest.main()

# #born.
