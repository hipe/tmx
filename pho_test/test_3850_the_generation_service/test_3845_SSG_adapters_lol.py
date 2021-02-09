from modality_agnostic.test_support.common import \
        listener_and_emissions_for, lazy, \
        dangerous_memoize_in_child_classes as shared_subject_in_child_classes
from unittest import TestCase as unittest_TestCase, main as unittest_main


# == Decorators

def o(which):
    def decorator(orig_f):
        def use_f(tc):
            am = these[which]()
            tc.given_adapter_module = lambda: am
            orig_f(tc)
        return use_f
    return decorator


def common_end_state(orig_f):
    def use_f(tc):
        return {k: v for k, v in orig_f(tc)}
    return property(shared_subject_in_child_classes(use_f))


def fake_business_collection(orig_f):
    def use_f():
        lines = orig_f()
        from pho_test.fake_collection import omg_fake_bcoll_via_lines as func
        return func(lines)
    return lazy(use_f)

# ==


class CommonCase(unittest_TestCase):
    do_debug = False


class ProperCase(CommonCase):

    # == Tests

    def no_emissions(self):
        emis = self.end_state['emissions']
        assert 0 == len(emis)

    # == End State Components (for use in tests)

    @property
    def end_state_markdown_paths(self):
        return (d[1] for d in self.markdown_file_directives)

    @property
    def markdown_file_directives(self):
        return (d for d in self.end_state['directives']
                if 'markdown_file' == d[0])

    @property
    @shared_subject_in_child_classes
    def end_state(self):
        return self.build_end_state()

    # == Support

    def build_end_state_for_generate_markdown(self, eid=None):
        return {k: v for k, v in self.do_build_end_state_for_etc(eid)}

    def do_build_end_state_for_etc(self, eid):
        listener, emis = listener_and_emissions_for(self)
        bcoll = self.given_business_collection()
        ad = self.given_adapter_module()
        direcs = ad.generate_markdown(bcoll, listener, NCID=eid)
        yield 'directives', tuple(direcs)
        yield 'emissions', emis


class Document_Tree_Given_EID(ProperCase):

    def directive_types_and_number_of_directives_looks_right(self):
        exp = 'markdown_file', 'markdown_file'
        act = tuple(tup[0] for tup in self.end_state['directives'])
        self.assertSequenceEqual(act, exp)

    def build_end_state(self):
        return self.build_end_state_for_generate_markdown('A')

    def given_business_collection(_):
        return business_collection_ONE()


class Document_Given_EID(ProperCase):

    def directive_types_and_number_of_directives_looks_right(self):
        exp = ('markdown_file',)
        act = tuple(tup[0] for tup in self.end_state['directives'])
        self.assertSequenceEqual(act, exp)

    def build_end_state(self):
        return self.build_end_state_for_generate_markdown('Fd')

    def given_business_collection(_):
        return business_collection_ONE()


class SmallsCase(CommonCase):

    def you_must_choose_one(self):
        listener, emis = listener_and_emissions_for(self)
        bcoll = business_collection_ONE()  # ..
        wow = self.given_adapter_module().generate_markdown(bcoll, listener)

        res = tuple(wow)
        assert 'adapter_error' == res[0][0]

        emi, = emis
        assert 'multiple_node_trees' == emi.channel[-1]

        act = emi.to_messages()
        exp = 'Multiple node trees, choose one:', 'A, B, C.'
        self.assertSequenceEqual(act, exp)

    def the_adapter_loads(self):
        assert self.given_adapter_module().HELLO_I_AM_AN_ADAPTER_MODULE


# ==

class Case3845_135_smalls(SmallsCase):

    @o('huggo')
    def test_010_loads(self):
        self.the_adapter_loads()

    @o('peloocan')
    def test_020_loads(self):
        self.the_adapter_loads()

    @o('huggo')
    def test_030_you_must_chose_one(self):
        self.you_must_choose_one()

    @o('peloocan')
    def test_040_you_must_chose_one(self):
        self.you_must_choose_one()

    def given_business_collection(_):
        return business_collection_ONE()


class Case3845_200_document_tree_given_EID_huggo(Document_Tree_Given_EID):

    def test_010_directive_types_OK(self):
        self.directive_types_and_number_of_directives_looks_right()

    def test_050_paths_OK(self):
        # (order matters, we are asserting it. the way the parsers parses it..)

        paths = tuple(tup[1] for tup in self.markdown_file_directives)

        same = 'hello-I-am-the-heading-for-A/GENERATED-'
        path1 = f"{same}Fd-hello-i-am-the-heading-for-fd.md"
        path2 = f"{same}Gd-hello-i-am-the-heading-for-gd.md"

        self.assertSequenceEqual(paths, (path1, path2))

    def test_100_file_content_OK(self):
        lines_itrs = tuple(tup[2] for tup in self.markdown_file_directives)
        liness = tuple(tuple(itr) for itr in lines_itrs)

        # [#882.U] newilnes inserted

        self.assertIn(len(liness[0]), range(10, 11))
        self.assertIn(len(liness[1]), range(6, 7))

        big_s_1, big_s_2 = (''.join(a) for a in liness)

        looks_like_the_Fd_content_for_huggo(self, big_s_1)

        assert '---' == big_s_2[:3]  # frontmatter
        needle = "Hello i am the body for 'Gd'"
        self.assertIn(needle, big_s_2)

    def test_200_no_emissions(self):
        self.no_emissions()

    def given_adapter_module(_):
        return these['huggo']()


