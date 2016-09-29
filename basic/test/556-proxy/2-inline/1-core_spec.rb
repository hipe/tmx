require_relative '../../test-support'

module Skylab::Basic::TestSupport

  describe "[ba] proxy - inline" do

    TS_[ self ]

    it "produce a proxy \"inline\" from a hash-like whose values are procs" do

      pxy = Home_::Proxy::Inline.new(
        :foo, -> x { "bar: #{ x }" },
        :biz, -> { :baz },
      )

      pxy.foo( :wee ).should eql "bar: wee"

      pxy.biz.should eql :baz
    end

    it "2 equivalent ways to construct it" do

      p2 = _subject :bar, -> { :ba }
      p3 = _subject baz: -> { :bz }
      [ p2.bar, p3.baz ].should eql( [:ba, :bz] )
    end

    it "does the right thing, with respect to `self`" do

      pxy = _subject :bizzo, -> { :_one_ }
      pxy.bizzo.should eql :_one_
      @fipple = 'two'
      pxy = _subject :wankers, -> x { two x }
      pxy.wankers( 'three' ).should eql( 'two - three' )
      pxy = _subject :one, method( :two )
      pxy.one( 'five' ).should eql( 'two - five' )
    end

    def two x
      "#{ @fipple } - #{ x }"
    end

    def _subject * x_a, & x_p
      Home_::Proxy::Inline.new( * x_a, & x_p )
    end
  end
end
