require_relative '../../../test-support'

module Skylab::System::TestSupport

  describe "[sy] doubles - stubbed-system - recording session (#LIVE)" do

    TS_[ self ]
    use :want_line
    use :doubles_stubbed_system

    it "works" do

      io = new_string_IO_

      x = subject_.recording_session io do | sess |

        i, o, e, t = sess.popen3 'echo', "it's", '"fun"'

        expect( i ).to be_nil
        expect( o.gets ).to eql "it's \"fun\"\n"
        expect( o.gets ).to be_nil

        expect( e.gets ).to be_nil
        expect( t.value.exitstatus ).to be_zero

        _, o, e, t = sess.popen3 'date'

        expect( ( 25 .. 35 ) ).to be_include o.gets.length
        expect( o.gets ).to be_nil

        expect( e.gets ).to be_nil
        expect( t.value.exitstatus ).to be_zero
      end

      expect( x ).to eql true
      io.close

      @output_s = io.string

      expect( excerpt( 0..7 ) ).to eql <<-HERE.unindent
        command
          argv
            echo, "it's", "\\"fun\\""
          stdout_string
            "it's \\"fun\\"
            "
          stderr_string ""
          exitstatus 0
      HERE

      expect( excerpt_lines( 10..10 ).first ).to eql "  argv date\n"
    end
  end
end
