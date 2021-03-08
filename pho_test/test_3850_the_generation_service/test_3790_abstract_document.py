from modality_agnostic.test_support.common import lazy
import unittest


class ThisOneMetaclass(type):  # #[#510.16] meta-class

    def __new__(cls, class_name, bases=None, dct=None):
        res = type.__new__(cls, class_name, bases, dct)
        # If the parent class of this class just subclassed is the vendor
        # unittest base class, don't do this hack (because it's support class)
        if unittest.TestCase != bases[-1]:
            setattr(res, 'test', res.do_test)
        return res


class CommonCase(unittest.TestCase):

    @property
    def derived_title(self):
        lines = self.given_native_lines()
        path = self.given_path()
        ad = abstract_document_via(lines, path)
        o = ADAPTER_module().func(ad, listener=None)
        return o.title


class NormTitleCase(unittest.TestCase, metaclass=ThisOneMetaclass):

    def do_test(self):
        def listener(*wow):
            print(f"wow: {wow!r}")
            raise RuntimeError()

        given_title = self.given_abstract_frontmatter_title()
        func = ADAPTER_module()._sluggerer()
        slug = func(given_title, listener)
        act_entry = ''.join((slug, '.md'))
        exp_entry = self.expected_entry()
        self.assertEqual(act_entry, exp_entry)


class Case3782_ting1(NormTitleCase):

    def expected_entry(self):
        return 'swing-ting-2020-rundown-w-joey-b-samrai-r.md'

    def given_abstract_frontmatter_title(self):
        return "Swing Ting 2020 Rundown (w/ Joey B & Samrai) (R)"


class Case3786_empty_native_document(CommonCase):

    def test_xx01_parses_as_abstract_document(self):
        ad = self.abstract_document
        assert 0 == len(ad.sections)

    @property
    def abstract_document(self):
        return this_empty_abstract_document()


class Case3790_look_at_this_document(CommonCase):

    def test_xx02_has_frontmatter(self):
        fm = self.abstract_document.frontmatter
        assert 1 < len(fm)
        for k, v in fm.items():
            assert isinstance(k, str)
            assert isinstance(v, str)

    def test_xx03_this_one_frontmatter_value_was_decoded_without_quotes(self):
        fm = self.abstract_document.frontmatter
        act = fm['title']
        assert act == "chim chum"

    def test_xx03_look_at_this_last_section(self):
        sect = self.abstract_document.sections[-1]
        hdr = sect.header
        assert 2 == hdr.depth
        assert 'document-meta' == hdr.label_text
        act = hdr.to_normalized_line()
        assert "## (document-meta)\n" == act

    def test_xx04_leading_and_trailing_blank_lines_gone(self):
        for sect in self.abstract_document.sections:
            lines = sect.normal_body_lines
            leng = len(lines)
            assert 0 < leng
            assert '\n' != lines[0]
            if 1 < leng:
                assert '\n' != lines[-1]

    @property
    def abstract_document(_):
        return this_one_abstract_document()


class Case3794_when_frontmatter_has_title_use_that(CommonCase):

    def test_010_go(self):
        act = self.derived_title
        assert act == 'choom choom'

    def given_native_lines(_):
        yield '---\n'
        yield 'title: "choom choom"\n'
        yield 'date: 2020-12-31T14:07:00-05:00\n'
        yield '---\n'
        yield '# Section 1\n'
        yield '\n'
        yield '\n'
        yield 'line 1\n'
        yield 'line 2\n'
        yield '\n'
        yield '\n'

    def given_path(_):
        return '/fake-fs/no-see'


class Case3798_when_this_crazy_depth_scenario_use_that(CommonCase):

    def test_010_go(self):
        act = self.derived_title
        assert act == 'Are you Ready to Rumble'

    def given_native_lines(_):
        yield '# Are you Ready to Rumble\n'
        yield 'line 1\n'
        yield '## subsect 1\n'
        yield 'line 1\n'

    def given_path(_):
        return '/fake-fs/no-see'


class Case3802_otherwise_use_path(CommonCase):

    def test_010_go(self):
        act = self.derived_title
        assert act == 'fun times'

    def given_native_lines(_):
        yield '## secto 1\n'
        yield 'line 1-11\n'
        yield '## secto 2\n'
        yield 'line 2-1\n'

    def given_path(_):
        return '/fake-fs/other-dir/101.3-fun-times.md'

    @property
    def abstract_document(_):
        return this_one_abstract_document()


@lazy
def this_one_abstract_document():
    return abstract_document_via(these_one_lines())


@lazy
def this_empty_abstract_document():
    return abstract_document_via(())


def these_one_lines():
    yield '---\n'
    yield "title: 'chim chum'\n"
    yield 'date: 2020-12-30T22:04:00-05:00\n'
    yield '---\n'
    yield '# Section 1\n'
    yield '\n'
    yield '\n'
    yield 'line 1\n'
    yield 'line 2\n'
    yield '\n'
    yield '\n'
    yield '## (document-meta)\n'
    yield '\n'
    yield '  - #born\n'


# == BEGIN

def wahoo(path=None):
    if path is None:
        path = the_pho_doc_documents_path()

    files = glob_markdown_files_via_path(path)

    from sys import stderr as serr
    func = subject_function()
    count = 0
    for markdown_path in files:
        count += 1
        with open(markdown_path) as fh:
            doc = func(fh, path=markdown_path)

        serr.write(markdown_path)
        serr.write('\n')
        for line in doc.to_summary_lines():
            serr.write('  ')
            serr.write(line)

    serr.write(f"{count} files. done\n")


def glob_markdown_files_via_path(path):

    from os.path import join
    glob_path = join(path, '*.md')

    from glob import glob
    return glob(glob_path)


def the_pho_doc_documents_path():
    from sys import modules
    here = modules[__name__].__file__
    from os.path import join, dirname
    return join(dirname(dirname(dirname(here))), 'pho-doc', 'documents')


# == END


def ADAPTER_module():  # tests that cover adapters should be in their own files
    from pho.SSG_adapters_.pelican import \
        native_lines_via_abstract_document as module
    return module


def abstract_document_via(lines, path=None):
    return subject_function()(lines, path=path)


def subject_function():
    return subject_module().abstract_document_via_lines


def subject_module():
    from pho.magnetics_ import \
        abstract_document_via_native_markdown_lines as result
    return result


def xx():
    raise RuntimeError('x')


if __name__ == '__main__':
    from sys import argv
    if 1 < len(argv) and (tok := argv[1])[:7] == '--wahoo':
        path = None
        if 7 < len(tok):
            assert '=' == tok[7]
            path = tok[8:]
        wahoo(path)
    else:
        unittest.main()

# #born
