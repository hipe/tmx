require_relative '../../test-support'

module Skylab::Basic::TestSupport

  describe "[ba] proxy - inline" do

    TS_[ self ]

    it "produce a proxy \"inline\" from a hash-like whose values are procs" do

      pxy = Home_::Proxy::Inline.new(
        :foo, -> x { "bar: #{ x }" },
        :biz, -> { :baz },
      )

      expect( pxy.foo( :wee ) ).to eql "bar: wee"

      expect( pxy.biz ).to eql :baz
    end

    it "2 equivalent ways to construct it" do

      p2 = _subject :bar, -> { :ba }
      p3 = _subject baz: -> { :bz }
      expect( [ p2.bar, p3.baz ] ).to eql( [:ba, :bz] )
    end

    it "does the right thing, with respect to `self`" do

      pxy = _subject :bizzo, -> { :_one_ }
      expect( pxy.bizzo ).to eql :_one_
      @fipple = 'two'
      pxy = _subject :wankers, -> x { two x }
      expect( pxy.wankers( 'three' ) ).to eql( 'two - three' )
      pxy = _subject :one, method( :two )
      expect( pxy.one( 'five' ) ).to eql( 'two - five' )
    end

    def two x
      "#{ @fipple } - #{ x }"
    end

    def _subject * x_a, & x_p
      Home_::Proxy::Inline.new( * x_a, & x_p )
    end
  end
end
