module Skylab::TanMan
  class Models::Model
    extend Bleeding::DelegatesTo
    extend Porcelain::AttributeDefiner
    include MyActionInstanceMethods

    delegates_to :runtime, :emit

    def initialize runtime
      my_action_init
      @runtime = runtime
    end
  end
end

