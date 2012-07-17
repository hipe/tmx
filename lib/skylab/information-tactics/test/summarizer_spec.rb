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
    o(2,  '', '')
    o(-1, 'a', 'a')
    o(0,  'a',  '')
    o(1,  'a', 'a')
    o(2,  'a', 'a')
    o(-1, 'ab', 'ab')
    o(0,  'ab', '')
    o(1,  'ab', '.')
    o(2,  'ab', 'ab')
    o(1,  'abc', '.')
    o(2,  'abc', '..')
    o(3,  'abc', 'abc')
  end
end
