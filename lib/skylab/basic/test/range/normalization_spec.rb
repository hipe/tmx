require_relative 'test-support'

module Skylab::Basic::TestSupport::Range::N11n

  Parent_ = ::Skylab::Basic::TestSupport::Range

  Parent_[ TS_ = self ]

  include Constants

  extend TestSupport_::Quickie

  describe "[ba] range normalization" do

    extend TS_
    use :expect_event

    context "inline via 3" do

      it "inline normative - outside left" do
        common_inline_against( -2 )
        expect_common_failure_with_message(
          "'argument' must be between -1 and 2 inclusive. had '-2'" )
      end

      it "inline normative - outside right" do
        common_inline_against 3
        expect_common_failure_with_message %r(inclusive\. had '3'\z)
      end

      it "inline normative - inside" do

        x = nil

        r = subject(
          :begin, -1,
          :end, 2,
          :x, -1,
          :when_normal_value, -> x_ do
            x = x_
            :_seen_
          end,
          :on_event, -> ev do
            fail "should not receive '#{ ev.terminal_channel_i }' here"
          end,
        )

        r.should eql :_seen_
        x.should eql( -1 )
      end

      def common_inline_against x

        @ev = @no_touch = nil

        @r = subject(
          :begin, -1,
          :end, 2,
          :x, x,
          :when_normal_value, -> _x do
            @no_touch = true
            :_never_see_
          end,
          :on_event, -> ev_ do
            @ev = ev_
            :_saw_event_
          end
        )
        NIL_
      end

      def expect_common_failure_with_message x
        @no_touch.should be_nil
        @r.should eql :_saw_event_
        @ev_a = [ @ev ]
        ev = expect_event :actual_property_is_outside_of_formal_property_set
        actual_s = black_and_white ev
        if x.respond_to? :ascii_only?
          actual_s.should eql x
        else
          actual_s.should match x
        end
      end
    end

    context "inline via 2 - when valid, result is value; when invalid event is called" do

      it "inside" do
        ev = nil ; r =
        subject :begin, 1.2, :end, 1.3, :x, 1.3, :on_event, -> ev_ { ev = ev_ }
        ev.should be_nil
        r.should eql 1.3
      end

      it "outside" do
        ev = nil
        r = subject :begin, 1.2, :end, 1.3, :x, 1.11119, :on_event,
          -> ev_ { ev = ev_ ; :_no_ }
        ev.terminal_channel_i.should(
          eql :actual_property_is_outside_of_formal_property_set )
        r.should eql :_no_
      end
    end

    context "inline via 1 - result is the event" do

      it "inside" do
        r = subject :begin, 'B', :end, 'E', :x, 'C'
        r.should be_nil
      end

      it "outside" do
        ev = subject :begin, 'B', :end, 'E', :x, 'A'
        s = black_and_white ev
        s.should match %r(\bmust be between "B" and "E" inclusive\. had 'A')
      end
    end

    context "prepared (\"curried\")" do

      before :all do
        VALID_RANGE = Parent_::Subject_[].normalization.with(
          :begin, 'barbie', :end, 'foobie' )
      end

      context "via one" do

        it "just call `is_valid` not to mess with building events" do
          VALID_RANGE.is_valid( 'arbie' ).should eql false
          VALID_RANGE.is_valid( 'foobi' ).should eql true
        end

        it "`any_error_event_via_validate_x` for the \"via one\" mode" do
          x = VALID_RANGE.any_error_event_via_validate_x 'barbie'
          x.should be_nil
          ev = VALID_RANGE.any_error_event_via_validate_x 'Zee'
          ev.terminal_channel_i.should(
            eql :actual_property_is_outside_of_formal_property_set )
        end
      end
    end

    def subject * x_a
      Parent_::Subject_[].normalization.call_via_iambic x_a
    end
  end
  NIL_ = nil
end
