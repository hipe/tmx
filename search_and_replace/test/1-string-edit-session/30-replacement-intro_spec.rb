require_relative '../test-support'

module Skylab::SearchAndReplace::TestSupport

  describe "[sa] magnetics - replacement intro" do

    TS_[ self ]
    use :memoizer_methods
    use :SES_replacement

    context "minimal performance" do

      given do
        str 'a'
        rx %r(a)
      end

      def apply_some_replacements_ es

        _mc = _Nth_match_controller 0, es
        _ = _mc.engage_replacement_via_string 'b'
        _ and fail  # assert that there is no result
      end

      it "one line" do
        number_of_lines_after_engaging_replacement_ == 1 or fail
      end

      it "atoms" do

        expect_atoms_after_having_replaced_for_Nth_line_ 0

        expect_atoms_ :match, 0, :repl, :content, "b"

        end_expect_atoms_
      end
    end

    context "replace the first of two." do

      given do
        str "GAK and GAK\n"
        rx %r(\bgak\b)i
      end

      def apply_some_replacements_ es
        _mc = _Nth_match_controller 0, es
        _ = _mc.engage_replacement_via_string 'wak'
        _ and fail  # assert that there is no result
      end

      it "one line" do
        number_of_lines_after_engaging_replacement_ == 1 or fail
      end

      it "atoms" do

        expect_atoms_after_having_replaced_for_Nth_line_ 0

        expect_atoms_ :match, 0, :repl, :content, 'wak'
        expect_atoms_ :static, :content, ' and '
        expect_atoms_ :match, 1, :orig, :content, 'GAK'
        expect_atoms_ :static, :LTS_begin, "\n", :LTS_end
        end_expect_atoms_
      end
    end
  end
end
