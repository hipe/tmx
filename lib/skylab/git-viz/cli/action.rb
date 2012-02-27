require File.expand_path('../../api', __FILE__)

module Skylab::GitViz
  class Cli::Action
    def api
      Api.instance[@runtime]
    end
    def initialize rt
      @runtime = rt
    end
    def emit(*a)
      @runtime.emit(*a)
    end
  end
end

