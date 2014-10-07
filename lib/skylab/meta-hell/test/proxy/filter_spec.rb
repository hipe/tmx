require_relative 'test-support'

module Skylab::MetaHell::TestSupport::Proxy::Filter

  ::Skylab::MetaHell::TestSupport::Proxy[ self ]

  include CONSTANTS

  extend TestSupport_::Quickie

  describe "[mh] Proxy::Filter::Post" do

    it 'proxies nerks to a reciever, possibly wrapping them' do

      obj = ::Object.new

      obj.define_singleton_method :bing do |x|
        "hello yes this is bing: #{ x }"
      end

      obj.define_singleton_method :bang do |x|
        "inner-bang:(#{ x })"
      end

      pxy_cls = MetaHell_::Proxy::Filter::Post.new bang: -> x do
        "outer-bang:(#{ x })"
      end

      pxy = pxy_cls.new

      pxy.upstream = obj

      pxy.bing( 'whohah' ).should eql( 'hello yes this is bing: whohah' )

      pxy.bang( 'huzzah' ).should eql( 'outer-bang:(inner-bang:(huzzah))' )

    end
  end
end
