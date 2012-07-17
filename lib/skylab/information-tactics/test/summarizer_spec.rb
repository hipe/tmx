require_relative '../summarizer'
require_relative 'test-support'

module Skylab::InformationTactics::TestSupport
  describe "Summarizer" do
    include ::Skylab::InformationTactics::Summarizer
    def self.o maxlen, input, expected
      it "summarize(#{maxlen}, #{input.inspect}) #=> #{expected.inspect}" do
        summarize(maxlen, input).should eql(expected)
      end
    end
    o(-1, '', '')
    o(0,  '', '')
    o(1,  '', '')
  end
end
