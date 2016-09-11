require_relative '../../test-support'

module Skylab::Basic::TestSupport

  describe "[ba] string - small procs - core" do

    context "(paragraph string via message lines)" do

      it "two plain strings" do

        _against 'A', 'B'
        _expect "A.\nB."
      end

      it "one string with newline (chomps original string)" do

        orig = "A\n"
        _against orig
        _expect "A"
        "A" == orig or fail
      end

      def _against * a

        @_actual =  Home_::String::Small_Procs__::
          Paragraph_string_via_message_lines[ a ]
        NIL_
      end

      def _expect exp_s
        @_actual == exp_s or fail
      end
    end
  end
end
