require_relative '../test-support'

module Skylab::SearchAndReplace::TestSupport

  describe "[sa] magnetics - (42) context challenge (FRAGMENTS)" do

    TS_[ self ]
    use :expect_event

    context "replacements, context & output lines", wip: true do

      it "viewing context - many matches, many replacements, delimitation changed" do

        _input = unindent_( <<-HERE )
          zero_then
          one_and
          two_and
          three_and
          four
        HERE

        es = _subject _input, /_and$/
        es.match_at_index( 0 ).set_replacement_string "\nAND"
        es.match_at_index( 1 ).set_replacement_string "_2_and"
        es.match_at_index( 2 ).set_replacement_string "\nAND"

        bf, m, af = es.context_streams 2, 1, 2

        bf.gets.to_flat_sexp.should eql(
          [ :normal, 10, "one", :replacement, 0, 0, DELIMITER_ ] )

        bf.gets.to_flat_sexp.should eql(
          [ :replacement, 0, 1, "AND", :normal, 17, DELIMITER_ ] )

        bf.gets.should be_nil

        m.gets.to_flat_sexp.should eql(
          [ :normal, 18, "two", :replacement, 1, 0, "_2_and", :normal, 25, DELIMITER_ ] )

        m.gets.should be_nil

        af.gets.to_flat_sexp.should eql(
          [ :normal, 26, "three", :replacement, 2, 0, DELIMITER_ ] )

        af.gets.to_flat_sexp.should eql(
          [ :replacement, 2, 1, "AND", :normal, 35, DELIMITER_ ] )

        af.gets.should be_nil

        _expect_output es, unindent_( <<-HERE )
          zero_then
          one
          AND
          two_2_and
          three
          AND
          four
        HERE
      end

      it "repl has a repl before it, does not start at column 1, adds lines" do

        _input = unindent_( <<-O )
          zip zonk zip
          zap zank zap
        O
        es = _subject _input, /\bz[aeiou]nk\b/i

        es.gets_match.set_replacement_string "nourk 1\nnourk 2\nnourk 3"
        es.gets_match.set_replacement_string "nelf 1\nnelf 2\nnelf 3"
        es.gets_match.should be_nil

        bf, m, af = es.context_streams 2, 1, 3

        bf.gets.to_flat_sexp.should eql(
          [ :replacement, 0, 8, "nourk 2\n" ] )

        bf.gets.to_flat_sexp.should eql(
          [ :replacement, 0, 16, "nourk 3", :normal, 8, " zip\n" ] )

        bf.gets.should be_nil

        m.gets.to_flat_sexp.should eql(
          [ :normal, 13, "zap ", :replacement, 1, 0, "nelf 1\n" ] )

        m.gets.to_flat_sexp.should eql(
          [ :replacement, 1, 7, "nelf 2\n" ] )

        m.gets.to_flat_sexp.should eql(
          [ :replacement, 1, 14, "nelf 3", :normal, 21, " zap\n" ] )

        af.gets.should be_nil

        _expect_output es, unindent_( <<-HERE )
          zip nourk 1
          nourk 2
          nourk 3 zip
          zap nelf 1
          nelf 2
          nelf 3 zap
        HERE
      end

      it "viewing context - when many matches on 1 line & actual ctx is low" do

        _input = unindent_( <<-HERE )
          zo ZE zoo
          ZIM zam ZOM
          ziff ZUP zaff
        HERE
        es = _subject _input, /\bZ[A-Z]+\b/

        es.gets_match.set_replacement_string 'JE'
        es.gets_match.set_replacement_string 'JIM'
        es.gets_match.set_replacement_string 'JOM'
        es.gets_match.set_replacement_string 'JUP'

        es.gets_match.should be_nil

        bf, m, af = es.context_streams 2, 1, 2
        bf.gets.to_flat_sexp.should eql(
          [ :normal, 0, "zo ", :replacement, 0, 0, "JE", :normal, 5, " zoo\n" ] )

        bf.gets.should be_nil

        m.gets.to_flat_sexp.should eql(
          [ :replacement, 1, 0, "JIM",
            :normal, 13, " zam ",
            :replacement, 2, 0, "JOM",
            :normal, 21, "\n" ] )
        m.gets.should be_nil

        af.gets.to_flat_sexp.should eql(
          [ :normal, 22, "ziff ",
            :replacement, 3, 0, "JUP",
            :normal, 30, " zaff\n" ] )

        af.gets.should be_nil

        _expect_output es, unindent_( <<-HERE )
          zo JE zoo
          JIM zam JOM
          ziff JUP zaff
        HERE
      end
    end
  end
end
