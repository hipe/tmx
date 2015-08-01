require_relative '../core'
require 'skylab/test-support/core'

module Skylab::Fields::TestSupport

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
            TS_.const_get( const )
          else
            TestSupport_.fancy_lookup sym, TS_
          end
          cache_h[ sym ] = x
          x
        end )[ self ]
      end
    end.call

    def subject & p
      memoize_ :subject, & p
    end

    def memoize_ sym, & p
      define_method sym, Callback_.memoize( & p )
    end
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

  Build_next_integer_generator_starting_after = -> d do

    -> do
      d += 1
    end
  end

  Expect_Event = -> tcm do

    Callback_.test_support::Expect_Event[ tcm ]

    tcm.send :define_method, :black_and_white_expression_agent_for_expect_event do
      Home_.lib_.brazen::API.expression_agent_instance
    end

    NIL_
  end

  Home_ = ::Skylab::Fields

  Callback_ = Home_::Callback_
  NIL_ = nil
end

Skylab::TestSupport::Quickie.enable_kernel_describe  # for > 10 legacy files
