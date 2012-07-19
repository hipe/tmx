require_relative '../summarizer'
require_relative 'test-support'

module Skylab::InformationTactics::TestSupport
  describe "Summarizer#summarize()" do
    include ::Skylab::InformationTactics::Summarizer
    context "truncates strings" do
      def self.o maxlen, input, expected, *r
        it("summarize(#{maxlen}, #{input.inspect}) #=> #{expected.inspect}", *r) do
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
    context "with some structures" do
      def self.o maxlen, expected, *r
        struct = self.struct
        it("#{maxlen}, #{struct.inspect} #=> #{expected.inspect}", *r) do
          summarize(maxlen, struct).should eql(expected)
        end
      end
      context "let's snap these fuckers -- for now we don't ellipsify discrete strings" do
        struct = ['abc', 'def']
        singleton_class.send(:define_method, :struct) { struct }
        o(6, 'abcdef')
        o(5, '')
      end
      context "here is a crap with a dapp and a sapp" do
        struct = ['#', ['<', '>']]
        singleton_class.send(:define_method, :struct) { struct }
        o(3, '#<>')
        o(2, '#')
        o(1, '#')
        o(0, '')
        o(-1, '#<>')
      end
      context "but then furk with this berk" do
        struct = ['#', ['<', ['furk'], '>']]
        singleton_class.send(:define_method, :struct) { struct }
        o(7, '#<furk>')
        o(6, '#<>')
      end
    end
  end
end
