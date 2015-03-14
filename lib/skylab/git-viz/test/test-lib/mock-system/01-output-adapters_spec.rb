require_relative '../test-support'

module Skylab::GitViz::TestSupport::Test_Lib

  describe "[gv] test-lib - mock-sys - output-adapters" do

    it "loads" do
      subject
    end

    it "writes one command" do

      co = subject::Models_::Command.new
      co.argv = [ "echo", "it's", '"fun"' ]
      co.stdout_string = "it's \"fun\"\n"
      co.exitstatus = 0

      io = ::StringIO.new
      co.write_to io

      st = GitViz_.lib_.basic::String.line_stream io.string

      st.gets.should eql "command\n"
      st.gets.should eql "  argv\n"
      st.gets.should eql "    echo, \"it's\", \"\\\"fun\\\"\"\n"
      st.gets.should eql "  stdout_string\n"
      st.gets.should eql "    \"it's \\\"fun\\\"\n"
      st.gets.should eql "    \"\n"
      st.gets.should eql "  exitstatus 0\n"
      st.gets.should be_nil
    end

    def subject
      GitViz_::Test_Lib_::Mock_Sys
    end
  end
end
