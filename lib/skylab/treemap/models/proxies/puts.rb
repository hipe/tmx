module Skylab::Treemap
  class Models::Proxies::Puts < ::Struct.new :func
    def puts str
      func[ str ]
    end
  end
end
