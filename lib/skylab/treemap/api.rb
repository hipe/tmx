require_relative '../../skylab'
require 'skylab/meta-hell/autoloader/autovivifying'
require 'skylab/pub-sub/emitter'
require 'skylab/porcelain/bleeding'
require 'singleton'

module Skylab::Treemap
  extend Skylab::Autoloader
  DelegatesTo = Skylab::Porcelain::Bleeding::DelegatesTo

  module API
    extend Skylab::MetaHell::Autoloader::Autovivifying
  end

  class API::Client
    include Singleton

    def action *names
      klass = names.reduce(API::Actions) do |m, n|
        m.const_get n.to_s.gsub(/(?:^|_)([a-z])/){ $1.upcase }
      end
      o = klass.new
      o.api_client = self
      o
    end
    def adapters
      @adapters ||= Skylab::Treemap::Adapter::Collection(
        Skylab::Treemap::Plugins::TreemapRenderAdapters,
        Skylab::Treemap.dir.join('plugins/treemap-render-adapters'),
        'client.rb'
      )
    end
  end

  class API::Event < Skylab::PubSub::Event
    def initialize tag, *payload
      if payload.size == 2 and Hash === payload.last
        h = payload.pop
        h[:message] = payload.first
        super(tag, h)
      else
        super(tag, *payload)
      end
    end
  end
end

