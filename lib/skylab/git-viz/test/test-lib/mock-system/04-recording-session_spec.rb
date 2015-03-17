require_relative '../test-support'

module Skylab::GitViz::TestSupport::Test_Lib

  describe "[gv] test-lib - mock-sys - recording session (#LIVE)" do

    extend TS_
    use :expect_line

    it "works" do

      io = new_string_IO_

      x = subject.recording_session io do | sess |

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

    def subject
      GitViz_::Test_Lib_::Mock_System
    end
  end
end
