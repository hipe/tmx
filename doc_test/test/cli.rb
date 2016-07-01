module Skylab::DocTest::TestSupport

  module CLI

    def self.[] tcc
      tcc.include self
    end

    # -

    # define_method :expect, instance_method( :expect )  # because rspec

    def invoke * s_a

      self._NO_use_zerk  # no it's becky

      g = TestSupport_::IO.spy.group.new
      g.debug_IO = debug_IO
      g.do_debug_proc = -> do
        do_debug
      end
      # g.add_stream :i, :_no_input_stream_
      g.add_stream :output
      g.add_stream :errput

      _invocation = _CLI_module.new( nil,
        * g.values_at( :output, :errput ),
        [ FAKE_PROGNAME___ ] )

      @exitstatus = _invocation.invoke s_a

      @IO_spy_group_for_expect_stdout_stderr = g
      nil
    end

    def _CLI_module  # library scope
      Home_::CLI
    end

    def the_main_real_file_doctestable_file_path
      ::File.join sidesystem_path_, Autoloader_.default_core_file
    end

    def expect_failed
      expect_no_more_lines
      @exitstatus.should eql Generic_error__[]
    end

    def equal_generic_error
      eql Generic_error__[]
    end

    def count_occurrences_of_newlines_in_string string
      count_occurrences_in_string_of_string string, NEWLINE_
    end

    def count_occurrences_in_string_of_string haystack_s, needle_s
      Home_.lib_.basic::String.
        count_occurrences_in_string_of_string haystack_s, needle_s
    end

    # ==

    FAKE_PROGNAME___ = 'ts-dt'

    Generic_error__ = Common_::Lazy.call do
      TestLib_.lib_.brazen::API.exit_statii.fetch :generic_error
    end
  end
end
