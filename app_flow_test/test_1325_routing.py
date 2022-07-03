from modality_agnostic.test_support.common import \
        dangerous_memoize_in_child_classes as shared_subject_in_children
from unittest import TestCase as unittest_TestCase, main as unittest_main


class CommonCase(unittest_TestCase):

    def go(self):
        self.end_state = self.url_matcher.match(
            self.given_url, self.given_http_method, self.given_GET_params)

    def expect_failure(self, msg):
        err = self.end_state
        self.assertEqual(msg, err.message)

    def expect_success(self, rav):
        actual_value = self.end_state.route_associated_value
        self.assertEqual(rav, actual_value)

    @property
    @shared_subject_in_children
    def url_matcher(self):
        """NOTE XXX this is intentionaly wild: strap in. subject is lazy
        """

        these = ((s, ('xx_RAV_xx', s)) for s in self.given_routes)
        return subject_module().matcher_via_routes(these)

    given_http_method = 'GET'
    given_GET_params = None


class RouteCase(unittest_TestCase):

    def go(self):
        self.end_state_tuple = tuple(self.do_go())

    def do_go(self):
        scn = subject_module()._route_string_scanner(self.given_route_string, 9)
        while not scn.empty:
            yield scn.next()


class Case1303_against_the_index_case(RouteCase):

    def test_010_go(self):
        self.go()
        assert 0 == len(self.end_state_tuple)

    given_route_string = '/'


class Case1305_against_a_one_entry_url(RouteCase):

    def test_010_go(self):
        self.go()
        assert 1 == len(self.end_state_tuple)
        assert 'faz-BAZ-123' == self.end_state_tuple[0]

    given_route_string = '/faz-BAZ-123/'


class Case1307_many(RouteCase):

    def test_010_go(self):
        self.go()
        assert 3 == len(self.end_state_tuple)
        self.assertSequenceEqual(tuple('AA BB CC'.split()), self.end_state_tuple)

    given_route_string = '/AA/BB/CC/'


class Case1309_must_have_ting(RouteCase):

    def test_010_go(self):
        exc_class = subject_module().DefinitionError
        try:
            self.go()
        except exc_class as exce:
            e = exce

        self.assertEqual("need non-slashes followed by slash: 'CC'", str(e))

    given_route_string = '/AA/BB/CC'


class Case1327_intro(CommonCase):

    def test_010_build_url_matcher(self):
       assert self.url_matcher

    def test_020_against_strange_first_token(self):
        self.given_url = '/zaboo/'
        self.go()
        self.expect_failure("404 - not found: '/zaboo/'")

    def test_030_against_strange_second_token(self):
        self.given_url = '/torso/mambo/'
        self.go()
        self.expect_failure("404 - not found: '/torso/mambo/'")

    def test_040_end_not_on_endpoint(self):
        self.given_url = '/torso/'
        self.go()
        self.expect_failure("404 - not an endpoint: '/torso/'")

    def test_050_lets_go_mambo(self):
        self.given_url = '/torso/heart/'
        self.go()
        self.expect_success(('xx_RAV_xx', '/torso/heart/'))

    @property
    def given_routes(self):
        yield '/lower/pelvis/'
        yield '/torso/heart/'
        yield '/torso/shoulders/'


def subject_module():
    # XXX not sure if will come in thru CLI
    import app_flow.routing as mod
    return mod


if __name__ == '__main__':
    unittest_main()

# #born
