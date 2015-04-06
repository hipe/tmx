require_relative '../../test-support'

module Skylab::Cull::TestSupport::Clients_CLI

  ::Skylab::Cull::TestSupport[ TS_ = self ]

  include Constants

  Cull_ = Cull_

  TestSupport_ = TestSupport_

  extend TestSupport_::Quickie

  module InstanceMethods

    include TestSupport_::Expect_Stdout_Stderr::Test_Context_Instance_Methods

    def invoke * argv

      g = TestSupport_::IO.spy.group.new

      g.do_debug_proc = -> do
        do_debug
      end

      g.debug_IO = debug_IO

      g.add_stream :i, :_no_instream_
      g.add_stream :o
      g.add_stream :e

      @IO_spy_group_for_expect_stdout_stderr = g

      @exitstatus = Cull_::CLI.new( nil, * g.values_at( :o, :e ), [ 'kul' ] ).invoke argv

      nil
    end

    define_method :expect, instance_method( :expect )  # because rpsec

    def expect_exitstatus_for_general_failure

      @exitstatus.should eql(
        Cull_::Brazen_::API.exit_statii.fetch :generic_error )
    end
  end
end
