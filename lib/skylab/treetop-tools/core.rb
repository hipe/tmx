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

    o[ :Basic ] = ::Skylab::MetaHell::FUN.require_subproduct

    define_singleton_method :const_missing do |i|
      const_set i, o.fetch( i )[ i ]
    end
  end
end
