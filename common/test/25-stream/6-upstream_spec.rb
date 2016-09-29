require_relative '../test-support'

module Skylab::Common::TestSupport

  describe "[co] stream - signals" do

    it "has it" do

      st = _build_subject
      st.gets.should eql 3
      st.gets.should eql 2
      st.upstream.should eql :x
    end

    it "endures by a map" do

      _st_ = _build_subject

      st = _st_.map_by do | d |
        "(#{ d })"
      end

      st.gets.should eql "(3)"
      st.upstream.should eql :x
    end

    def _build_subject
      d = 4
      _subject.new :x do
        if d > 1
          d -= 1
        end
      end
    end

    def _subject

      Home_::Stream
    end
  end
end
