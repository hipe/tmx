require_relative 'test-support'

module Skylab::Human::TestSupport

  describe "[hu] summarizer" do

    include Home_::Summarization  # strange but historic

    context "truncates strings" do
      def self.o maxlen, input, expected, *r
        it("summarize(#{maxlen}, #{input.inspect}) #=> #{expected.inspect}", *r) do
          expect( summarize(maxlen, input) ).to eql(expected)
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
        it("summarize(#{maxlen}, #{struct.inspect}) #=> #{expected.inspect}", *r) do
          expect( summarize(maxlen, struct) ).to eql(expected)
        end
      end
      def self.struct! struct
        singleton_class.send(:define_method, :struct) { struct }
      end
      context "let's snap these fuckers -- for now we don't ellipsify discrete strings" do
        struct! ['abc', 'def']
        o(6, 'abcdef')
        o(5, '')
      end
      context "here is a crap with a dapp and a sapp" do
        struct! ['#', ['<', '>']]
        o(3, '#<>')
        o(2, '#')
        o(1, '#')
        o(0, '')
        o(-1, '#<>')
      end
      context "but then furk with this berk" do
        struct! ['#', ['<', ['furk'], '>']]
        o(7, '#<furk>')
        o(6, '#<>')
      end
      context "more than one doohah" do
        struct! [['a'], 'b', ['c']]
        o(2, 'b')
        o(3, 'abc')
        o(1, 'b')
      end
      context "even if the doohah would fit, it's atomic per level" do
        struct! [['a'], 'b', ['cd']]
        o(1, 'b')
        o(2, 'b')
        o(3, 'b')
        o(4, 'abcd')
      end
      # context "nerkle with my derkle to herkle your berkle" do
      # end
    end
  end
end
