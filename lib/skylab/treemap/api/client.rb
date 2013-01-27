module Skylab::Treemap
  class API::Client # (was [#032])
    include ::Singleton # [#033] - - go it away, singleton

    def action *names # [#034] - look at what this is - definately boxxy tiem
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
end
