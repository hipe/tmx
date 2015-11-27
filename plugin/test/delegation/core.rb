module Skylab::Plugin::TestSupport

  module Delegation

    def self.use
      NIL_  # if this file is loaded, we are loaded
    end
  end

  module Delegation_Namespace

    extend TestSupport_::Quickie

    Subject_ = Home_::Delegation

  end
end
