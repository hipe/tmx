require_relative '../../../../test-support'

module Skylab::Human::TestSupport

  describe "[hu] NLP en expression-frames - O & S (cross-product)" do

    extend TS_
    use :nlp_en_expression_frame_support

    if false  # the mentor-case, here for refernce:

      # before:

      y << "#{ and_ a } #{ s a, :does } not match any subsystem#{ s a }."

      # after:

      _etc( :subject, a, :verb, 'match', :negative, :object, 'subsystem' )
    end

    #  [td] permute  --polarity negative -ppositive \
    #    --count none -cone -ctwo -cthree

    context "(main context)" do

      it "negative, none" do
        _a false, 0
        e_ "nothing matches a subsystem"
      end

      it "positive, none" do
        _a true, 0
        e_ "nothing matches a subsystem"
      end

      it "negative, one" do
        _a false, 1, :object, EMPTY_A_
        e_ "x does not match any subsystem"
      end

      it "positive, one" do
        _a true, 1
        e_ "x matches a subsystem"
      end

      it "negative, two" do
        _a false, 2
        e_ "x and y do not match any subsystems"
      end

      it "positive, two" do
        _a true, 2
        e_ "x and y match subsystems"
      end

      it "negative, three" do
        _a false, 3
        e_ "x, y and z do not match any subsystems"
      end

      it "positive, three" do
        _a true, 3
        e_ "x, y and z match subsystems"
      end
    end

    def _a yes_positive, num, * x_a

      x_a.concat _same

      x_a.push :subject, _ary[ 0, num ]

      if ! yes_positive
        x_a.push :negative
      end

      @the_iambic_for_the_request_ = x_a

      NIL_
    end

    memoize_ :_ary do
      [ 'x', 'y', 'z' ].freeze
    end

    memoize_ :_same do
      [ :verb, 'match',
        :object, 'subsystem' ]
    end

    def frame_module_
      Hu_::NLP::EN::Expression_Frames___::Object_and_Subject
    end
  end
end
