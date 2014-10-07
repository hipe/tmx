require_relative 'test-support'

module Skylab::MetaHell::TestSupport

  describe "[mh] \"strange\" (the summarization-aware `inspect`-ish)" do

    it "a string 9 chars wide gets quoted and becomes 11 wide" do
      expect_quotes 'nine_char'
    end

    it "a string 10 chars wide gets quoted and becomes 12 chars wide" do
      expect_quotes 'ten_chars_'
    end

    it "the quoting happens via 'inspect' so things get escaped too" do
      subject( "\"\n" ).should eql '"\"\n"'
    end

    it "a string 11 chars wide becomes 10 chars wide and is ellipsified" do
      subject( 'eleven_chrs' ).should eql '"eleven[..]"'
    end

    def expect_quotes s
      subject( s ).should eql "\"#{ s }\""
    end

    def subject s
      MetaHell_.strange s
    end
  end
end
