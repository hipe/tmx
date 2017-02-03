require_relative '../test-support'

module Skylab::Treemap::TestSupport

  describe "[tr] output-adapters - group by sigil" do

    TS_[ self ]
    use :expect_event

    it "OK (small representative sample)" do

      _path = Fixture_file_[ 'eg-050-small-representative-sample' ]

      io = TS_.string_IO.new

      call_API :session,
        :upstream_identifier, _path,
        :stdin, Home_.lib_.system.test_support::STUBS.interactive_STDIN_instance,
        :stdout, io,
        :stderr, :_no_stderr_,
        :output_adapter, 'group-by-sigi'

      expect_succeed
      scn = TestSupport_::Expect_Line::Scanner.via_string io.string

      scn.next_line.should eql "[ab]...(3)\n"
      scn.next_line.should eql "[cd].(1)\n"
      scn.next_line.should eql "(4 tests over 2 sigil changes)\n"
      scn.next_line.should be_nil
    end
  end
end
