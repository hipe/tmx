require_relative '../test-support'

module Skylab::Treemap::TestSupport::Services
  ::Skylab::Treemap::TestSupport[ Services_TestSupport = self ]

  include CONSTANTS

  extend TestSupport::Quickie

  describe "#{ Treemap }::MetaHell::Proxy" do

    it 'proxies nerks to a reciever, possibly wrapping them' do

      obj = ::Object.new

      obj.define_singleton_method :bing do |x|
        "hello yes this is bing: #{ x }"
      end

      obj.define_singleton_method :bang do |x|
        "inner-bang:(#{ x })"
      end

      pxy_cls = Treemap::Services::Proxy.new bang: -> x do
        "outer-bang:(#{ x })"
      end

      pxy = pxy_cls.new

      pxy.upstream = obj

      pxy.bing( 'whohah' ).should eql( 'hello yes this is bing: whohah' )

      pxy.bang( 'huzzah' ).should eql( 'outer-bang:(inner-bang:(huzzah))' )

    end
  end
end
