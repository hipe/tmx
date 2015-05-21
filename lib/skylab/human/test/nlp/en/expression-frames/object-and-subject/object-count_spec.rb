require_relative '../../../../test-support'

module Skylab::Human::TestSupport

  describe "[hu] NLP en expression-frames - O & S (object count)" do

    extend TS_
    use :nlp_en_expression_frame_support

    # [td] permute --x "more is expected" -x "(no expectation)"
    # --polarity negative -ppositive --count 0 -c1 -c2 -c3

    # the focus of this production plan is around how count is expressed
    # variously when it exceeds or falls short of an expected quantity
    # (if any such expectation exists), in concert with expression of the
    # rest of the received information.
    #
    # (then we removed the notion of `less_is_expected` as an input, because
    # it seems that it doesn't receive interesting surface expression
    # in our self-produced "natural" examples we made as targets.)
    #
    # there is a received subject (with modifiers as well as quantity)
    # and a predicate which in turn has an object with modifiers.
    #
    # the received predicate (with children) will be skipped under a
    # certain circumstance explained in an inline comment below.
    #
    # the received predicate (when expressed) must be expressed as
    # informational rather than being expressed as a qualifier.
    # we want:
    #
    #     "the three people at this party are not wearing hats"
    #
    # we do not want:
    #
    #     "there are three people at this party who are not wearing hats"
    #
    # the former is the sort of construction we are after. the latter
    # expresses this "qualifier" dynamic that we are defining as an
    # incorrect production here.
    #
    # the former associates two distinct pieces of information with a
    # class of thing: of the people at this party,
    #
    #   1) their quantity is three
    #   2) they are not wearing hats
    #
    # whereas in the latter, the "class of thing" is different. in the
    # latter, the total number of people at the party is not expressed.
    #
    # as well we get into the pronoun needing to agree with the antecedent
    # it modifies ..

    context "(main context)" do

      it "(no expectation), negative, 0" do
        _a false, 0
        _common_0
      end

      it "more is expected, negative, 0" do
        _a false, 0, :more_is_expected
        _common_0
      end

      it "(no expectation), positive, 0" do
        _a true, 0
        _common_0
      end

      it "more is expected, positive, 0" do
        _a true, 0, :more_is_expected
        _common_0
      end

      def _common_0

        e_ "there are no found items"

        # always we skip the predicate when there are no items. to do
        # otherwise makes the sentence awkward, ambiguous, misleading
        # or incorrect.

        # let's consider the anti-example from a variety of angles:
        #
        #     !"the 0 found items have no content after them"
        #
        # in real life pragmatics it may be that we are never actually
        # saying that nothing does something. rather, we do so only
        # as a "deep idiom", or construction of its own:
        #
        #     "nobody punched me in the face"
        #     !"you got punched in the face!? are ok alright?"
        #
        # the first sentence *means* that there is the absence of an
        # actor that did this thing. it is not the case that a punch in
        # the face happened. rather, the "nothing actor" is a shorthand
        # for this negation.
        #
        # this seems to be the definite article that ..

      end

      # ~

      it "(no expectation), negative, 1" do
        _a false, 1
        e_ "the 1 found item does not have any content after it"
      end

      it "more is expected, negative, 1" do
        _a false, 1, :more_is_expected
        e_ "the only found item has no content after it"
      end

      it "(no expectation), positive, 1" do
        _a true, 1
        e_ "the 1 found item has content after it"
      end

      it "more is expected, positive, 1" do
        _a true, 1, :more_is_expected
        e_ "the only found item has content after it"
      end

      # ~

      it "(no expectation), negative, 2" do
        _a false, 2
        e_ "the 2 found items have no content after them"
      end

      it "more is expected, negative, 2" do
        _a false, 2, :more_is_expected
        e_ "of the 2 found items, neither of them have content after them"
      end

      it "(no expectation), positive, 2" do
        _a true, 2
        e_"the 2 found items have content after them"
      end

      it "more is expected, positive, 2" do
        _a true, 2, :more_is_expected
        e_ "the only 2 found items have content after them"
      end

      # `less_is_expected`: "both of the.." , "all 3 of the.." etc

      # ~

      it "(no expectation), negative, 3" do
        _a false, 3
        e_ "the 3 found items have no content after them"
      end

      it "more is expected, negative, 3" do
        _a false, 3, :more_is_expected
        e_ "of the 3 found items, none of them have content after them"
      end

      it "(no expectation), positive, 3" do
        _a true, 3
        e_ "the 3 found items have content after them"
      end

      it "more is expected, positive, 3" do
        _a true, 3, :more_is_expected
        e_ "the only 3 found items have content after them"
      end
    end

    def _a yes_positive, num, * x_a

      x_a.concat _same

      x_a.push :subject, num

      if ! yes_positive
        x_a.push :negative
      end

      @the_iambic_for_the_request_ = x_a

      NIL_
    end

    memoize_ :_same do
      [
        :subject, 'found item',
        :verb, 'have',
        :object, 'content after it'
      ]
    end

    def frame_module_
      Hu_::NLP::EN::Expression_Frames___::Object_and_Subject
    end
  end
end
