require_relative '../../test-support'

module Skylab::GitViz::TestSupport::Test_Lib

  describe "[gv] test-lib - mock-sys - input-adapters" do

    it "reads one command" do

      against <<-HERE.unindent
        command
          argv
            echo, "it's", "\\"fun\\""
          stdout_string
            "it's \\"fun\\"
            "
          exitstatus 0
      HERE

      co = @st.gets
      co.argv.should eql [ 'echo', "it's", "\"fun\"" ]
      co.stdout_string.should eql "it's \"fun\"\n"
      co.stderr_string.should be_nil
      co.exitstatus.should be_zero

      @st.gets.should be_nil
    end

    it "reads two commands" do
      against <<-HERE.unindent
        command
          argv
            one, two
          stdout_string "\\n"

            # comment

        command
          argv
           three
          exitstatus
            015
      HERE

      co = @st.gets
      co.argv.should eql %w( one two )
      co.stdout_string.should eql "\n"

      co = @st.gets
      co.argv.should eql [ 'three' ]
      co.exitstatus.should eql 15

      @st.gets.should be_nil
    end

    def against s
      _st = GitViz_.lib_.basic::String.line_stream s
      @st = subject::Models_::Command.unmarshalling_stream _st, :OGDL
      NIL_
    end

    def subject
      GitViz_::Test_Lib_::Mock_Sys
    end
  end
end
