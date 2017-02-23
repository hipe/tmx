require 'skylab/brazen'
require 'skylab/test_support'

module Skylab::Brazen::TestSupport

  class << self

    def [] tcc
      tcc.send :define_singleton_method, :use, Use_method___
      tcc.include Instance_Methods___
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

  module Instance_Methods___

    def debug!
      @do_debug = true
    end

    attr_reader :do_debug

    def debug_IO
      TestSupport_.debug_IO
    end

    def handle_event_selectively_
      event_log.handle_event_selectively
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

    def black_and_white_expression_agent_for_expect_emission
      This_one_expression_agent___[]
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
  end

  Common_ = ::Skylab::Common

  Lazy_ = Common_::Lazy

  This_one_expression_agent___ = Lazy_.call do
    Zerk_lib_[]::API::InterfaceExpressionAgent::THE_LEGACY_CLASS.
      via_expression_agent_injection :_no_injection_for_tests_BR_
  end

  module TestLib_

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

      sys = Home_::LIB_.system

      _path = ::File.join sys.defaults.dev_tmpdir_path, 'brzn'

      sys.filesystem.tmpdir :path, _path
    end

    System_tmpdir_path = Lazy_.call do
      require 'tmpdir'
      ::Dir.tmpdir
    end

    Zerk_test_support = -> do
      Zerk_lib_[].test_support
    end
  end

  module Test_Instance_Methods_

    def initialize & edit_p
      instance_exec( & edit_p )
    end

  # ~ to be an entity (model or action) you have to:

    def knownness_via_association_ prp  # :+#cp

      if bx
        had = true
        x = bx.fetch prp.name_symbol do
          had = false
        end
      end

      if had
        Common_::Known_Known[ x ]
      else
        Common_::KNOWN_UNKNOWN
      end
    end

    def as_entity_actual_property_box_
      @bx ||= Home_::Box_.new
    end

    def handle_event_selectively
      NIL_
    end

  # ~ for these tests

    attr_reader :bx

    private def process_and_normalize_for_test_ * x_a

      _st = Common_::Scanner.via_array x_a
      _ok = process_argument_scanner_fully _st
      _ok && normalize
    end
  end

  module Fixtures
    Common_::Autoloader[ self ]  # don't load fixture file when autoloading lib
  end

  Common_::Autoloader[ self, ::File.dirname( __FILE__ ) ]

  Home_ = ::Skylab::Brazen

  EMPTY_A_ = Home_::EMPTY_A_
  EMPTY_S_ = ''.freeze
  NIL_ = nil
  NOTHING_ = nil
  SPACE_ = ' '.freeze
  TS_ = self
  Zerk_lib_ = Home_::Zerk_lib_
end
