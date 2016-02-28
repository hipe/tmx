require_relative '../../../test-support'

module Skylab::Human::TestSupport

  describe "[hu] NLP en expression-frames - object (list) and subject" do

    extend TS_
    use :NLP_EN_expression_frame_support

    if false  #  the mentor case, here for reference:

      y << "html-escaping support is currently very limited. the following #{
       }character#{ s d } #{ s d, :is } not yet supported: #{ _s_a_ }"
    end

    # the virgin voyage of [#ts-045] permute. the constituencies and
    # description heads of all of the below cases were produced with:
    #
    #     [td] permute  --future future -f "no future" --polarity negative \
    #       -ppositive --count none -cone -ctwo -cthree [ this file ]

    context "no items" do

      it "future, negative, none - no double negative" do

        _a true, false
        e_ "no characters are supported yet"
      end

      it "no future, negative, none - no double negative" do

        _a false, false
        e_ "no characters are supported"
      end

      it "future, positive, none" do

        _a true, true
        e_ "no characters are supported yet"
      end

      it "no future, positive, none" do

        _a false, true
        e_ "no characters are supported"
      end

      def _ary
        EMPTY_A_
      end
    end

    context "one item" do

      it "future, negative, one" do

        _a true, false
        e_ "the x character is not yet supported"
      end

      it "no future, negative, one" do

        _a false, false
        e_ "the x character is not supported"
      end

      it "future, positive, one" do

        _a true, true
        e_ "the x character is already supported"
      end

      it "no future, positive, one" do

        _a false, true
        e_ "the x character is supported"
      end

      memoize_ :_ary do
        %w( x )
      end
    end

    context "two items" do

      it "future, negative, two" do

        _a true, false
        e_ "the x and y characters are not yet supported"
      end

      it "no future, negative, two" do

        _a false, false
        e_ "the x and y characters are not supported"
      end

      it "future, positive, two" do

        _a true, true
        e_ "the x and y characters are already supported"
      end

      it "no future, positive, two" do

        _a false, true
        e_ "the x and y characters are supported"
      end

      memoize_ :_ary do
        %w( x y )
      end
    end

    context "three items" do

      it "future, negative, three" do

        _a true, false
        e_ "the following characters are not yet supported: a, b and c"
      end

      it "no future, negative, three" do

        _a false, false
        e_ "the following characters are not supported: a, b and c"
      end

      it "future, positive, three" do

        _a true, true
        e_ "the following characters are already supported: a, b and c"
      end

      it "no future, positive, three" do

        _a false, true
        e_ "the following characters are supported: a, b and c"
      end

      memoize_ :_ary do
        %w( a b c )
      end
    end

    def _a yes_future, yes_positive  # "a_" = "against_"

      a = _same.dup
      a.push :subject, _ary

      if yes_future
        a.push :later_is_expected
      end

      if ! yes_positive
        a.push :negative
      end

      @the_iambic_for_the_request_ = a

      NIL_
    end

    memoize_ :_same do

      [ :object, :adjectivial, 'supported',
        :subject, 'character',
      ].freeze
    end

    def frame_module_
      Home_::NLP::EN::Expression_Frames___::Object_and_Subject
    end
  end
end
