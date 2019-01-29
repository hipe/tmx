import _common_state  # noqa: F401
import unittest


class _CommonCase(unittest.TestCase):

    def expect_edit(self):
        dll = self.given_edit()
        _actual = tuple(dll.to_item_stream())
        _expected = self.expect_these_items()
        self.assertEqual(_actual, _expected)

    def expect_backwards(self):

        _ = self.expect_these_items()
        _expected = list(reversed(_))

        a = []
        dll = self.given_edit()
        item_via = dll.item_via_IID
        prev_via = dll.prev_IID_via_IID
        iid = dll.tail_IDD()
        while iid is not None:
            a.append(item_via(iid))
            iid = prev_via(iid)

        self.assertEqual(a, _expected)


def _common_shared_state(orig_f):
    first = True
    dll = None

    def new_f(self):
        nonlocal first
        nonlocal dll
        if first:
            first = False
            dll = _subject_module().build_new_doubly_linked_list()
            orig_f(None, dll)  # don't pass self unless we really need to
        return dll
    return new_f


class Case000_empty(_CommonCase):

    def test_100_edit(self):
        self.expect_edit()

    def test_200_backwards(self):
        self.expect_backwards()

    def expect_these_items(self):
        return ()

    @_common_shared_state
    def given_edit(self, dll):
        pass


class Case100_append_to_empty(_CommonCase):

    def test_100_edit(self):
        self.expect_edit()

    def test_200_backwards(self):
        self.expect_backwards()

    def expect_these_items(self):
        return ('A',)

    @_common_shared_state
    def given_edit(self, dll):
        dll.append_item('A')


class Case110_append_to_non_empty(_CommonCase):

    def test_100_edit(self):
        self.expect_edit()

    def test_200_backwards(self):
        self.expect_backwards()

    def expect_these_items(self):
        return ('A', 'B')

    @_common_shared_state
    def given_edit(self, dll):
        dll.append_item('A')
        dll.append_item('B')


class Case120_insert_at_head(_CommonCase):

    def test_100_edit(self):
        self.expect_edit()

    def test_200_backwards(self):
        self.expect_backwards()

    def expect_these_items(self):
        return ('B', 'A')

    @_common_shared_state
    def given_edit(self, dll):
        iid = dll.append_item('A')
        dll.insert_item_before_item('B', iid)


class Case130_insert_into_mid(_CommonCase):

    def test_100_edit(self):
        self.expect_edit()

    def test_200_backwards(self):
        self.expect_backwards()

    def expect_these_items(self):
        return ('A', 'C', 'B')

    @_common_shared_state
    def given_edit(self, dll):
        dll.append_item('A')
        iid = dll.append_item('B')
        dll.insert_item_before_item('C', iid)


class Case200_delete_at_head_to_make_non_empty(_CommonCase):

    def test_100_edit(self):
        self.expect_edit()

    def test_200_backwards(self):
        self.expect_backwards()

    def expect_these_items(self):
        return ('B',)

    @_common_shared_state
    def given_edit(self, dll):
        iid = dll.append_item('A')
        dll.append_item('B')
        dll.delete_item(iid)


class Case210_delete_from_mid_to_make_non_empty(_CommonCase):

    def test_100_edit(self):
        self.expect_edit()

    def test_200_backwards(self):
        self.expect_backwards()

    def expect_these_items(self):
        return ('A', 'C')

    @_common_shared_state
    def given_edit(self, dll):
        dll.append_item('A')
        iid = dll.append_item('B')
        dll.append_item('C')
        dll.delete_item(iid)


class Case230_delete_from_tail_to_make_non_empty(_CommonCase):

    def test_100_edit(self):
        self.expect_edit()

    def test_200_backwards(self):
        self.expect_backwards()

    def expect_these_items(self):
        return ('A',)

    @_common_shared_state
    def given_edit(self, dll):
        dll.append_item('A')
        iid = dll.append_item('B')
        dll.delete_item(iid)


class Case240_delete_to_make_empty_SIMPLE(_CommonCase):

    def test_100_edit(self):
        self.expect_edit()

    def test_200_backwards(self):
        self.expect_backwards()

    def expect_these_items(self):
        return ()

    @_common_shared_state
    def given_edit(self, dll):
        iid = dll.append_item('A')
        dll.delete_item(iid)


class Case320_integrate_delete_and_add(_CommonCase):
    """internally this covers that IID's from the "hole pool" are re-used"""

    def test_100_edit(self):
        self.expect_edit()

    def test_200_backwards(self):
        self.expect_backwards()

    def expect_these_items(self):
        return ('A', 'D', 'E')

    @_common_shared_state
    def given_edit(self, dll):
        dll.append_item('A')
        iid0 = dll.append_item('B')
        iid1 = dll.append_item('C')
        dll.append_item('D')
        dll.delete_item(iid1)
        dll.delete_item(iid0)
        dll.append_item('E')


class Case410_replace_when_one(_CommonCase):

    def test_100_edit(self):
        self.expect_edit()

    def test_200_backwards(self):
        self.expect_backwards()

    def expect_these_items(self):
        return ('B',)

    @_common_shared_state
    def given_edit(self, dll):
        iid = dll.append_item('A')
        dll.replace_item(iid, 'B')


class Case420_replace_at_head(_CommonCase):

    def test_100_edit(self):
        self.expect_edit()

    def test_200_backwards(self):
        self.expect_backwards()

    def expect_these_items(self):
        return ('C', 'B')

    @_common_shared_state
    def given_edit(self, dll):
        iid = dll.append_item('A')
        dll.append_item('B')
        dll.replace_item(iid, 'C')


class Case430_replace_at_tail(_CommonCase):

    def test_100_edit(self):
        self.expect_edit()

    def test_200_backwards(self):
        self.expect_backwards()

    def expect_these_items(self):
        return ('A', 'C')

    @_common_shared_state
    def given_edit(self, dll):
        dll.append_item('A')
        iid = dll.append_item('B')
        dll.replace_item(iid, 'C')


def _subject_module():
    from kiss_rdb.magnetics_ import doubly_linked_list_functions as _
    return _


if __name__ == '__main__':
    unittest.main()

# #born.
