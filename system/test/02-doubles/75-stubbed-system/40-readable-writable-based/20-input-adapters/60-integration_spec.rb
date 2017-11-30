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
      expect( co.argv ).to eql [ 'echo', "it's", "\"fun\"" ]
      expect( co.stdout_string ).to eql "it's \"fun\"\n"
      expect( co.stderr_string ).to be_nil
      expect( co.exitstatus ).to be_zero

      expect( @st.gets ).to be_nil
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
      expect( co.argv ).to eql %w( one two )
      expect( co.stdout_string ).to eql "\n"

      co = @st.gets
      expect( co.argv ).to eql [ 'three' ]
      expect( co.exitstatus ).to eql 15

      expect( @st.gets ).to be_nil
    end

    def _against s

      _st = Basic_[]::String::LineStream_via_String[ s ]

      @st = popen3_result_for_RW_.unmarshalling_stream _st, :OGDL

      NIL_
    end
  end
end
