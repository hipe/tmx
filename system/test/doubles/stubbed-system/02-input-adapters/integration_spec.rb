require_relative '../test-support'

module Skylab::System::TestSupport::Doubles_Stubbed_System

  describe "[sy] doubles - mock-sys - 02: input-adapters" do

    it "reads one command" do

      _against <<-HERE.unindent
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

      _against <<-HERE.unindent
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

    def _against s

      _st = Home_.lib_.basic::String.line_stream s

      @st = Subject_[]::Models_::Command.unmarshalling_stream _st, :OGDL

      NIL_
    end
  end
end
