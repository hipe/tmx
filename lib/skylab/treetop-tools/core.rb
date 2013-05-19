require_relative '..'
require 'skylab/headless/core'

module Skylab::TreetopTools

  Headless = ::Skylab::Headless
  extend Headless::MAARS

  const_get :Grammar, false       # ick load this now so we can say 'Grammar'

  class RuntimeError < ::RuntimeError
  end

  class Parameter < Headless::Parameter
    param :dir, boolean: true
    param :exist, enum: [:must], accessor: true

    public :[]                    # the Definer::I_M of this is protected
    public :known?                # the Definer::I_M of this is protected

    def pathname= x
      super x
      :dir == x and dir!
    end
  end
end
