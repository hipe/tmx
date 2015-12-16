require_relative '../test-support'

module Skylab::Basic::TestSupport::Numeric

  ::Skylab::Basic::TestSupport[ TS_ = self ]

  include Constants

  extend TestSupport_::Quickie

  describe "[ba] number normalization" do

    extend TS_
    use :expect_event
    use :expect_normalization

    it "loads" do
      subject
    end

    context "the normalizer with no args" do

      before :all do
        With_Nothing = Subject_[].new_via_arglist Home_::EMPTY_A_
      end

      it "builds" do
      end

      it "againt an integer-looking string" do
        normalize_against '123'
        output_value_was_written
        @output_x.should eql 123
        expect_no_events
      end

      it "against a non-integer looking string" do
        normalize_against 'A'
        output_value_was_not_written
        @result_x.should eql false
        expect_not_OK_event_ expected_terminal_channel,
          '(par «your_value») must be (indefinite_noun "integer"), had (ick "A")'
        expect_no_more_events
      end

      it "against a float" do
        normalize_against 1.23
        output_value_was_not_written
        expect_not_OK_event_ expected_terminal_channel
        @result_x.should eql false
      end

      def subject
        With_Nothing
      end
    end

    context "the normalizer with a minimum" do

      before :all do
        Min = Subject_[].new_with :minimum, -3
      end

      it "when input is below minimum (string)" do
        normalize_against '-4'
        expect_result_for_input_was_below_minimum
      end

      it "when input is below minimum (int)" do
        normalize_against( -4 )
        expect_result_for_input_was_below_minimum
      end

      def expect_result_for_input_was_below_minimum
        output_value_was_not_written
        @result_x.should eql false
        expect_not_OK_event_ :number_too_small,
          "(par «your_value») must be greater than or equal to (val -3), #{
            }had (ick -4)" do |ev|
          ev.error_category.should eql :argument_error
        end
        expect_no_more_events
      end

      it "when input is at minimum it is OK" do
        normalize_against '-3'
        output_value_was_written
        @output_x.should eql( -3 )
        expect_no_events
      end

      it "when input is above minimum OK too" do

        normalize_against( -2 )
        output_value_was_written
        expect_no_events
        @output_x.should eql( -2 )
      end

      def subject
        Min
      end
    end

    def subject * x_a
      if x_a.length.zero?
        Subject_[]
      else
        Subject_[].new_via_arglist x_a
      end
    end

    def expected_terminal_channel
      :uninterpretable_under_number_set
    end

    Subject_ = -> do
      Home_::Number.normalization
    end
  end
end
