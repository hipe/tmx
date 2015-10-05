require_relative '../core'
require 'skylab/test-support/core'

module Skylab::Permute::TestSupport

  TestSupport_ = ::Skylab::TestSupport

  TestSupport_::Regret[ TS_ = self ]

  extend TestSupport_::Quickie

  module ModuleMethods

    def use sym

      _const = Callback_::Name.via_variegated_symbol( sym ).as_const
      TS_.const_get( _const, false )[ self ]
      NIL_
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

    def subject_API
      Home_.application_kernel_
    end

    def black_and_white_expression_agent_for_expect_event
      Home_.lib_.brazen::API.expression_agent_instance
    end
  end

  module Expect_CLI

    class << self

      def [] test_cls

        Home_.lib_.brazen.test_support.CLI::Expect_CLI[ test_cls ]

        test_cls.include self

      end
    end  # >>

    def subject_CLI
      Home_::CLI
    end

    def get_invocation_strings_for_expect_stdout_stderr
      %w( pmt )
    end

    def the_list_of_all_visible_actions_for_expect_CLI
      %w( ping generate )
    end
  end

  Expect_Event = -> tcm do
    Callback_.test_support::Expect_Event[ tcm ]
  end

  EMPTY_S_ = ''
  NIL_ = nil
  Home_ = ::Skylab::Permute
  Callback_ = Home_::Callback_
end

# :+#tombstone: was [#ts-010] dark hack "one weird old tr.."
