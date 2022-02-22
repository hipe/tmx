module Skylab::Cull::TestSupport

  module CLI

    def self.[] tcc
      tcc.include TestSupport_::Want_Stdout_Stderr::Test_Context_Instance_Methods
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

      @IO_spy_group_for_want_stdout_stderr = g

      @exitstatus = Home_::CLI.new( argv, nil, * g.values_at( :o, :e ), [ 'kul' ] ).execute

      nil
    end

    def want_exitstatus_for_general_failure

      expect( @exitstatus ).to eql(
        Home_.lib_.brazen::API.exit_statii.fetch :generic_error )
    end
  end
end
