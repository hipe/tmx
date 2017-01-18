require_relative '../test-support'

module Skylab::Common::TestSupport

  describe "[co] stream - instance method" do

    it "`join_into_with_by`" do

      _st = _stream_via 'A', 'B', 'C'
      _act = _st.join_into_with_by( "", '; ', & :downcase )
      _act == "a; b; c" || fail
    end

    def _stream_via * these
      stack = these.reverse
      _subject_module.by do
        stack.pop
      end
    end

    def _subject_module
      Home_::Stream
    end
  end
end
# #born years and years later
