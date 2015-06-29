require_relative '../core'
require 'skylab/test-support/core'

module Skylab::Plugin::TestSupport

  TestSupport_ = ::Skylab::TestSupport

  TestSupport_::Regret[ TS_ = self ]

  extend TestSupport_::Quickie

  module ModuleMethods

    define_method :use, -> do

      cache_h = {}

      -> sym do

        ( cache_h.fetch sym do

          const = Callback_::Name.via_variegated_symbol( sym ).as_const

          x = if TS_.const_defined? const, false
            TS_.const_get const, false
          else
            Home_::Bundle::Fancy_lookup[ sym, TS_ ]
          end
          cache_h[ sym ] = x
          x
        end )[ self ]
      end
    end.call
  end

  module InstanceMethods

    def debug!
      @do_debug = true
    end

    attr_reader :do_debug

    def debug_IO
      TestSupport_.debug_IO
    end
  end

  Dangerous_memoize_ = -> & meth_p do
    x = nil
    -> do
      x ||= instance_exec( & meth_p )
    end
  end

  Expect_Event = -> tcm do

    Callback_.test_support::Expect_Event[ tcm ]

    tcm.send :define_method, :black_and_white_expression_agent_for_expect_event do
      Home_.lib_.brazen::API.expression_agent_instance
    end

    NIL_
  end

  Home_ = ::Skylab::Plugin

  ACHIEVED_ = true
  Callback_ = Home_::Callback_
  NIL_ = nil
end
