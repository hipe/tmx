require_relative '../../test-support'

module Skylab::Fields::TestSupport

  describe "[fi] attributes - actor - normalizant integration" do  # :#cov2.10

    TS_[ self ]
    use :memoizer_methods
    use :want_event
    use :attributes

    # ==

      shared_subject :entity_class_ do

        class X_a_a_ni_NoSee

          Attributes::Actor.lib.call( self,
            starts_as_true: [ :default, true ],
            other: :required,
          )

          attr_reader :other, :starts_as_true
          self
        end
      end

      it "the default is applied when it should be" do
        o = entity_class_.with :other, :k
        expect( o.starts_as_true ).to eql true
        :k == o.other or fail
      end

      it "the default is not applied when it shouldn't be" do
        o = entity_class_.with :other, :k, :starts_as_true, false
        false == o.starts_as_true or fail
        :k == o.other or fail
      end

      context "emit a missing a required emission" do

        shared_subject :state_ do  # #open [#ts-049]

          _x = entity_class_.with( & event_log.handle_event_selectively )

          flush_event_log_and_result_to_state _x
        end

        it "fails (`with` results in false)" do
          want_this_other_false_or_nil_ state_.result
        end

        it "expresses" do

          _be_this = be_emission :error, :missing_required_attributes do |ev|
            _ = black_and_white ev
            want_missing_required_message_with_newline_ _, :other
          end

          expect( only_emission ).to _be_this
        end
      end
    # ==
  end
end
