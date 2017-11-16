require_relative '../../test-support'

module Skylab::Human::TestSupport

  describe "[hu] magnetics - list via c.agg. - intro" do

    TS_[ self ]
    use :memoizer_methods
    use :magnetics_list_via_columnar_aggregation

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

      it "builds" do  # :#cov1.6
        subject
      end

      it "with zero frames, zero output" do
        want_no_more_lines
      end

      it "with one frame, pass-thru" do
        push 'fee', 'foo'
        want_line 'fee likes foo'
        want_no_more_lines
      end

      it "with completely different frames - pass thru" do
        push "sara", "soup"
        push "kyle", "kale"
        want_line "sara likes soup"
        want_line "kyle likes kale"
        want_no_more_lines
      end

      it "with two identical frames - LOOK by default repeated lines are swallowed" do
        push "sara", "soup"
        push "sara", "soup"
        want_line 'sara likes soup'
        want_no_more_lines
      end

      it "with frames same on the first field - acknowledging redundancy" do
        push "sara", "soup"
        push "sara", "kale"
        want_line "sara likes soup"
        want_line "sara also likes kale"
        want_no_more_lines
      end

      it "frame same on second - because the adverb wants to be close to the invariant field" do
        push "sara", "soup"
        push "kyle", "soup"
        want_line "sara likes soup"
        want_line "kyle likes soup as well"
        want_no_more_lines
      end

      it "counts will be remembered even when values are not contiguous" do
        push_symbols :X, :Y
        push_symbols :P, :Q
        push_symbols :X, :Z
        want_line "X likes Y"
        want_line "P likes Q"
        want_line "X also likes Z"
        want_no_more_lines
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
        want_line 'the server was pinged'
        want_line 'the server was pinged again'
      end

      it "three times" do
        push_symbols :A, :B
        push_symbols :A, :B
        push_symbols :A, :B
        want_line 'AB'
        want_line 'AB again'
        want_line 'AB again'
        want_no_more_lines
      end

      it "strange things in between" do
        push_symbols :A, :B
        push_symbols :G, :Q
        push_symbols :A, :B
        push_symbols :G, :Q
        want_line 'AB'
        want_line 'GQ'
        want_line 'AB again'
        want_line 'GQ again'
        want_no_more_lines
      end

      it "ALSO field-level redundancy acknowledgement is still activated" do
        push 'the server', ' was pinged'
        push 'sally', ' did a little dance'
        push 'jim', ' did a little dance'
        push 'the server', ' was pinged'
        want_line 'the server was pinged'
        want_line 'sally did a little dance'
        want_line 'jim did a little dance too'
        want_line 'the server was pinged again'
        want_no_more_lines
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
        want_no_more_lines
      end

      it "with only one input frame, pass-thru" do
        with [ :np, 'jack', :vp, ' jumped' ]
        want_line 'jack jumped'
        want_no_more_lines
      end

      it "exemplary" do
        with [ :np, 'jack', :vp, ' went up the hill' ],
             [ :np, 'jill', :vp, ' went up the hill' ]
        want_line 'jack and jill went up the hill'
        want_no_more_lines
      end

      it "three frames" do
        push_mixed :A, ' wahoo'
        push_mixed :B, ' wahoo'
        push_mixed :C, ' wahoo'
        want_line "A and B and C wahoo"
        want_no_more_lines
      end

      it "three frames third dissimilar" do
        push_mixed :A, 1
        push_mixed :B, 1
        push_mixed :C, 2
        want_line 'A and B1'
        want_line 'C2'
        want_no_more_lines
      end

      it "when the non-repeating field does not have an aggregator" do
        push_mixed :A, 1
        push_mixed :A, 2
        want_line 'A1'
        want_line 'A2'
        want_no_more_lines
      end
    end
  end
end
