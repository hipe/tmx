require_relative 'test-support'

module Skylab::MetaHell::TestSupport::Proxy::Ad_Hoc

  ::Skylab::MetaHell::TestSupport::Proxy[ self ]

  include CONSTANTS

  extend TestSupport_::Quickie

  describe "[mh] Proxy::Ad_Hoc" do

    it "2 equivalent ways to construct it" do
      p2 = MetaHell_::Proxy::Ad_Hoc[ bar: -> { :ba } ]
      p3 = MetaHell_::Proxy::Ad_Hoc.new baz: -> { :bz }
      [ p2.bar, p3.baz ].should eql( [:ba, :bz] )
    end

    def one ; 'One' end

    def two x ; "#{ @fipple } - #{ x }" end

    it "does the right thing, with respect to `self`" do
      pxy = MetaHell_::Proxy::Ad_Hoc[ bizzo: -> { one } ]
      pxy.bizzo.should eql( 'One' )
      @fipple = 'two'
      pxy = MetaHell_::Proxy::Ad_Hoc[ wankers: -> x { two x } ]
      pxy.wankers( 'three' ).should eql( 'two - three' )
      pxy = MetaHell_::Proxy::Ad_Hoc[ one: method(:two) ]
      pxy.one( 'five' ).should eql( 'two - five' )
    end
  end
end
