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

end
