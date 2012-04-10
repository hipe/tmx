module Skylab::TanMan
  class Models::Model
    extend Bleeding::DelegatesTo
    extend Porcelain::AttributeDefiner

    delegates_to :runtime, :emit

    def initialize runtime
      @runtime = runtime
    end
  end
end

