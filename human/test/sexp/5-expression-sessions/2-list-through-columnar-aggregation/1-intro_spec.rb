require_relative '../../../test-support'

module Skylab::Human::TestSupport

  describe "[hu] sexp - expression sessions - list thru c.agg. - intro" do

    TS_Joist_[ self ]
    use :memoizer_methods
    use :sexp_expression_sessions_list_through_columnar_aggregation

    context "handling field-level repetition by redundancy acknowledgement" do

      dangerous_memoize :subject do

        su = subject_call_(

          :template, "{{ noun }} likes {{ obj }}",

          :noun, :on_subsequent_mentions, -> y, x do
            y << "#{ x } also"
          end,

          :obj, :on_subsequent_mentions, -> y, x do
            y << "#{ x } as well"
          end,
        )
        SESLtA_Min_Count = su
        su
      end

      it "builds" do
        subject
      end

      it "with zero frames, zero output" do
        expect_no_more_lines
      end

      it "with one frame, pass-thru" do
        push 'fee', 'foo'
        expect_line 'fee likes foo'
        expect_no_more_lines
      end

      it "with completely different frames - pass thru" do
        push "sara", "soup"
        push "kyle", "kale"
        expect_line "sara likes soup"
        expect_line "kyle likes kale"
        expect_no_more_lines
      end

      it "with two identical frames - LOOK by default repeated lines are swallowed" do
        push "sara", "soup"
        push "sara", "soup"
        expect_line 'sara likes soup'
        expect_no_more_lines
      end

      it "with frames same on the first field - acknowledging redundancy" do
        push "sara", "soup"
        push "sara", "kale"
        expect_line "sara likes soup"
        expect_line "sara also likes kale"
        expect_no_more_lines
      end

      it "frame same on second - because the adverb wants to be close to the invariant field" do
        push "sara", "soup"
        push "kyle", "soup"
        expect_line "sara likes soup"
        expect_line "kyle likes soup as well"
        expect_no_more_lines
      end

      it "counts will be remembered even when values are not contiguous" do
        push_symbols :X, :Y
        push_symbols :P, :Q
        push_symbols :X, :Z
        expect_line "X likes Y"
        expect_line "P likes Q"
        expect_line "X also likes Z"
        expect_no_more_lines
      end
    end

    context "handling frame-level repetition by redundancy acknowledgement" do

      dangerous_memoize :subject do

        su = subject_call_(

          :template, "{{ np }}{{ vp }}{{ adv }}",

          :np, :on_subsequent_mentions, -> y, x do
            y << "#{ x } also"
          end,

          :vp, :on_subsequent_mentions, -> y, x do
            y << "#{ x } too"
          end,

          :adv, :on_subsequent_mentions_of, :frame, -> y, x do
            y << " again"
          end,
        )
        SESLtA_Frame_Redundancy =  su
        su
      end

      it "works - note that field-level redundancy handlers are not used" do
        push 'the server', ' was pinged'
        push 'the server', ' was pinged'
        expect_line 'the server was pinged'
        expect_line 'the server was pinged again'
      end

      it "three times" do
        push_symbols :A, :B
        push_symbols :A, :B
        push_symbols :A, :B
        expect_line 'AB'
        expect_line 'AB again'
        expect_line 'AB again'
        expect_no_more_lines
      end

      it "strange things in between" do
        push_symbols :A, :B
        push_symbols :G, :Q
        push_symbols :A, :B
        push_symbols :G, :Q
        expect_line 'AB'
        expect_line 'GQ'
        expect_line 'AB again'
        expect_line 'GQ again'
        expect_no_more_lines
      end

      it "ALSO field-level redundancy acknowledgement is still activated" do
        push 'the server', ' was pinged'
        push 'sally', ' did a little dance'
        push 'jim', ' did a little dance'
        push 'the server', ' was pinged'
        expect_line 'the server was pinged'
        expect_line 'sally did a little dance'
        expect_line 'jim did a little dance too'
        expect_line 'the server was pinged again'
        expect_no_more_lines
      end
    end

    context "introduction to nested aggregation" do

      dangerous_memoize :subject do

        su = subject_call_(

          :template, "{{ np }}{{ vp }}",

          :np, :aggregate, -> y, a do
            y << ( a * ' and ' )
          end,
        )
        SESLtA_J_and_J = su
        su
      end

      it "with no input frames, yields nil by default" do
        with
        expect_no_more_lines
      end

      it "with only one input frame, pass-thru" do
        with [ :np, 'jack', :vp, ' jumped' ]
        expect_line 'jack jumped'
        expect_no_more_lines
      end

      it "exemplary" do
        with [ :np, 'jack', :vp, ' went up the hill' ],
             [ :np, 'jill', :vp, ' went up the hill' ]
        expect_line 'jack and jill went up the hill'
        expect_no_more_lines
      end

      it "three frames" do
        push_mixed :A, ' wahoo'
        push_mixed :B, ' wahoo'
        push_mixed :C, ' wahoo'
        expect_line "A and B and C wahoo"
        expect_no_more_lines
      end

      it "three frames third dissimilar" do
        push_mixed :A, 1
        push_mixed :B, 1
        push_mixed :C, 2
        expect_line 'A and B1'
        expect_line 'C2'
        expect_no_more_lines
      end

      it "when the non-repeating field does not have an aggregator" do
        push_mixed :A, 1
        push_mixed :A, 2
        expect_line 'A1'
        expect_line 'A2'
        expect_no_more_lines
      end
    end
  end
end
