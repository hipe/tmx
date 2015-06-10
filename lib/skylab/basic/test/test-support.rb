require_relative '../core'

module Skylab::Basic

  module TestSupport

    TestSupport_ = Autoloader_.require_sidesystem :TestSupport

    TestSupport_::Regret[ TS_ = self ]

    TestSupport_::Sandbox::Host[ self ]

    extend TestSupport_::Quickie

    module ModuleMethods

      def use sym, * args
        Use___[ args, sym, self ]
      end
    end

    Use___ = -> do

      cache_h = {}

      -> args, sym, tcm do

        ( cache_h.fetch sym do

          const = Callback_::Name.via_variegated_symbol( sym ).as_const

          x = if TS_.const_defined? const, false
            TS_.const_get const, false
          else
            Basic_.lib_.brazen::Bundle::Fancy_lookup[ sym, TS_ ]
          end

          cache_h[ sym ] = x

          x
        end )[ tcm, * args ]
      end
    end.call

    module InstanceMethods

      def debug!
        @do_debug = true
      end

      attr_reader :do_debug

      def debug_IO
        TestSupport_.debug_IO
      end

      def black_and_white_expression_agent_for_expect_event
        Basic_.lib_.brazen::API.expression_agent_instance
      end
    end

    Expect_Event = -> test_context_class do

      Basic_::Callback_.test_support::Expect_Event[ test_context_class ]
    end

    Basic_ = ::Skylab::Basic
    Callback_ = Basic_::Callback_
    EMPTY_A_ = Basic_::EMPTY_A_
    EMPTY_S_ = Basic_::EMPTY_S_
    NIL_ = nil

    module Constants
      Basic_ = Basic_
      Callback_ = Callback_
      TestSupport_ = TestSupport_
    end
  end
end
