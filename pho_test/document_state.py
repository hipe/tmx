from unittest import TestCase


# == Case Parent Classes


class CaseMetaClass(type):
    # Make it so when the below parent class is subclassed, the subclasses
    # get a "test" method, but the parent itself doesn't have a "test" method
    # because if it had one and you import it into your module, it auto runs

    def __new__(cls, class_name, bases=None, dct=None):
        res = type.__new__(cls, class_name, bases, dct)
        if TestCase != bases[-1]:
            setattr(res, 'test', res.definition_for_the_method_called_test())
        return res


class SexpCase(TestCase, metaclass=CaseMetaClass):
    # For asserting how the `body` attribute (content lines) are broken into
    # a stream of S-expressions; the first pass of parsing notecards for md

    def definition_for_the_method_called_test():
        return the_method_called_test_for_the_sexp_case


def the_method_called_test_for_the_sexp_case(self):

    act = tuple(subject_module()._sexps_via_lines(self.given_lines()))

    exp = tuple(((row, None) if isinstance(row, str) else row)
                for row in self.expected_sexps())

    act_types = tuple(sx[0] for sx in act)
    exp_types = tuple(two[0] for two in exp)
    self.assertSequenceEqual(act_types, exp_types)

    for i in range(0, len(exp)):
        exp_x = exp[i][1]
        if exp_x is None:
            continue
        act_x = act[i][1]
        if isinstance(act_x, tuple):
            use_num = len(act_x)
        else:
            assert isinstance(act_x, int)
            use_num = act_x
        if exp_x == use_num:
            continue
        raise RuntimeError(f"had {use_num} expected {exp_x} at offset {i}")


# ==

def document_state_via_notecards(frag_itr):
    use_itr = ((h, _body_via_lines(lines)) for h, lines in frag_itr)
    ad = subject_module().abstract_document_via_notecards_(use_itr)

    # NOTE for now we're just trying to bridge back to 17 month old code
    # to get old tests to pass (asserting still current specs). But when
    # we introduce abstract document procurement, do that here probably

    class document_state:  # #clas-as-n

        @property
        def document_title(_):
            return ad.frontmatter['title']

        @property
        def first_section(self):
            return self.section_at(0)

        def section_at(_, offset):
            return ad.sections[offset]

        @property
        def AD(_):
            return ad

    return document_state()


def final_sexps_via_notecards(notecards):

    def these():
        for heading, lines in notecards:
            yield heading, _body_via_lines(lines)

    sxs = tuple(subject_module()._final_sexps(these()))
    return _SexpAccessor(sxs)


class _SexpAccessor:

    def __init__(self, sexps):
        self.sexps = sexps

    def first(self, key):
        return first_in_sexps(self.sexps, key)

    def last(self, key):
        return last_in_sexps(self.sexps, key)

    def all(self, key):
        return all_in_sexps(self.sexps, key)


def last_in_sexps(sexps, key):
    for sx in reversed(sexps):
        if key == sx[0]:
            return sx
    raise KeyError(key)


def first_in_sexps(sexps, key):
    for sx in sexps:
        if key == sx[0]:
            return sx
    raise KeyError(key)


def all_in_sexps(sexps, key):
    return (sx for sx in sexps if key == sx[0])


def _body_via_lines(lines):
    return ''.join(_add_newline(s) for s in lines)


def _add_newline(s):
    # not needing newlines in the tests make them easier to read
    # but let's add a sanity check because this breaks a deep convention
    assert(0 == len(s) or '\n' != s[-1])
    return f'{s}\n'


# ==

def subject_module():
    import pho.notecards_.document_via_notecards as mod
    return mod


def xx(msg):
    raise RuntimeError(msg)

# #born.
