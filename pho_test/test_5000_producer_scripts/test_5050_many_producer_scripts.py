from modality_agnostic.test_support.common import lazy
import unittest


def o(  # #decorator
    module_entry,
    skip_reason=None,       # freeform value. reason for not covering
    has_bundled_test=None,  # is there a test that can be run with --test
    see=None,               # a string with a case identifier
    worked=None,            # value must be 'visually'. just for notation
    broken_scrape=None,     # t/f if there's a known issue (wontfix)
    is_shell_script=None,   # t/f. we don't test shell scripts for now
        ):

    def class_decorator(orig_class):

        def test_050_everything(tc):
            # Make sure the item under test still correponds to a real script
            esi = _existing_script_index()
            if not esi.has_script_via_module_entry(module_entry):
                msg = f"exists in tests but not in real life: {s()}"
                tc.fail(msg)

            # If a skip reason, skip
            if skip_reason:
                print(f"\n(skipping '{module_entry}' because {skip_reason})")
                return

            # If it exists and it has its own test, that's all we need
            if has_bundled_test:
                return _run_this_test(tc, module_entry)

            # FOR NOW, if another test covers the internals of this script,
            # (according to us saying it does), it passes
            if see:
                return

            # If it's a known broken scrape, skip hmm
            if broken_scrape:
                return

            # If it's a shell script, we don't test it for now
            if is_shell_script:
                return

            # If you've seen it work visually, add a test!
            if 'visually' == worked:
                tc.fail("If you've seen it work visually, add a test!")

            # If it didn't work visually and you didn't add a note
            tc.fail("if it doesn't work visually, add a note or delete it")

        setattr(orig_class, 'test_050_everything', test_050_everything)
        return orig_class

    def s():
        return module_entry

    _tested_tings.append(module_entry)
    return class_decorator


_tested_tings = []
_prefix = 'script/producer_scripts'


class Case(unittest.TestCase):
    do_debug = False


@o('script_180920_hugo_themes', skip_reason="#open [#882.1] cover me")
class Case5880_hugo_themes_all(Case):
    pass


@o('script_180306_woody_allen_movies', has_bundled_test=True)
class Case5881_wam(Case):
    pass


@o('script_180421_heroku_add_ons', see='Case3392', worked='visually')
class Case5882_hao(Case):
    pass


@o('script_180421_khong_lessons', see='Case2872DP',
   skip_reason='HTTP Status 406 - K Hong resisting our efforts to scrape?')
class Case5883_kl(Case):
    pass


@o('script_180618_03_parser_generators_via_python_wiki',
   see='Case2763DP', worked='visualy')
class Case5884_pgvpw(Case):
    pass


@o('script_180618_22_parser_generators_via_bernstein',
   see='Case3459DP', worked='visually')
class Case5885_pgvb(Case):
    pass


@o('script_180815_hugo_docs', see='Case2757', worked='visually')
class Case5886_hd(Case):
    pass


@o('script_180905_hugo_themes', see='Case3395DP', worked='visually')
class Case5887_ht(Case):
    pass


@o('script_180920_hugo_relevant_themes_collection_metadata_via_themes_dir',
   see='Case4975NC', worked='visually')
class Case5888_hrt(Case):
    pass


@o('script_180920_hugo_theme_directory_stream_via_themes_dir',
   see='Case4975NC', worked='visually')
class Case5889_htd(Case):
    pass


@o('script_180920_hugo_theme_toml_stream_via_themes_dir',
   see='Case4975NC', worked='visually')
class Case5889_htts(Case):
    pass


@o('script_181223_kubernetes_document_urls', is_shell_script=True)
class Case5890_kdu(Case):
    pass


@o('script_181223_kubernetes_json_stream_via_TOC_page_url',
   broken_scrape=True)
class Case5891_kjs(Case):
    pass


@o('script_200117_electron_resources',
   worked='visually', skip_reason="#open [#882.1] cover me")
class Case5892_er(Case):
    pass


class Case589Z_make_sure_everything_covered(Case):
    def test_050_everything_covered(self):
        esi = _existing_script_index()
        not_covered = esi.entries_set - set(_tested_tings)
        if 0 == len(not_covered):
            return
        _ = ', '.join(not_covered)
        self.fail(f"this/these script(s) exist in real life but not covered: {_}")  # noqa: E501


# ==

def _run_this_test(tc, module_entry):
    def do_debug():
        return tc.do_debug

    import script_lib.test_support.expect_STDs as lib
    soutr = lib.build_write_receiver_for_debugging('DBG SOUT: ', do_debug)
    serrr = lib.build_write_receiver_for_debugging('DBG SERR: ', do_debug)
    sout = lib.spy_on_write_via_receivers((soutr,))
    serr = lib.spy_on_write_via_receivers((serrr,))

    argv = '[me]', '--test'

    cli = _CLI_via_module(module_entry)
    ec = cli(None, sout, serr, argv)

    tc.assertEqual(ec, 0)


def _CLI_via_module(module_entry):
    from os import path as os_path
    use_path = os_path.join(_prefix, module_entry)

    esi = _existing_script_index()
    ext = esi.ext_via_entry[module_entry]
    if ext:
        use_path += ext

    # Big hacks ahead (we don't want to make 2 branch nodes modules)

    with open(use_path) as fh:
        big_string = fh.read()

    amazing = {}
    x = exec(big_string, amazing, amazing)
    assert x is None
    return amazing['_CLI']


@lazy
def _existing_script_index():
    entries = set()
    ext_via_entry = {}

    from os import listdir
    from os.path import splitext
    from fnmatch import fnmatch

    for entry in listdir(_prefix):
        if not fnmatch(entry, '[!_]*'):
            continue
        entry, ext = splitext(entry)
        entries.add(entry)
        ext_via_entry[entry] = ext

    class index:  # #class-as-namespace
        def has_script_via_module_entry(k):
            return k in entries

        entries_set = entries
    index.ext_via_entry = ext_via_entry
    return index


def xx(msg=None):
    raise RuntimeError(''.join(('write me', *((': ', msg) if msg else ()))))


if __name__ == '__main__':
    unittest.main()

# #born
