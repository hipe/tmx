module Skylab::GitViz
  class Api::Action < Struct.new(:api, :params)
    def emit(*a)
      api.runtime.emit(*a)
    end
    def initialize api, params
      super(api, params)
    end
  end
end

