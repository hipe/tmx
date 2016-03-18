require 'skylab/task_examples'
require 'skylab/test_support'

module Skylab::TaskExamples::TestSupport

  class << self

    def [] tcc

      tcc.include Instance_Methods___

      h = {}
      tcc.send :define_singleton_method, :use do | sym |

        _lib = h.fetch sym do
          x = TestSupport_.fancy_lookup sym, TS_
          h[ sym ] = x
          x
        end

        _lib[ self ]
      end

      NIL_
    end

    def const_missing sym
      x = LAZY_CONSTANTS___.lookup sym
      const_set sym, x
      x
    end
  end  # >>

  TestSupport_ = ::Skylab::TestSupport

  extend TestSupport_::Quickie

  module Instance_Methods___

    def debug!
      @do_debug = true
    end

    attr_reader :do_debug

    def debug_IO
      TestSupport_.debug_IO
    end

    # -- setup

    def build_common_state_ result_x, em_a, task=nil
      State___[ result_x, em_a, task ]
    end

    # -- assertion

    def fails_
      _x = state_.result
      false == _x or fail
    end
  end

  State___ = ::Struct.new :result, :emission_array, :task

  # ~ function-like

  yes = true
  do_run = nil
  Run_static_file_server_if_necessary_ = -> & x_y do  # (from our cmdline script too)
    if yes
      yes = false
      do_run[ & x_y ]
    end
  end

  do_run = -> & x_y do

    do_debug, debug_IO = x_y[]

    expag = nil ; y = nil

    emit = -> x, & p do

      expag = Home_.lib_.brazen::API.expression_agent_instance
      y = ::Enumerator::Yielder.new do | s |
        debug_IO.puts s
      end

      emit = -> i_a, & ev_p do
        if :expression == i_a[ 1 ]
          expag.calculate y, & ev_p
        else
          ev_p[].express_into_under y, expag
        end
      end
      emit[ x, & p ]
    end

    if do_debug

      _handle = -> * i_a, & ev_p do
        debug_IO.puts i_a.inspect
        emit[ i_a, & ev_p ]
      end
    else
      _handle = -> * i_a, & ev_p do
        if :info != i_a.first
          emit[ i_a, & ev_p ]
        end
      end
    end

    _path = FIXTURES_DIR
    _PID_path = TestLib_::Development_tmpdir_path[]

    _ok = TestSupport_::Servers::Static_File_Server.new(
      _path,
      :PID_path, _PID_path,
      & _handle
    ).execute

    _ok or self._FAIL

    NIL_
  end

  Task_types_ = -> do
    Home_::TaskTypes
  end

  # ~ these

  Expect_Event = -> tcc do
    Callback_.test_support::Expect_Event[ tcc ]
  end

  Memoizer_Methods = -> tcc do
    TestSupport_::Memoization_and_subject_sharing[ tcc ]
  end

  # ~ library-like

  class LAZY_CONSTANTS___ < TestSupport_::Lazy_Constants

    def BUILD_DIR
      # ::File.join TestLib_::System_tmpdir_path[], '[te]'
      ::File.join TestLib_::Development_tmpdir_path[], '[te]'
    end

    def FIXTURES_DIR
      TS_.dir_pathname.join( 'fixtures' ).to_path
    end
  end

  Home_ = ::Skylab::TaskExamples
  Autoloader__ = Home_::Autoloader_

  module TestLib_

    sidesys = Autoloader__.build_require_sidesystem_proc

    Brazen = sidesys[ :Brazen ]

    hl = sidesys[ :Headless ]

    CLI_lib = -> do
      hl[]::CLI
    end

    system_lib = sidesys[ :System ]

    Development_tmpdir_path = -> do
      System[].defaults.dev_tmpdir_path
    end

    System = -> do
      system_lib[].services
    end

    System_tmpdir_path = -> do
      System[].filesystem.tmpdir_path
    end

    Task = sidesys[ :Task ]
  end

  Autoloader__[ self, ::File.dirname( __FILE__ ) ]

  Callback_ = Home_::Callback_
  DOT_BYTE_ = '.'.getbyte 0
  EMPTY_A_ = []
  EMPTY_H_ = {}.freeze
  NIL_ = nil
  NOTHING_ = nil
  TS_ = self
end
