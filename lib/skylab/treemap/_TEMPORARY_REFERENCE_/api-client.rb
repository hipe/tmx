require 'singleton' # [#048] - - singleton goes away

module Skylab::Treemap

  class API::Client # (was [#032])

    include ::Singleton # [#033] - - go it away, singleton

    def adapter_box                  # BUCK api actions will use these
      @adapter_box ||= Treemap::Adapter::Box.new Treemap::Plugins, 'client.rb'
    end

  private

    def initialize
      @adapter_box = nil
    end
  end
end