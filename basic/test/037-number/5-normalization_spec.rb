require_relative '../test-support'

module Skylab::Basic::TestSupport

  describe "[ba] number normalization" do

    TS_[ self ]
    use :memoizer_methods
    use :expect_event
    use :expect_normalization

    it "loads" do
      _subject_module
    end

    context "the normalizer with no args" do

      shared_subject :subject_normalization_ do
        _subject_module.new_via_arglist Home_::EMPTY_A_
      end

      it "builds" do
        subject_normalization_
      end

      it "againt an integer-looking string" do
        normalize_against_ '123'
        expect_output_value_was_written_
        @output_x.should eql 123
        expect_no_events
      end

      it "against a non-integer looking string" do
        normalize_against_ 'A'
        expect_output_value_was_not_written_
        @result_x.should eql false
        expect_not_OK_event_ expected_terminal_channel,
          '(par «your_value») must be (indefinite_noun "integer"), had (ick "A")'
        expect_no_more_events
      end

      it "against a float" do
        normalize_against_ 1.23
        expect_output_value_was_not_written_
        expect_not_OK_event_ expected_terminal_channel
        @result_x.should eql false
      end
    end

    context "the normalizer with a minimum" do

      shared_subject :subject_normalization_ do
        _subject_module.new_with :minimum, -3
      end

      it "when input is below minimum (string)" do
        normalize_against_ '-4'
        expect_result_for_input_was_below_minimum
      end

      it "when input is below minimum (int)" do
        normalize_against_( -4 )
        expect_result_for_input_was_below_minimum
      end

      def expect_result_for_input_was_below_minimum
        expect_output_value_was_not_written_
        @result_x.should eql false
        expect_not_OK_event_ :number_too_small,
          "(par «your_value») must be greater than or equal to (val -3), #{
            }had (ick -4)" do |ev|
          ev.error_category.should eql :argument_error
        end
        expect_no_more_events
      end

      it "when input is at minimum it is OK" do
        normalize_against_ '-3'
        expect_output_value_was_written_
        @output_x.should eql( -3 )
        expect_no_events
      end

      it "when input is above minimum OK too" do

        normalize_against_( -2 )
        expect_output_value_was_written_
        expect_no_events
        @output_x.should eql( -2 )
      end
    end

    def expected_terminal_channel
      :uninterpretable_under_number_set
    end

    def _subject_module
      Home_::Number.normalization
    end
  end
end
