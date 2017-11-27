require_relative '../test-support'

module Skylab::Basic::TestSupport

  describe "[ba] regexp - actors - stream of matches" do

    rx = /B/

    it "two matches" do

      st = subject "__BB__", rx

      md = st.gets
      expect( md.offset( 0 ).first ).to eql 2

      md = st.gets
      expect( md.offset( 0 ).first ).to eql 3

      expect( st.gets ).to be_nil
    end

    it "no matches" do

      expect( subject( 'a', rx ).gets ).to be_nil
    end

    def subject s, rx
      Home_::Regexp.stream_of_matches s, rx
    end
  end
end
