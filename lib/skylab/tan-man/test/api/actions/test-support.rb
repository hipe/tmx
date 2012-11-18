require_relative '../test-support'

module Skylab::TanMan::TestSupport::API::Actions
  ::Skylab::TanMan::TestSupport::API[ Actions_TestSupport = self ] # #regret

  include CONSTANTS # for the spec itself

  module InstanceMethods
    def api_invoke *a
      api.invoke(* a)
    end
  end
end
