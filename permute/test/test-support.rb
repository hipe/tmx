require 'skylab/permute'
require 'skylab/test_support'

module Skylab::Permute::TestSupport

  class << self
    def [] tcc
      tcc.send :define_singleton_method, :use, Use_method___
      tcc.include InstanceMethods___
    end
  end  # >>

  TestSupport_ = ::Skylab::TestSupport

  extend TestSupport_::Quickie

  # -
    Use_method___ = -> sym do
      s = sym.id2name
      s[ 0 ] = s[ 0 ].upcase
      Use__.const_get( s, false )[ self ]
      NIL
    end
  # -

  module InstanceMethods___

    attr_reader :do_debug

    def debug!
      @do_debug = true
    end

    def debug_IO
      TestSupport_.debug_IO
    end

    def subject_API
      Home_::API
    end
  end

  Use__ = ::Module.new

  module Use__::My_CLI

    class << self

      def [] tcc
        Zerk_test_support_[]::Non_Interactive_CLI[ tcc ]
        # Home_.lib_.brazen.test_support.lib( :CLI_support_expectations )[ tcc ]
        tcc.include self
      end
    end  # >>

    pn_s_a = nil
    define_method :invocation_strings_for_expect_stdout_stderr do
      pn_s_a ||= %w([pe])
    end

    def _WAS_ get_invocation_strings_for_expect_stdout_stderr
      %w( pmt )
    end

    def _WAS2_ the_list_of_all_visible_actions_for_CLI_expectations
      %w( ping generate )
    end

    def subject_CLI
      Home_::CLI
    end
  end

  # --

  Expect_no_emission_ = -> * x_a do
    fail "expected no events, had #{ x_a.inspect }"
  end

  # --

  module Use__

    Expect_event = -> tcm do
      Common_.test_support::Expect_Emission[ tcm ]
    end

    Memoizer_methods = -> tcm do
      TestSupport_::Memoization_and_subject_sharing[ tcm ]
    end
  end

  Home_ = ::Skylab::Permute
  Common_ = Home_::Common_

  # --

  Lazy_ = Common_::Lazy

  Zerk_test_support_ = Lazy_.call do
    Home_::Zerk_lib_[].test_support
  end

  # --

  Common_::Autoloader[ self, ::File.dirname( __FILE__ ) ]

  EMPTY_S_ = ''
  NIL_ = nil
  TS_ = self
end
# :+#tombstone: was [#ts-010] dark hack "one weird old tr.."
