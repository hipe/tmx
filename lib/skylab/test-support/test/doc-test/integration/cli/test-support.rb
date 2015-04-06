require_relative '../../test-support'

module Skylab::TestSupport::TestSupport::DocTest::CLI

  Parent_ = ::Skylab::TestSupport::TestSupport::DocTest

  Parent_[ TS_ = self ]

  include Constants

  extend TestSupport_::Quickie

  TestSupport_ = TestSupport_

  module InstanceMethods

    include TestSupport_::Expect_Stdout_Stderr::Test_Context_Instance_Methods

    define_method :expect, instance_method( :expect )  # because rspec

    def invoke * s_a

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
        [ FAKE_PROGNAME_ ] )

      @exitstatus = _invocation.invoke s_a

      @IO_spy_group_for_expect_stdout_stderr = g
      nil
    end

    def _CLI_module
      Subject_[]::CLI
    end

    def the_main_real_file_doctestable_file_path
      TestSupport_::DocTest.dir_pathname.join( 'core.rb' ).to_path
    end

    def expect_failed
      expect_no_more_lines
      @exitstatus.should eql Generic_error__[]
    end

    def equal_generic_error
      eql Generic_error__[]
    end

    def count_occurrences_of_newlines_in_string string
      count_occurrences_in_string_of_string string, TestSupport_::NEWLINE_
    end

    def count_occurrences_in_string_of_string haystack_s, needle_s
      TestSupport_.lib_.basic::String.
        count_occurrences_in_string_of_string haystack_s, needle_s
    end
  end

  FAKE_PROGNAME_ = 'ts-dt'

  Generic_error__ = TestSupport_::Callback_.memoize do
    TestSupport_.lib_.brazen::API.exit_statii.fetch :generic_error
  end

  Subject_ = Parent_::Subject_
end
