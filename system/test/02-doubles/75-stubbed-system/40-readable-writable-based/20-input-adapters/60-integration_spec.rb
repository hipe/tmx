require_relative '../../../../test-support'

module Skylab::System::TestSupport

  describe "[sy] doubles - stubbed-system - 02: input-adapters" do

    TS_[ self ]
    use :doubles_stubbed_system

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

      _st = Basic_[]::String::LineStream_via_String[ s ]

      @st = popen3_result_for_RW_.unmarshalling_stream _st, :OGDL

      NIL_
    end
  end
end
