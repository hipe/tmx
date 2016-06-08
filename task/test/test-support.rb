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

  extend TestSupport_::Quickie

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

    # -- SETUP

    def build_exception_throwing_state_

      o = _setup_state
      begin
        o.execute_as_front_task
      rescue ::ArgumentError => e
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

    def common_expression_agent_for_expect_event_
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
  end

  # -- these

  Subject_class_ = -> do
    Home_  # one to rule them all
  end

  # -- these

  Expect_Event = -> tcc do
    Common_.test_support::Expect_Event[ tcc ]
  end

  Memoizer_Methods = -> tcc do
    TestSupport_::Memoization_and_subject_sharing[ tcc ]
  end

  # --

  Home_ = ::Skylab::Task
  Autoloader__ = Home_::Autoloader_

  module TestLib_

    sidesys = Autoloader__.build_require_sidesystem_proc

    system_lib = nil

    Tee = -> do
      system_lib[]::IO::Mappers::Tee
    end

    system_lib = sidesys[ :System ]
  end

  Autoloader__[ self, ::File.dirname( __FILE__ ) ]

  Common_ = Home_::Common_
  NIL_ = nil
  NOTHING_ = nil
  TS_ = self
end
