require_relative '../test-support'

module Skylab::GitViz::TestSupport::Test_Lib

  describe "[gv] test-lib - mock-sys - 01: output-adapters" do

    extend TS_

    it "loads" do
      subject
    end

    it "writes one command" do

      co = subject::Models_::Command.new
      co.receive_args [ "echo", "it's", '"fun"' ]
      co.stdout_string = "it's \"fun\"\n"
      co.exitstatus = 0

      io = new_string_IO_
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

    it "if options are provided, they get special treatment" do

      co = subject::Models_::Command.new
      co.receive_args [ 'hi', chdir: 'etc' ]

      io = new_string_IO_
      co.write_to io

      io.string.should eql <<-HERE.unindent
        command
          argv hi
          chdir etc
      HERE
    end

    def subject
      GitViz_::Test_Lib_::Mock_System
    end
  end
end
