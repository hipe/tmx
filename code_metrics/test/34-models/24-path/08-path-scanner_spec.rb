require_relative '../../test-support'

module Skylab::CodeMetrics::TestSupport

  describe "[cm] models (public) - path - path scanner" do

    it "empty string - is not absolute" do
      _o = _against EMPTY_S_
      _o.is_absolute && fail
    end

    it "root path - is absolute, is already done parsing" do
      o = _against '/'
      o.is_absolute || fail
      o.no_unparsed_exists || fail
    end

    it "windows path - is not absolute (i.e we are not compatible with it)" do
      _o = _against "c:\\foo"
      _o.is_absolute && fail
    end

    it "one part (normal)" do
      _a = _array_against "/foo"
      _a == %w( foo ) || fail
    end

    it "two - not ended with sep" do
      o = _against '/foo/bar'
      _same_two o
      o.ended_with_separator && fail
    end

    it "same two - ended with sep" do
      o = _against '/foo/bar/'
      _same_two o
      o.ended_with_separator || fail
    end

    def _same_two o
      a = [ o.gets_one, o.gets_one ]
      a == %w( foo bar ) || fail
      o.no_unparsed_exists || fail
    end

    it "multiple separators OK (ending with)" do
      o = _against '/foo//'
      o.gets_one == 'foo' || fail
      o.no_unparsed_exists || fail
      o.ended_with_separator || fail
    end

    it "multiple separators OK (inside)" do
      o = _against '/foo///bar'
      o.gets_one == 'foo' || fail
      o.no_unparsed_exists && fail
      o.gets_one == 'bar' || fail
      o.no_unparsed_exists || fail
      o.ended_with_separator && fail
    end

    def _array_against s
      o = _against s
      a = []
      until o.no_unparsed_exists
        a.push o.gets_one
      end
      a
    end

    def _against s
      Subject___[].via s
    end

    Subject___ = Lazy_.call do
      Home_::Mondrian_[]::PathScanner
    end
  end
end
