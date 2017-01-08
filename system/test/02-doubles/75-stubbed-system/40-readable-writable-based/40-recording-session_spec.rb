require_relative '../../../test-support'

module Skylab::System::TestSupport

  describe "[sy] doubles - stubbed-system - recording session (#LIVE)" do

    TS_[ self ]
    use :expect_line
    use :doubles_stubbed_system

    it "works" do

      io = new_string_IO_

      x = subject_.recording_session io do | sess |

        i, o, e, t = sess.popen3 'echo', "it's", '"fun"'

        i.should be_nil
        o.gets.should eql "it's \"fun\"\n"
        o.gets.should be_nil

        e.gets.should be_nil
        t.value.exitstatus.should be_zero

        _, o, e, t = sess.popen3 'date'

        ( 25 .. 35 ).should be_include o.gets.length
        o.gets.should be_nil

        e.gets.should be_nil
        t.value.exitstatus.should be_zero
      end

      x.should eql true
      io.close

      @output_s = io.string

      excerpt( 0..7 ).should eql <<-HERE.unindent
        command
          argv
            echo, "it's", "\\"fun\\""
          stdout_string
            "it's \\"fun\\"
            "
          stderr_string ""
          exitstatus 0
      HERE

      excerpt_lines( 10..10 ).first.should eql "  argv date\n"
    end
  end
end
