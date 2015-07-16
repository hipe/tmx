require_relative '../core'
require 'skylab/test-support/core'

module Skylab::TMX::TestSupport

  TestSupport_ = ::Skylab::TestSupport

  TestSupport_::Regret[ TS_ = self ]

  extend TestSupport_::Quickie

  module ModuleMethods

    define_method :use, -> do
      cache = {}
      -> sym do
        ( cache.fetch sym do

          const = Callback_::Name.via_variegated_symbol( sym ).as_const

          x = if TS_.const_defined? const
            TS_.const_get const
          else
            TestSupport_.fancy_lookup sym, TS_
          end
          cache[ sym ] = x
          x
        end )[ self  ]
      end
    end.call

    def dangerous_memoize_ sym, & p
      first = true
      x = nil
      define_method sym do
        if first
          first = false
          x = instance_exec( & p )
        end
        x
      end
    end

    def memoize_ sym, & p
      define_method sym, Callback_.memoize( & p )
    end
  end

  module InstanceMethods

    attr_reader :do_debug

    def debug!
      @do_debug = true
    end

    def debug_IO
      TestSupport_.debug_IO
    end

    def black_and_white_expression_agent_for_expect_event
      Home_.lib_.brazen::API.expression_agent_instance
    end
  end

  Callback_ = ::Skylab::Callback
  Home_ = ::Skylab::TMX
  NIL_ = nil
end