class Case3845_230_document_tree_given_EID_peloogan(Document_Tree_Given_EID):

    def test_010_directive_types_OK(self):
        self.directive_types_and_number_of_directives_looks_right()

    def test_050_paths_OK(self):
        # (order matters, we are asserting it. the way the parsers parses it..)

        paths = tuple(tup[1] for tup in self.markdown_file_directives)

        # (no more deep paths at #history-B.5)
        path1 = "hello-i-am-the-heading-for-fd.md"
        path2 = "hello-i-am-the-heading-for-gd.md"

        self.assertSequenceEqual(paths, (path1, path2))

    def test_100_file_content_OK(self):
        lines_itrs = tuple(tup[2] for tup in self.markdown_file_directives)
        liness = tuple(tuple(itr) for itr in lines_itrs)

        looks_like_the_Fd_content_for_peloocan(self, liness[0])

        exp = tuple(self.expected_lines_for_second_file())
        self.assertSequenceEqual(liness[1], exp)

    def expected_lines_for_second_file(_):
        yield 'title: Hello I am the heading for \'Gd\'\n'
        yield 'date: 1925-05-19 12:13:14+05:00\n'
        # (expecting needing a dividing blank line here)
        yield "Hello i am the body for 'Gd' KISS For now\n"
        yield "line 2\n"

    def test_200_no_emissions(self):
        self.no_emissions()

    def given_adapter_module(_):
        return these['peloocan']()


class Case3845_265_document_given_EID_huggo(Document_Given_EID):

    def test_010_directive_types_OK(self):
        self.directive_types_and_number_of_directives_looks_right()

    def test_050_path_is_only_component_deep(self):
        (_, path, lines), = self.markdown_file_directives
        assert 'GENERATED-Fd-hello-i-am-the-heading-for-fd.md' == path

    def test_100_content_OK(self):
        (_, path, lines), = self.markdown_file_directives
        big_s = ''.join(lines)
        looks_like_the_Fd_content_for_huggo(self, big_s)

    def test_200_no_emissions(self):
        self.no_emissions()

    def given_adapter_module(_):
        return these['huggo']()


class Case3845_285_document_given_EID_peloogan(Document_Given_EID):

    def test_010_directive_types_OK(self):
        self.directive_types_and_number_of_directives_looks_right()

    def test_050_path_is_only_component_deep(self):
        (_, path, lines), = self.markdown_file_directives
        assert 'hello-i-am-the-heading-for-fd.md' == path

    def test_100_content_OK(self):
        (_, path, lines), = self.markdown_file_directives
        looks_like_the_Fd_content_for_peloocan(self, tuple(lines))

    def test_200_no_emissions(self):
        self.no_emissions()

    def given_adapter_module(_):
        return these['peloocan']()


def looks_like_the_Fd_content_for_peloocan(tc, lines):
    tc.assertSequenceEqual(lines, tuple(_these_peloocan_lines()))


def _these_peloocan_lines():
    yield "title: Hello I am the heading for 'Fd'\n"
    yield 'date: 1925-05-19 12:13:14+05:00\n'
    # (expecting needing a dividing blank line here)
    yield "Hello i am the body for 'Fd' KISS For now\n"
    yield "line 2\n"
    yield "\n"  # new in [#882.U]
    yield "## Hello I am the heading for 'H'\n"
    yield "Hello i am the body for 'H' KISS For now\n"
    yield "line 2\n"


def looks_like_the_Fd_content_for_huggo(tc, big_s):

    assert '---' == big_s[:3]

    needle = "Hello i am the body for 'Fd'"
    tc.assertIn(needle, big_s)

    needle = "Hello i am the body for 'H'"
    tc.assertIn(needle, big_s)


@fake_business_collection
def business_collection_ONE():
    yield r"                  A               "
    yield r"     B           / \              "
    yield r"    / \         /   \      C      "
    yield r"   Dd  E       /     Fd           "
    yield r"              /     /             "
    yield r"             Gd    H              "


def these():

    @lazy
    def huggo():
        from pho.SSG_adapters_ import hugo as module
        return module

    @lazy
    def peloocan():
        from pho.SSG_adapters_ import pelican as module
        return module

    return locals()


these = these()


def xx(msg=None):
    raise RuntimeError(''.join(('ohai', *((': ', msg) if msg else ()))))


if __name__ == '__main__':
    unittest_main()

# #history-B.5
# #history-B.4 spike peloogan intro (and most of its integration to date)
# #born
