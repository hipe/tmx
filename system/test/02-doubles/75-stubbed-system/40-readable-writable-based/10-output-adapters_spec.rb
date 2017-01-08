require_relative '../../../test-support'

module Skylab::System::TestSupport

  describe "[sy] doubles - stubbed-system - output-adapters" do

    TS_[ self ]
    use :doubles_stubbed_system

    it "loads" do
      subject_
    end

    it "writes one command" do

      co = popen3_result_for_RW_.new
      co.receive_args [ "echo", "it's", '"fun"' ]
      co.stdout_string = "it's \"fun\"\n"
      co.exitstatus = 0

      io = new_string_IO_
      co.write_to io

      st = Home_.lib_.basic::String.line_stream io.string

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

      co = popen3_result_for_RW_.new
      co.receive_args [ 'hi', chdir: 'etc' ]

      io = new_string_IO_
      co.write_to io

      io.string.should eql <<-HERE.unindent
        command
          argv hi
          chdir etc
      HERE
    end
  end
end
