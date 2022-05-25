from modality_agnostic.test_support.common import \
        dangerous_memoize as shared_subject
from unittest import TestCase as unittest_TestCase, main as unittest_main


class CommonCase(unittest_TestCase):

    def test_010_MESSY(self):
        abs_sch = abstract_schema_via_sexp(("abstract_schema",
            ("properties",),
            ("abstract_entity", "AA",
                ("abstract_attribute", "BB", "text", "key"),
                ("abstract_attribute", "CC", "text", "optional"),
            )))
        mod = subject_module()
        coll = mod._DUMMY_COLL(abs_sch['AA'])
        lines = subject_module().html_form_via_SOMETHING_ON_THE_MOVE_(coll)
        seen = {}
        import re
        rx = re.compile('^[ ]*</?([a-z]+)')
        count = 0
        for line in lines:
            count += 1
            md = rx.match(line)
            if not md:
                raise f"oops: {line!r}"
            seen[md[1]] = None

        act = sorted(seen.keys())
        exp = 'form input table td th tr'.split()
        self.assertSequenceEqual(act, exp)


def abstract_schema_via_sexp(sx):
    from kiss_rdb.magnetics_.abstract_schema_via_sexp import \
            _abstract_schema_via_sexp as func
    return func(sx)


def subject_module():
    import kiss_rdb.storage_adapters.html.form_via_formal_entity as mod
    return mod


if __name__ == '__main__':
    unittest_main()

# #born
