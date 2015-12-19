require_relative '../../../../../test-support'

module Skylab::BeautySalon::TestSupport

  describe "[bs] models - S & R - models - string edit session", wip: true do

    extend TS_
    use :models_search_and_replace_actors_build_file_scan_support

    context "modeled as a list of string segments separated by match segments" do

      it "the match segements are determined lazily" do
        es = _subject '__XX__XX__', /XX/
        m1 = es.gets_match
        m2 = es.gets_match
        es.gets_match.should be_nil
        m1.begin.should eql 2
        m1.next_begin.should eql 4
        m2.begin.should eql 6
        m2.next_begin.should eql 8
      end

      it "a match segment can retrieve its previous, its next" do

        es = _subject 'Fibble..XX..and faBBle, and Fopple and falafel fubbel',
          /\bf[a-z][bp]{2}(?:el|le)\b/i

        ma = es.match_at_index 1
        ma.md[ 0 ].should eql 'faBBle'

        ma_ = ma.previous_match
        ma_.md[ 0 ].should eql 'Fibble'

        ma__ = ma.next_match
        ma__.md[ 0 ].should eql 'Fopple'

        ma__.next_match.next_match.should be_nil

        ma_.previous_match.should be_nil

      end

      it "no matches is OK" do
        es = _subject 'one', /two/
        es.match_at_index( 3 ).should be_nil
      end

      it "empty string is OK (but don't bother trying to match it)" do
        es = _subject '', //
        es.gets_match.should be_nil
      end
    end

    context "replacements, context & output lines" do

      it "in repl string you can add lines that weren't there and opposite" do

        _input = unindent_( <<-O )
          one
          two
          three
        O
        es = _subject _input, /(?:thre)?e\n/

        m1 = es.gets_match
        m2 = es.gets_match

        m1.set_replacement_string "iguruma\nand PCRE are\n"
        m2.set_replacement_string "rx engines"

        stream = es.to_line_stream
        stream.gets.should eql "oniguruma\n"
        stream.gets.should eql "and PCRE are\n"
        stream.gets.should eql "two\n"
        stream.gets.should eql "rx engines"
        stream.gets.should be_nil
      end

      it "viewing context - minimal normal (note \"segmented line\" class)" do

        _input = unindent_( <<-O )
          line 1
          line 2
          ohai
          line 4
          line 5
        O
        es = _subject _input, /^ohai$/
        es.gets_match.set_replacement_string 'yerp'

        bf, m, af = es.context_streams 1, 0, 1

        line = bf.gets
        line.length.should eql 1
        line.first.string_index.should eql 7
        bf.gets.should be_nil

        line = m.gets
        line.length.should eql 2
        line.first.string.should eql 'yerp'
        line.last.string.should eql DELIMITER_
        line.first.category.should eql :replacement
        line.last.category.should eql :normal
        m.gets.should be_nil

        line = af.gets
        line.length.should eql 1
        line.first.to_sexp.should eql [ :normal, 19, "line 4\n" ]
        af.gets.should be_nil

        _expect_output es, unindent_( <<-O )
          line 1
          line 2
          yerp
          line 4
          line 5
        O
      end

      it "viewing context - many matches, many replacements, delimitation changed" do

        _input = unindent_( <<-O )
          zero_then
          one_and
          two_and
          three_and
          four
        O

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

        _expect_output es, unindent_( <<-O )
          zero_then
          one
          AND
          two_2_and
          three
          AND
          four
        O
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

        _expect_output es, unindent_( <<-O )
          zip nourk 1
          nourk 2
          nourk 3 zip
          zap nelf 1
          nelf 2
          nelf 3 zap
        O
      end

      it "(regression)" do

        _input = unindent_( <<-O )
          ZE zoo
          ZIM
        O
        es = _subject _input, /\bZ[A-Z]+\b/

        es.gets_match.set_replacement_string 'JE'
        es.gets_match.set_replacement_string 'JIM'

        bf, m, af = es.context_streams 2, 1, 2
        bf.gets.to_flat_sexp.should eql [ :replacement, 0, 0, "JE", :normal, 2, " zoo\n" ]
        bf.gets.should be_nil
        m.gets.to_flat_sexp.should eql [ :replacement, 1, 0, "JIM", :normal, 10, "\n" ]
        m.gets.should be_nil
        af.gets.should be_nil

        _expect_output es, unindent_( <<-O )
          JE zoo
          JIM
        O
      end

      it "viewing context - when many matches on 1 line & actual ctx is low" do

        _input = unindent_( <<-O )
          zo ZE zoo
          ZIM zam ZOM
          ziff ZUP zaff
        O
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

        _expect_output es, unindent_( <<-O )
          zo JE zoo
          JIM zam JOM
          ziff JUP zaff
        O
      end
    end

    def _subject * a
      actors_::Build_file_scan::Models__::Interactive_File_Session::String_Edit_Session_.new( * a )
    end

    def _expect_output es, string
      queue = string.split %r((?<=\n))
      stream = es.to_line_stream
      while line = stream.gets
        expect = queue.shift
        if expect
          if line != expect
            line.should eql expect
            fail "skipping the remaining lines."
          end
        else
          fail "unexpected line: #{ line.inspect }"
        end
      end
      if queue.length.nonzero?
        fail "had no more lines, expecting #{ queue.first.inspect }"
      end
    end
  end
end
