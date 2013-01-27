module Skylab::Treemap
  class Proxies::Puts < ::Struct.new :func
    def puts str
      func[ str ]
    end
  end
end
