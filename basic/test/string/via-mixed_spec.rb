require_relative '../test-support'

module Skylab::Basic::TestSupport

  describe "[ba] string - `via_mixed`" do

    extend TS_
    use :string

    it "a string 9 chars wide gets quoted and becomes 11 wide" do
      expect_quotes 'nine_char'
    end

    it "a string 10 chars wide gets quoted and becomes 12 chars wide" do
      expect_quotes 'ten_chars_'
    end

    it "the quoting happens via 'inspect' so things get escaped too" do
      subject( "\"\n" ).should eql '"\"\n"'
    end

    it "a string 16 chars wide becomes 15 chars wide and is ellipsified" do
      subject( 'sixteen_chars_wd' ).should eql '"sixteen_cha[..]"'
    end

    it "a typical symbol gets single quotes" do
      subject( :"foo_Bar baz 123" ).should eql "'foo_Bar baz 123'"
    end

    it "a crazy symbol gets escaped" do
      subject( :"\thi" ).should eql "'\\thi'"
    end

    def expect_quotes s
      subject( s ).should eql "\"#{ s }\""
    end

    def subject s
      subject_module_.via_mixed s
    end
  end
end
