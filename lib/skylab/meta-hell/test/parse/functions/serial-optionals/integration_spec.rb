require_relative 'test-support'

module Skylab::MetaHell::TestSupport::Parse::Series

  describe "[mh] parse series (integration spec)", wip: true do

    before :all do

      fields = Subject_[].fields

      P_ = Subject_[].series.curry_with(
        :syntax, :monikate, -> a { a * ' ' },
        :field, :monikate, -> s { "[ #{ s } ]" },
        :field, :moniker, '<integer>',
        :token_stream, fields.int.scan_token,
        :field, * fields::Flag[ :random ].to_a,
        :prepend_to_uncurried_queue, :exhaustion )

    end

    it "does nothing with nothing" do
      int, kw = parse
      @msg1.should be_nil
      @msg2.should be_nil
      int.should be_nil
      kw.should be_nil
    end

    it "against one strange string - borks gracefully" do
      integer, kw = parse 'frinkle'
      @msg1.should eql 'expecting arguments [ <integer> ] [ random ]'
      @msg2.should eql 'unrecognized argument at index 0 - "frinkle"'
      integer.should be_nil
      kw.should be_nil
    end

    it "good first token, strange second one" do
      a, b = prse '3', 'frinkle'
      a.should eql 3
      b.should be_nil
      @msg.should match %r(\bunrecognized.+at index 1 - "frinkle")i
    end

    it "two good tokens" do
      d, r = prse '3', 'random'
      d.should eql 3
      r.should eql true
      @msg.should be_nil
    end

    it "only one token - a production of the first formal symbol" do
      d, r = prse '3'
      d.should eql 3
      r.should be_nil
      @msg.should be_nil
    end

    it "only one token - *the* production of the second formal symbol" do
      d, r = prse 'random'
      d.should be_nil
      r.should eql true
      @msg.should be_nil
    end

    def parse *argv
      @msg1 = @msg2 = nil
      P_[ -> e do
        @msg1 = "expecting arguments #{ e.syntax_proc.call }"
        do_debug and y << @msg1
        @msg2 = e.message_proc.call
        do_debug and y << @msg2
      end, argv ]
    end

    def prse *argv
      @msg = nil
      P_[ -> e do
        @msg = e.message_proc.call
        do_debug and y << @msg
      end, argv ]
    end

    define_method :y, ( TS_::MetaHell_::Callback_.memoize do
      ::Enumerator::Yielder.new( &
        TestSupport_.debug_IO.method( :puts ) )
    end )
  end
end
