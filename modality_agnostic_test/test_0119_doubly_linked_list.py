from modality_agnostic.test_support.common import \
        dangerous_memoize_in_child_classes as shared_subject_in_child_classes
import unittest


class CommonCase(unittest.TestCase):

    def expect_edit(self):
        dll = self.end_state()
        _actual = tuple(dll.to_item_stream())
        _expected = self.expect_these_items()
        self.assertEqual(_actual, _expected)

    def expect_backwards(self):

        _ = self.expect_these_items()
        _expected = list(reversed(_))

        a = []
        dll = self.end_state()
        item_via = dll.item_via_IID
        prev_via = dll.prev_IID_via_IID
        iid = dll.tail_IID
        while iid is not None:
            a.append(item_via(iid))
            iid = prev_via(iid)

        self.assertEqual(a, _expected)

    @shared_subject_in_child_classes
    def end_state(self):
        build_empty_DLL = subject_function()
        dll = build_empty_DLL()
        self.given_edit(dll)
        return dll


class Case0119_038_empty(CommonCase):

    def test_100_edit(self):
        self.expect_edit()

    def test_200_backwards(self):
        self.expect_backwards()

    def expect_these_items(self):
        return ()

    def given_edit(self, dll):
        pass


class Case0119_116_append_to_empty(CommonCase):

    def test_100_edit(self):
        self.expect_edit()

    def test_200_backwards(self):
        self.expect_backwards()

    def expect_these_items(self):
        return ('A',)

    def given_edit(self, dll):
        dll.append_item('A')


class Case0119_192_append_to_non_empty(CommonCase):

    def test_100_edit(self):
        self.expect_edit()

    def test_200_backwards(self):
        self.expect_backwards()

    def expect_these_items(self):
        return ('A', 'B')

    def given_edit(self, dll):
        dll.append_item('A')
        dll.append_item('B')


class Case0119_269_insert_at_head(CommonCase):

    def test_100_edit(self):
        self.expect_edit()

    def test_200_backwards(self):
        self.expect_backwards()

    def expect_these_items(self):
        return ('B', 'A')

    def given_edit(self, dll):
        iid = dll.append_item('A')
        dll.insert_item_before_item('B', iid)


class Case0119_346_insert_into_mid(CommonCase):

    def test_100_edit(self):
        self.expect_edit()

    def test_200_backwards(self):
        self.expect_backwards()

    def expect_these_items(self):
        return ('A', 'C', 'B')

    def given_edit(self, dll):
        dll.append_item('A')
        iid = dll.append_item('B')
        dll.insert_item_before_item('C', iid)


class Case0119_423_delete_at_head_to_make_non_empty(CommonCase):

    def test_100_edit(self):
        self.expect_edit()

    def test_200_backwards(self):
        self.expect_backwards()

    def expect_these_items(self):
        return ('B',)

    def given_edit(self, dll):
        iid = dll.append_item('A')
        dll.append_item('B')
        dll.delete_item(iid)


class Case0119_500_delete_from_mid_to_make_non_empty(CommonCase):

    def test_100_edit(self):
        self.expect_edit()

    def test_200_backwards(self):
        self.expect_backwards()

    def expect_these_items(self):
        return ('A', 'C')

    def given_edit(self, dll):
        dll.append_item('A')
        iid = dll.append_item('B')
        dll.append_item('C')
        dll.delete_item(iid)


class Case0119_577_delete_from_tail_to_make_non_empty(CommonCase):

    def test_100_edit(self):
        self.expect_edit()

    def test_200_backwards(self):
        self.expect_backwards()

    def expect_these_items(self):
        return ('A',)

    def given_edit(self, dll):
        dll.append_item('A')
        iid = dll.append_item('B')
        dll.delete_item(iid)


class Case0119_654_delete_to_make_empty_SIMPLE(CommonCase):

    def test_100_edit(self):
        self.expect_edit()

    def test_200_backwards(self):
        self.expect_backwards()

    def expect_these_items(self):
        return ()

    def given_edit(self, dll):
        iid = dll.append_item('A')
        dll.delete_item(iid)


class Case0119_731_integrate_delete_and_add(CommonCase):
    """internally this covers that IID's from the "hole pool" are re-used"""

    def test_100_edit(self):
        self.expect_edit()

    def test_200_backwards(self):
        self.expect_backwards()

    def expect_these_items(self):
        return ('A', 'D', 'E')

    def given_edit(self, dll):
        dll.append_item('A')
        iid0 = dll.append_item('B')
        iid1 = dll.append_item('C')
        dll.append_item('D')
        dll.delete_item(iid1)
        dll.delete_item(iid0)
        dll.append_item('E')


class Case0119_808_replace_when_one(CommonCase):

    def test_100_edit(self):
        self.expect_edit()

    def test_200_backwards(self):
        self.expect_backwards()

    def expect_these_items(self):
        return ('B',)

    def given_edit(self, dll):
        iid = dll.append_item('A')
        dll.replace_item(iid, 'B')


class Case0119_885_replace_at_head(CommonCase):

    def test_100_edit(self):
        self.expect_edit()

    def test_200_backwards(self):
        self.expect_backwards()

    def expect_these_items(self):
        return ('C', 'B')

    def given_edit(self, dll):
        iid = dll.append_item('A')
        dll.append_item('B')
        dll.replace_item(iid, 'C')


class Case0119_962_replace_at_tail(CommonCase):

    def test_100_edit(self):
        self.expect_edit()

    def test_200_backwards(self):
        self.expect_backwards()

    def expect_these_items(self):
        return ('A', 'C')

    def given_edit(self, dll):
        dll.append_item('A')
        iid = dll.append_item('B')
        dll.replace_item(iid, 'C')


def subject_function():
    from modality_agnostic.magnetics.doubly_linked_list_via_nothing import func
    return func


if __name__ == '__main__':
    unittest.main()

# #history-B.4 got rid of custom memoizing decorator
#   (above was an [#510.6]. ok to remove this line)
# #born.
