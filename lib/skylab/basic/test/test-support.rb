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

      define_method :dangerous_memoize_, TestSupport_::DANGEROUS_MEMOIZE

      def memoize_ sym, & p
        define_method sym, ( Callback_.memoize do
          p[]
        end )
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
            TestSupport_.fancy_lookup sym, TS_
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
        Home_.lib_.brazen::API.expression_agent_instance
      end
    end

    Expect_Event = -> test_context_class do

      Home_::Callback_.test_support::Expect_Event[ test_context_class ]
    end

    Home_ = ::Skylab::Basic
    Callback_ = Home_::Callback_
    EMPTY_A_ = Home_::EMPTY_A_
    EMPTY_S_ = Home_::EMPTY_S_
    NIL_ = nil

    module Constants
      Home_ = Home_
      Callback_ = Callback_
      TestSupport_ = TestSupport_
    end
  end
end
