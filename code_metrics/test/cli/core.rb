module Skylab::CodeMetrics::TestSupport

  module CLI

    def self.[] tcc
      tcc.extend Module_Methods__
      tcc.include Instance_Methods__
    end

    Support_Expectations = -> tcc do
      Home_.lib_.brazen.test_support.lib( :CLI_support_expectations )[ tcc ]
    end

    # <-

  # ~ table-specific layer atop "execution snapshot"

  module Instance_Methods__

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

  module CLI::Module_Methods__

    def memoize_output_lines_ & p

      memoized_structure = nil

      define_method :execution_snapshot_ do

        memoized_structure ||= __flush_execution p
      end
    end
  end

  module Instance_Methods__

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
  # ->
  end
end
