module Skylab::Cull::TestSupport

  module Clients::CLI

    def self.[] tcc

      tcc.include TestSupport_::Expect_Stdout_Stderr::Test_Context_Instance_Methods
      tcc.send :define_method, :expect, tcc.instance_method( :expect )  # #rspec-annoyance

      tcc.include self
    end

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

      @exitstatus = Home_::CLI.new( nil, * g.values_at( :o, :e ), [ 'kul' ] ).invoke argv

      nil
    end

    def expect_exitstatus_for_general_failure

      @exitstatus.should eql(
        Home_::Brazen_::API.exit_statii.fetch :generic_error )
    end
  end
end
