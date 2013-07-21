require_relative '..'
require 'skylab/headless/core'

module Skylab::TreetopTools

  Headless = ::Skylab::Headless
  TreetopTools = self

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

  module Services

    o = { }

    o[ :Basic ] = ::Skylab::Subsystem::FUN.require_subsystem

    define_singleton_method :const_missing do |c|
      const_set c, o.fetch( c )[ c ]
    end
  end
end
