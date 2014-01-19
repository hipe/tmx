require_relative '..'
require 'skylab/headless/core'

module Skylab::TreetopTools

  Headless = ::Skylab::Headless
  TreetopTools = self

  Headless::MAARS[ self ]

  class RuntimeError < ::RuntimeError
  end

  class Parameter < Headless::Parameter
    param :dir, boolean: true
    param :exist, enum: [:must], accessor: true

    public :[]                    # the Definer::I_M of this is private
    public :known?                # the Definer::I_M of this is private

    def pathname= x
      super x
      :dir == x and dir!
    end
  end

  module Library_  # :+[#su-001]

    o = { }

    subsys = ::Skylab::Subsystem::FUN.require_subsystem

    o[ :Basic ] = subsys
    o[ :CodeMolester ] = subsys

    define_singleton_method :const_missing do |c|
      const_set c, o.fetch( c )[ c ]
    end
  end
end
