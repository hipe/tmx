require_relative '../test-support'

module Skylab::SearchAndReplace::TestSupport

  describe "[sa] magnetics - replacement adds lines" do

    TS_[ self ]
    use :memoizer_methods
    use :SES_replacement

    # - performance

    context "in repl string you can add lines that weren't there and opposite" do

      given do
        str unindent_ <<-HERE
          one
          two
          three
        HERE

        rx %r((?:thre)?e\n)
      end

      def apply_some_replacements_ es

        _mc1 = es.first_match_controller
        _mc2 = _mc1.next_match_controller

        _mc1.engage_replacement_via_string "iguruma\nand PCRE are\n"
        _mc2.engage_replacement_via_string "rx engines"
      end

      it "four lines in new document" do
        number_of_lines_after_engaging_replacement_ == 4 or fail
      end

      _NL = [ :LTS_begin, "\n", :LTS_end ]

      it "first" do

        expect_atoms_after_having_replaced_for_Nth_line_ 0

        expect_atoms_ :static, :content, "on"
        expect_atoms_ :match, 0, :repl, :content, "iguruma", * _NL
      end

      it "second line is from the first replacement" do

        expect_atoms_after_having_replaced_for_Nth_line_ 1
        expect_last_atoms_ :content, "and PCRE are", * _NL
      end

      it "third is same as orig" do

        expect_atoms_after_having_replaced_for_Nth_line_ 2
        expect_last_atoms_ :static, :content, "two", * _NL
      end

      it "fourth is second replacement" do

        expect_atoms_after_having_replaced_for_Nth_line_ 3
        expect_last_atoms_ :match, 1, :repl, :content, "rx engines"
      end
    end
  end
end
