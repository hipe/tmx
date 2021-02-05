"""
(11:00AM) Primary Objective: effectively "import" content into a notecard
from an external file


Design objectives: Hand-editable, transparent not obtuse, low-redundancy,
works well for batches of files of the typical size


Discussion: We have a large number of existing markdown files that we always
intened to fold in to our new system ~ somehow ~. Now is when we figure out
the "somehow".


Development ~ ~ philosophy ~ ~: at the first outing we don't expect to find
the "best" way, just anything to match this criteria. Iterative


Implementation ideas:

- Mutual Exclusivity: In the class, `body` and `body_function` will co-exist
as ordinary value attributes. (We want them to be settable in the ordinary
way in the GUI). We'll probably create a new function that manages the rule
table of what to do for the four permuations of these two being set or not set.
Maybe we'll be strict at first about them being mutually exclusive. :[#882.S.2]

- Function Call Syntax: A typical `body_function` string value might look like:
"get_content_from_file_in_directory(pho_doc_directory)" Both this "function"
and this symbolic name (variable) will be defined in the schema.rec.
Implementing this novel use of the schema file will probably end up consuming
the most development work here, because it bridges the concerns of two of our
core packages (this one and [kiss-rdb]) and uses an external format that we
have little understanding of at the moment. :[#882.S.3]

- Value variables: A typical such variable will be "../documents"; that is,
it will be defined relative to the collection path. This will be memoized
somehow, so that it is not resolved anew for each notecard that uses it.
:[#882.S.4]

- Rigging the Function: Such functions will be "rigged" in the schema file:
it will point to a python module that can be loaded quite like the way pelican
loads a plugin (but without its namespace thing). The resolution of this
function definition will be memoized somehow, so that it is not resolve anew
for each notecard that uses it :[#883.S.5]

- The most fun (sic) will be implementing the function, which will be a whole
other space of provisions.

(done writing at 11:40AM)
(committing next day at 3:21 PM)
"""

from pho_test.common_initial_state import read_only_business_collection_one
from modality_agnostic.test_support.common import \
        dangerous_memoize as shared_subject
from unittest import TestCase as unittest_TestCase, main as unittest_main


class Case1405_intro_to_value_functions(unittest_TestCase):

    def test_010_everything(self):
        bcoll = read_only_business_collection_one()
        nc = bcoll.retrieve_notecard('PBX', None)
        ad = bcoll.abstract_document_via_notecards((nc,), None)
        sect, = ad.sections
        lines = sect.normal_body_lines
        act, = lines
        exp = 'hello, value func one did a thing: ⇨here is the cha cha⇦\n'
        self.assertEqual(act, exp)


class Case1415_body_via_document(unittest_TestCase):

    def test_050_first_section_content(self):
        act = lines_via_sect(self.end_state_as_two_sections[0])
        exp = tuple(self.expected_lines_for_first_section())
        self.assertSequenceEqual(act, exp)

    def test_100_second_section_content(self):
        act = lines_via_sect(self.end_state_as_two_sections[1])
        exp = tuple(self.expected_lines_for_second_section())
        self.assertSequenceEqual(act, exp)

    @shared_subject
    def end_state_as_two_sections(self):
        bcoll = read_only_business_collection_one()
        nc = bcoll.retrieve_notecard('PBY', None)
        ad = bcoll.abstract_document_via_notecards((nc,), None)
        sect1, sect2 = ad.sections
        return sect1, sect2

    def expected_lines_for_first_section(_):
        yield "## I started life as a Header 1\n"
        yield "Pretend this was a hugo document\n"
        yield "\n"
        yield "```bash\n"
        yield "some code block\n"
        yield "```\n"

    def expected_lines_for_second_section(_):
        yield "### Here have a header 2\n"
        yield "That's the end of the content for old hugo!\n"


def lines_via_sect(sect):
    return tuple(sect.to_normalized_lines())


if __name__ == '__main__':
    unittest_main()

# #born
