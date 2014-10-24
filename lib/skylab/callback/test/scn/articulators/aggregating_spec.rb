require_relative 'aggregating/test-support'

module Skylab::Callback::TestSupport::Scn::Articulators::Aggregating

  describe "[cb] scn articulators - aggregating" do

    extend TS_

    context "handling field-level repetition by redundancy acknowledgement" do

      before :all do

        Min_Count = Subject_.call(

          :template, "{{ noun }} likes {{ obj }}",

          :noun, :on_subsequent_mentions, -> y, x do
            y << "#{ x } also"
          end,

          :obj, :on_subsequent_mentions, -> y, x do
            y << "#{ x } as well"
          end )

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
        push :X, :Y
        push :P, :Q
        push :X, :Z
        expect_line "X likes Y"
        expect_line "P likes Q"
        expect_line "X also likes Z"
        expect_no_more_lines
      end

      def subject
        Min_Count
      end
    end

    context "handling frame-level repetition by redundancy acknowledgement" do

      before :all do

        Frame_Redundancy = Subject_.call(

          :template, "{{ np }}{{ vp }}{{ adv }}",

          :np, :on_subsequent_mentions, -> y, x do
            y << "#{ x } also"
          end,

          :vp, :on_subsequent_mentions, -> y, x do
            y << "#{ x } too"
          end,

          :adv, :on_subsequent_mentions_of, :frame, -> y, x do
            y << " again"
          end )
      end

      it "works - note that field-level redundancy handlers are not used" do
        push 'the server', ' was pinged'
        push 'the server', ' was pinged'
        expect_line 'the server was pinged'
        expect_line 'the server was pinged again'
      end

      it "three times" do
        push :A, :B
        push :A, :B
        push :A, :B
        expect_line 'AB'
        expect_line 'AB again'
        expect_line 'AB again'
        expect_no_more_lines
      end

      it "strange things in between" do
        push :A, :B
        push :G, :Q
        push :A, :B
        push :G, :Q
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

      def subject
        Frame_Redundancy
      end
    end

    context "introduction to nested aggregation" do

      before :all do

        J_and_J = Subject_.call(

          :template, "{{ np }}{{ vp }}",

          :np, :aggregate, -> y, a do
            y << ( a * ' and ' )
          end )

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
        push :A, ' wahoo'
        push :B, ' wahoo'
        push :C, ' wahoo'
        expect_line "A and B and C wahoo"
        expect_no_more_lines
      end

      it "three frames third dissimilar" do
        push :A, 1
        push :B, 1
        push :C, 2
        expect_line 'A and B1'
        expect_line 'C2'
        expect_no_more_lines
      end

      it "when the non-repeating field does not have an aggregator" do
        push :A, 1
        push :A, 2
        expect_line 'A1'
        expect_line 'A2'
        expect_no_more_lines
      end

      def subject
        J_and_J
      end
    end
  end
end
