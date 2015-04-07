require_relative '../../test-support'

module Skylab::Basic::TestSupport

  describe "[ba] regexp - actors - stream of matches" do

    rx = /B/

    it "two matches" do

      st = subject "__BB__", rx

      md = st.gets
      md.offset( 0 ).first.should eql 2

      md = st.gets
      md.offset( 0 ).first.should eql 3

      st.gets.should be_nil
    end

    it "no matches" do

      subject( 'a', rx ).gets.should be_nil
    end

    def subject s, rx
      Basic_::Regexp.stream_of_matches s, rx
    end
  end
end
