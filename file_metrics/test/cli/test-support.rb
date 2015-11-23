require_relative '../test-support'

module Skylab::FileMetrics::TestSupport::CLI

  Parent__ = ::Skylab::FileMetrics::TestSupport

  Parent__[ TS_ = self ]

  TestSupport_ = ::Skylab::TestSupport

  extend TestSupport_::Quickie

  # ~ table-specific layer atop "execution snapshot"

  module InstanceMethods

    def subject_CLI
      Home_::CLI
    end

    define_method :get_invocation_strings_for_expect_stdout_stderr, -> do

      s_a = [ '[flz]' ]
      -> do
        s_a
      end
    end.call
  end

  # ~ experimental "execution snapshot"

  module ModuleMethods

    def memoize_output_lines_ & p

      memoized_structure = nil

      define_method :execution_snapshot_ do

        memoized_structure ||= __flush_execution p
      end
    end
  end

  module InstanceMethods

    def __flush_execution p

      instance_exec( & p )

      _em_a = flush_baked_emission_array
      Execution_Snapshot___.new _em_a, @exitstatus
    end
  end

  class Execution_Snapshot___

    def initialize x, x_
      @exitstatus = x_
      @output_lines = x
      @memo = {}
    end

    attr_reader :exitstatus, :memo, :output_lines
  end

  # ~ standard

  module ModuleMethods

    def use sym

      case sym
      when :expect_CLI
        Home_.lib_.brazen.test_support.lib( :CLI_expectations )[ self ]

      when :classify_common_screen
        TS_::Classify_Common_Screen[ self ]

      else
        raise ::KeyError, sym
      end
      NIL_
    end
  end

  o = Parent__

  Home_ = ::Skylab::FileMetrics

  Callback_ = Home_::Callback_
  EMPTY_S_ = o::EMPTY_S_
  Fixture_file_directory_ = o::Fixture_file_directory_
  Fixture_tree_directory_ = o::Fixture_tree_directory_
  NEWLINE_ = o::NEWLINE_
  NIL_ = nil
  SPACE_ = Home_::SPACE_
  UNDERSCORE_ = '_'
end
