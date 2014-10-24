require_relative 'test-support'

module Skylab::Callback::TestSupport::Proxy

  describe "[cb] proxy - inline" do

    it "2 equivalent ways to construct it" do
      p2 = Subject_[].inline :bar, -> { :ba }
      p3 = Subject_[].inline baz: -> { :bz }
      [ p2.bar, p3.baz ].should eql( [:ba, :bz] )
    end

    it "does the right thing, with respect to `self`" do
      pxy = Subject_[].inline :bizzo, -> { one }
      pxy.bizzo.should eql( 'One' )
      @fipple = 'two'
      pxy = Subject_[].inline :wankers, -> x { two x }
      pxy.wankers( 'three' ).should eql( 'two - three' )
      pxy = Subject_[].inline :one, method( :two )
      pxy.one( 'five' ).should eql( 'two - five' )
    end

    def one
      'One'
    end

    def two x
      "#{ @fipple } - #{ x }"
    end
  end
end
