module Skylab::Treemap
  module API
  end

  class API::Client # #todo move this - it's the bulk of the file
    include ::Singleton # let this be the only use of singletons - they are evil
                        # gives you `instance`, accesses the singleton obj to
                        # todo - go it away, singleton

    def action *names # #todo look at what this is
      klass = names.reduce API::Actions do |m, n|
        m.const_get n.to_s.gsub(/(?:^|_)([a-z])/){ $1.upcase }
      end
      klass.new self
    end

    def adapter_box                  # api actions will use these
      @adapter_box ||= Treemap::Adapter::Box.new nil, Treemap::Plugins, 'client.rb'
    end

  protected

    def initialize
      @adapter_box = nil
    end
  end

  class API::Event < PubSub::Event

  protected

    def initialize tag, *payload
      if payload.size == 2 and ::Hash === payload.last
        h = payload.pop
        h[:message] = payload.first
        super tag, h
      else
        super tag, *payload
      end
    end
  end
end
