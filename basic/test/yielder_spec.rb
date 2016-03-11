require_relative 'test-support'

module Skylab::Basic::TestSupport

  describe "[ba] yielder - line flusher" do

    it "x." do

      a = []
      y = _subject[ a ]

      y << "one"
      y << "two\nthr"

      a.should eql [ "onetwo\n" ]

      y << "ee"

      _hi = y.flush
    end

    def _subject
      Home_::Yielder::LineFlusher
    end
  end
end
