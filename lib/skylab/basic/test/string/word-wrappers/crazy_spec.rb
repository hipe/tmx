require_relative '../test-support'

module Skylab::Basic::TestSupport::String

  describe "[ba] string - word wrappers - crazy" do

    it "loads" do

      _subject
    end

    it "two words - we can't figure out how it works (crazy)" do

      ww = _subject.curry 'X', 5, y=[]
      ww << 'foo bar'
      ww.flush

      y.should eql [ 'Xfoo bar' ]  # #t-odo meh
    end

    def _subject
      Basic_::String.word_wrappers.crazy
    end
  end
end
