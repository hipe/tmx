require 'skylab/task'
require 'skylab/test_support'

module Skylab::Task::TestSupport

  class << self

    def [] tcc
      tcc.send :define_singleton_method, :use, Use_method___
      tcc.include Instance_Methods___
    end

    def lib sym
      _lib.public_library sym
    end

    def lib_ sym
      _lib.protected_library sym
    end

    def _lib
      @___lib ||= TestSupport_::Library.new TS_
    end
  end  # >>

  TestSupport_ = ::Skylab::TestSupport

  TestSupport_::Quickie.
    enhance_test_support_module_with_the_method_called_describe self

    Use_method___ = -> sym, * x_a do
      TS_.lib_( sym )[ self, * x_a ]
    end

  module Instance_Methods___

    def debug!
      @do_debug = true
    end

    attr_reader :do_debug

    def debug_IO
      TestSupport_.debug_IO
    end

    # -- SETUP

    def build_exception_throwing_state_ & cls_p

      o = _setup_state
      begin
        o.execute_as_front_task
      rescue cls_p[] => e
      end

      if e
        e
      else
        fail
      end
    end

    def build_state_

      o = _setup_state
      _x = o.execute_as_front_task
      flush_event_log_and_result_to_state _x
    end

    def build_my_state_via_ result, emissions=nil, task
      State___.new result, emissions, task
    end

    State___ = ::Struct.new :result, :emission_x_a, :task

    def _setup_state

      _ = handler_
      _cls = task_class_
      o = _cls.new( & _ )
      add_parameters_into_ o
      o
    end

    def common_expression_agent_for_expect_emission_
      Home_.lib_.brazen::API.expression_agent_instance
    end

    def common_handler_
      event_log.handle_event_selectively
    end

    # -- ASSERTION

    def fails_
      false == state_.result or fail
    end

    def succeeds_
      true == state_.result or fail
    end

    def threw_
      state_ or fail
    end

    def exception_message_
      state_.message
    end

    def state_for_expect_emission
      state_
    end
  end

  # -- these

  Subject_class_ = -> do
    Home_  # one to rule them all
  end

  # -- these

  Expect_Event = -> tcc do
    Common_.test_support::Expect_Emission[ tcc ]
  end

  module Magnetics_CLI
    def self.[] tcc
      Require_zerk_[]
      Zerk_.test_support::Non_Interactive_CLI[ tcc ]
      tcc.send :define_method, :subject_CLI do
        Home_::Magnetics::CLI
      end
    end
  end

  Memoizer_Methods = -> tcc do
    TestSupport_::Memoization_and_subject_sharing[ tcc ]
  end

  # --

  Home_ = ::Skylab::Task
  Lazy_ = Home_::Lazy_

  Require_zerk_ = Lazy_.call do
    Zerk_ = Home_.lib_.zerk ; nil
  end

  Autoloader_ = Home_::Autoloader_

  module TestLib_

    sidesys = Autoloader_.build_require_sidesystem_proc

    system_lib = nil

    Tee = -> do
      system_lib[]::IO::Mappers::Tee
    end

    system_lib = sidesys[ :System ]
  end

  Autoloader_[ self, ::File.dirname( __FILE__ ) ]

  Common_ = Home_::Common_
  EMPTY_S_ = Home_::EMPTY_S_
  NIL_ = nil
  NOTHING_ = nil
  TS_ = self
end
