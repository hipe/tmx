module Skylab::GitViz
  class CLI::Action
    def api
      API.instance[@runtime]
    end
    def initialize rt
      @runtime = rt
    end
    def emit(*a)
      @runtime.emit(*a)
    end
  end
end

