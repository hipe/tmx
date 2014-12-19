require_relative 'test-support'

module Skylab::MetaHell::TestSupport::Parse::Series::Intgrtn

  ::Skylab::MetaHell::TestSupport::Parse::Series[ self ]

  include Constants

  extend TestSupport_::Quickie

  MetaHell_ = MetaHell_

  describe "[mh] Parse::Series (integration spec)" do

    before :all do
      fields = MetaHell_::Parse.fields
      P_ = MetaHell_::Parse::series.curry[
        :syntax, :monikate, -> a { a * ' ' },
        :field, :monikate, -> s { "[ #{ s } ]" },
        :field, :moniker, '<integer>',
        :token_stream, fields.int.scan_token,
        :field, * fields::Flag[ :random ].to_a,
        :prepend_to_uncurried_queue, :exhaustion
      ]
    end

    def debug! ; @do_debug = true end

    attr_reader :do_debug

    def y
      TS_.const_defined?( :Y_, false ) ?
        TS_.const_get( :Y_, false ) :
        TS_.const_set( :Y_, ::Enumerator::Yielder.
          new( & TestSupport_.debug_IO.method( :puts ) ) )
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

    it "does nothing with nothing" do
      int, kw = parse
      @msg1.should eql( nil ) ; @msg2.should eql( nil )
      int.should eql( nil ) ; kw.should eql( nil )
    end

    it "borks gracefully with one strange string" do
      integer, kw = parse 'frinkle'
      @msg1.should eql( 'expecting arguments [ <integer> ] [ random ]' )
      @msg2.should eql( 'unrecognized argument at index 0 - "frinkle"' )
      integer.should eql( nil )
      kw.should eql( nil )
    end

    it "when good first param, strange second one" do
      a, b = prse '3', 'frinkle'
      a.should eql( 3 )
      b.should eql( nil )
      @msg.should match( /unrecognized.+at index 1 - "frinkle"/i )
    end

    it "when params are all good" do
      d, r = prse '3', 'random'
      d.should eql( 3 )
      r.should eql( true )
      @msg.should eql( nil )
    end

    it "only one param, the first of two" do
      d, r = prse '3'
      d.should eql( 3 )
      r.should eql( nil )
      @msg.should eql( nil )
    end

    it "only one param, the second of two" do
      d, r = prse 'random'
      d.should eql( nil )
      r.should eql( true )
      @msg.should eql( nil )
    end
  end
end
