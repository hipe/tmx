require_relative '../test-support'

module Skylab::Basic::TestSupport

  describe "[ba] string - line stream via string" do

    TS_[ self ]
    use :string

    it "loads" do
      _subject_module
    end

    it "when built with a string, works the same" do  # mirror 2 others
      scn = of "one C\ntwo C\n"
      expect( scn.lineno ).to be_zero  # be like ::File
      expect( scn.gets ).to eql "one C\n"
      expect( scn.lineno ).to eql 1
      expect( scn.gets ).to eql "two C\n"
      expect( scn.lineno ).to eql 2
      expect( scn.gets ).to be_nil
      expect( scn.lineno ).to eql 2
      expect( scn.gets ).to be_nil
    end

    it "empty string" do
      scn = of ''
      expect( scn.lineno ).to be_zero
      expect( scn.gets ).to be_nil
      expect( scn.lineno ).to be_zero
      expect( scn.gets ).to be_nil
    end

    it "noneempty string no terminating newline" do
      scn = of 'abc'
      expect( scn.lineno ).to be_zero
      expect( scn.gets ).to eql 'abc'
      expect( scn.lineno ).to eql 1
      expect( scn.gets ).to be_nil
      expect( scn.lineno ).to eql 1
    end

    it "nonempty string terminating newline" do
      scn = of "foo\n"
      expect( scn.lineno ).to be_zero
      expect( scn.gets ).to eql "foo\n"
      expect( scn.lineno ).to eql 1
      expect( scn.gets ).to be_nil
      expect( scn.lineno ).to eql 1
    end

    it "two no term" do
      scn = of "foo\nbar"
      expect( scn.lineno ).to be_zero
      expect( scn.gets ).to eql "foo\n"
      expect( scn.lineno ).to eql 1
      expect( scn.gets ).to eql "bar"
      expect( scn.lineno ).to eql 2
      expect( scn.gets ).to be_nil
      expect( scn.lineno ).to eql 2
      expect( scn.gets ).to be_nil
      expect( scn.lineno ).to eql 2
    end

    it "two term" do
      scn = of "foo\nbar\n"
      expect( scn.gets ).to eql "foo\n"
      expect( scn.gets ).to eql "bar\n"
      expect( scn.gets ).to be_nil
    end

    it "three with interceding blank line" do
      scn = of "foo\n\nbar\n"
      expect( scn.gets ).to eql "foo\n"
      expect( scn.gets ).to eql "\n"
      expect( scn.lineno ).to eql 2
      expect( scn.gets ).to eql "bar\n"
      expect( scn.lineno ).to eql 3
    end

    it "reverse" do
      str = "haha\n"
      y = _subject_module::Reverse[ str ]
      y << 'this'
      y << 'is what'
      expect( str ).to eql "haha\nthis\nis what"
    end

    def of s
      _subject_module[ s ]
    end

    def _subject_module
      Home_::String::LineStream_via_String
    end
  end
end
