module Skylab::Treemap
  class Models::Node
    def clear!
    end
  end
  class << Models::Node
    def build_root
      new
    end
  end
end

