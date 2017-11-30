# frozen_string_literal: true

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

      _st = Basic_[]::String::LineStream_via_String[ io.string ]

      want_these_lines_in_array_ _st do |y|
        y << "command\n"
        y << "  argv\n"
        y << "    echo, \"it's\", \"\\\"fun\\\"\"\n"
        y << "  stdout_string\n"
        y << "    \"it's \\\"fun\\\"\n"
        y << "    \"\n"
        y << "  exitstatus 0\n"
      end
    end

    it "if options are provided, they get special treatment" do

      co = popen3_result_for_RW_.new
      co.receive_args [ 'hi', chdir: 'etc' ]

      io = new_string_IO_
      co.write_to io

      expect( io.string ).to eql <<~HERE
        command
          argv hi
          chdir etc
      HERE
    end
  end
end
