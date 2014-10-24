require_relative '../test-support'

module Skylab::Basic::TestSupport::Numeric

  ::Skylab::Basic::TestSupport[ TS_ = self ]

  include Constants

  extend TestSupport_::Quickie

  describe "[br] number normalization" do

    TestLib_::Expect_event[ self ]

    TestLib_::Expect_normalization[ self ]

    extend TS_

    it "loads" do
      subject
    end

    context "the normalizer with no args" do

      before :all do
        With_Nothing = Subject_[].build_via_iambic Basic_::EMPTY_A_
      end

      it "builds" do
      end

      it "with an evr againt an integer-looking string" do
        use_event_receiver_against '123'
        output_value_was_written
        @output_x.should eql 123
        @result_x.should eql :happy
        expect_no_events
      end

      it "with an evr against a non-integer looking string" do
        use_event_receiver_against 'A'
        output_value_was_not_written
        @result_x.should eql false
        expect_not_OK_event expected_terminal_channel,
          '(par «your_value») must be (indefinite_noun "integer"), had (ick "A")'
        expect_no_more_events
      end

      it "with a proc evr against an integer-looking string" do
        use_event_proc_against '456'
        output_value_was_written
        event_proc_was_not_called
        @output_x.should eql 456
        @result_x.should eql :happy
      end

      it "with a proc evr against a non-integer looking string" do
        use_event_proc_against 'A'
        output_value_was_not_written
        @result_x.should eql :sad_from_proc
        ( 4..12 ).should be_include @event_x_a.length
        @event_x_a.first.should eql expected_terminal_channel
        @event_x_a.last.arity.should eql 2  # msg proc
      end

      it "against a float" do
        use_event_receiver_against 1.23
        output_value_was_not_written
        expect_not_OK_event expected_terminal_channel
        @result_x.should eql false
      end

      def subject
        With_Nothing
      end
    end

    context "the normalizer with a minimum" do

      before :all do
        Min = Subject_[].build_with :minimum, -3
      end

      it "when input is below minimum (string)" do
        use_event_receiver_against '-4'
        expect_result_for_input_was_below_minimum
      end

      it "when input is below minimum (int)" do
        use_event_receiver_against( -4 )
        expect_result_for_input_was_below_minimum
      end

      def expect_result_for_input_was_below_minimum
        output_value_was_not_written
        @result_x.should eql false
        expect_not_OK_event :number_too_small,
          "(par «your_value») must be greater than or equal to (val -3), #{
            }had (ick -4)" do |ev|
          ev.error_category.should eql :argument_error
        end
        expect_no_more_events
      end

      it "when input is at minimum it is OK" do
        use_event_receiver_against '-3'
        output_value_was_written
        @output_x.should eql( -3 )
        expect_no_events
      end

      it "when input is above minimum OK too" do
        use_event_proc_against( -2 )
        output_value_was_written
        event_proc_was_not_called
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
        Subject_[].build_via_iambic x_a
      end
    end

    def expected_terminal_channel
      :value_not_in_number_set
    end

    Subject_ = -> do
      Basic_::Number.normalization
    end
  end
end
