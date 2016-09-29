require_relative '../../test-support'

module Skylab::Basic::TestSupport

  describe "[ba] string - word wrappers - crazy" do

    TS_[ self ]
    use :string

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
      subject_module_.word_wrappers.crazy
    end
  end
end
