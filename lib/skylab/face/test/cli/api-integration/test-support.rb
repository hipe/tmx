require_relative '../test-support'

module Skylab::Face::TestSupport::CLI::API_Integration

  ::Skylab::Face::TestSupport::CLI[ API_Integration_TestSupport = self ]

  module InstanceMethods

    def client_class  # wide riggings here. compat with above.
      application_module.const_get( :CLI, false ).const_get( :Client, false )
    end
  end
end
