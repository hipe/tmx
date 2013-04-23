require_relative '../core'

require 'skylab/test-support/core'

module Skylab::Basic::TestSupport

  module CONSTANTS
    %i| Basic TestSupport |.each do |i|
      const_set i, ::Skylab.const_get( i, false )
    end
  end

  include CONSTANTS

  TestSupport::Regret[ self ]

  module ModuleMethods

    def sandbox i, &blk
      define_method i do
        if ! sandbox_module.const_defined? i, false
          blk.call  # do not instance exec this! run it in orig. context.
        end
        sandbox_module.const_get i, false
      end
    end
  end
end
