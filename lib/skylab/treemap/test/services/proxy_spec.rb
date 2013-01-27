# side-stepping parent for now

require_relative '../../core'
require 'skylab/test-support/core'

module Skylab::Treemap::TestSupport

  @dir_path = ::Pathname.new( '../..' ).expand_path( __FILE__ ).to_s # while side-stepping

  ::Skylab::TestSupport::Regret[ self ]

  module CONSTANTS
    TestSupport = ::Skylab::TestSupport
    Treemap = ::Skylab::Treemap
  end
end

module Skylab::Treemap::TestSupport::MetaHell
  ::Skylab::Treemap::TestSupport[ MetaHell_TestSupport = self ]

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

      pxy_cls = Treemap::MetaHell::Proxy.new bang: -> x do
        "outer-bang:(#{ x })"
      end

      pxy = pxy_cls.new

      pxy.upstream = obj

      pxy.bing( 'whohah' ).should eql( 'hello yes this is bing: whohah' )

      pxy.bang( 'huzzah' ).should eql( 'outer-bang:(inner-bang:(huzzah))' )

    end
  end
end
