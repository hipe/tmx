require 'skylab/brazen'
require 'skylab/test_support'

module Skylab::Brazen::TestSupport

  class << self

    def [] tcc
      tcc.send :define_singleton_method, :use, Use_method___
      tcc.include InstanceMethods___
    end

    def lib sym
      _libs.public_library sym
    end

    def lib_ sym
      _libs.protected_library sym
    end

    def _libs
      @___libs ||= TestSupport_::Library.new TestLib_, TS_
    end
  end  # >>

  TestSupport_ = ::Skylab::TestSupport

  TestSupport_::Quickie.
    enhance_test_support_module_with_the_method_called_describe self

  Use_method___ = -> sym do
    TS_.lib_( sym )[ self ]
  end

  module InstanceMethods___

    def expect_these_lines_in_array_ act_s_a, & p

      TestSupport_::Expect_Line::Expect_these_lines_in_array.call(
        act_s_a, p, self )
    end

    def handle_event_selectively_
      event_log.handle_event_selectively
    end

    def black_and_white ev
      _expag = expression_agent  # yes different
      ev.express_into_under "", _expag
    end

    def black_and_white_lines ev
      _expag = expression_agent  # yes different
      ev.express_into_under [], _expag
    end

    def black_and_white_expression_agent_for_expect_emission
      This_one_expression_agent___[]
    end

    def begin_emission_spy_

      # (when your OCD prevents you from pulling in the test support module whole hog)

      Common_.test_support::Expect_Emission_Fail_Early::Spy.new
    end

    def ignore_emissions_whose_terminal_channel_is_in_this_hash
      NOTHING_
    end

    def prepared_tmpdir
      td = TestLib_::Tmpdir_controller_instance[]
      if do_debug
        if ! td.be_verbose
          td = td.with :be_verbose, true, :debug_IO, debug_IO
        end
      elsif td.be_verbose
        self._IT_WILL_BE_EASY
      end
      td.prepare
      td
    end

    def fixture_path_ tail
      ::File.join Fixture_path_directory_[], tail
    end

    def cfg_filename
      Home_::Models_::Workspace.default_config_filename
    end

    def subject_API_value_of_failure
      FALSE
    end

    def subject_API
      Home_::API
    end

    def debug!
      @do_debug = true
    end

    attr_reader :do_debug

    def debug_IO
      TestSupport_.debug_IO
    end
  end

  Common_ = ::Skylab::Common
  Lazy_ = Common_::Lazy

  # --

  This_one_expression_agent___ = Lazy_.call do
    Zerk_lib_[]::API::InterfaceExpressionAgent::THE_LEGACY_CLASS.
      via_expression_agent_injection :_no_injection_for_tests_BR_
  end

  This_other_expression_agent_ = Lazy_.call do
    Home_::No_deps_zerk_[]::API_InterfaceExpressionAgent.instance
  end

  Fixture_path_directory_ = Lazy_.call do
    ::File.join TS_.dir_path, 'fixtures'
  end

  # --

  module TestLib_

    Expect_emission_fail_early = -> tcc do
      Common_.test_support::Expect_Emission_Fail_Early[ tcc ]
    end

    Expect_event = -> test_context_cls do
      Common_.test_support::Expect_Emission[ test_context_cls ]
    end

    Fileutils = Lazy_.call do
      require 'fileutils'
      ::FileUtils
    end

    Memoizer_methods = -> tcc do
      TestSupport_::Memoization_and_subject_sharing[ tcc ]
    end

    The_method_called_let = -> tcc do
      TestSupport_::Let[ tcc ]
    end

    Tmpdir_controller_instance = Lazy_.call do

      _path = ::File.join Home_.lib_.system.defaults.dev_tmpdir_path, 'brzn'

      Home_.lib_.system_lib::Filesystem::Tmpdir.with(
        :path, _path,
      )
    end

    System_tmpdir_path = Lazy_.call do
      require 'tmpdir'
      ::Dir.tmpdir
    end

    Zerk_test_support = -> do
      Zerk_lib_[].test_support
    end
  end

  Common_::Autoloader[ self, ::File.dirname( __FILE__ ) ]

  Home_ = ::Skylab::Brazen

  EMPTY_A_ = Home_::EMPTY_A_
  EMPTY_S_ = ''.freeze
  NEWLINE_ = Home_::NEWLINE_
  NIL_ = nil
  NIL = nil  # open [#sli-016.C]
    FALSE = false ; TRUE = true
  NOTHING_ = nil
  SPACE_ = ' '.freeze
  TS_ = self
  Zerk_lib_ = Home_::Zerk_lib_
end
