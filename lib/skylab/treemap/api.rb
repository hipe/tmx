require_relative '../../skylab'
require 'skylab/meta-hell/autoloader/autovivifying'
require 'skylab/pub-sub/emitter'
require 'skylab/porcelain/bleeding'
require 'singleton'

module Skylab::Treemap
  Treemap = self
  extend Skylab::Autoloader

  module API
    extend Skylab::MetaHell::Autoloader::Autovivifying
    PLUGINS_DIR = dir_pathname.dirname.join('plugins')
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
      @adapters ||= Skylab::Treemap::Adapter::Collection(Skylab::Treemap::Plugins, API::PLUGINS_DIR, 'client.rb')
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

