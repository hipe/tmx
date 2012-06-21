require_relative '../../skylab'
require 'skylab/pub-sub/emitter'
require 'skylab/porcelain/bleeding'

module Skylab::Treemap
  extend Skylab::Autoloader
  DelegatesTo = Skylab::Porcelain::Bleeding::DelegatesTo

  module API
    extend Skylab::Autoloader
  end

  class API::Client
    def action *names
      klass = names.reduce(API::Actions) do |m, n|
        m.const_get n.to_s.gsub(/(?:^|_)([a-z])/){ $1.upcase }
      end
      klass.new
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

