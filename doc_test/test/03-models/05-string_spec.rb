require_relative '../test-support'

module Skylab::DocTest::TestSupport

  describe "[dt] models - string" do

    TS_[ self ]

    foo = 'foo'

    it "normative" do
      _soft( ' "foo"  ' ) == foo || fail
    end

    it "no overreach" do
      _soft( ' "foo" "bar" ') == foo || fail
    end

    it "single quote" do
      _soft( " 'foo' " ) == foo || fail
    end

    it "in a single quote have a single quote" do

      # this is #coverpoint4-3: the remarkable case of needing four
      # backslashes in our regex.

      _soft( " 'mom\\'s spaghetti' " ) == "mom's spaghetti" || fail
    end

    it "in a single quote have a backslash" do
      _soft( " 'backslash: \"\\\\\"' " ) == 'backslash: "\"' || fail
    end

    it "in a double quote have a double quote" do
      _soft( ' "what \\"fun\\"." yep' ) == 'what "fun".' || fail
    end

    it "in a double quote have a backslash" do
      _soft( ' "bs: \\\\." k' ) == 'bs: \\.' || fail
    end

    def _soft s

      # (we use this form and not the other because this one is more
      #  lenient and so we want to be sure it doesn't "overreach"
      #  whereas because the other one is "anchored" to the end of the
      #  string it's hypothetically easier to match by that "not soft" one.)

      Home_::Models_::String.unescape_quoted_literal_anchored_at_head s
    end
  end
end
