module Skylab::Treemap

  module Adapter::API
  end

  module Adapter::API::Action
  end

  module Adapter::API::Action::InstanceMethods

    # remember you are probably "in" a probably produced adapter API
    # action class that descends from ..
    #

    def initialize mc
      fail "wat: #{ mc.class }"  # #todo
    end
  end
end
