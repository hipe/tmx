require_relative '../../test-support'

module Skylab::Fields::TestSupport

  TS_.require_ :attributes_actor  # #[#017]

  module Attributes::Actor

    TS_.describe "[fi] attributes - actor - normalizant integration" do

      TS_[ self ]
      use :memoizer_methods
      use :expect_event
      Here_[ self ]

      shared_subject :entity_class_ do

        class X_Nznt_A

          Subject_proc_[].call( self,
            starts_as_true: [ :default, true ],
            other: nil,
          )

          attr_reader :other, :starts_as_true
          self
        end
      end

      it "the default is applied when it should be" do
        o = entity_class_.new_with :other, :k
        o.starts_as_true.should eql true
        :k == o.other or fail
      end

      it "the default is not applied when it shouldn't be" do
        o = entity_class_.new_with :other, :k, :starts_as_true, false
        false == o.starts_as_true or fail
        :k == o.other or fail
      end

      context "emit a missing a required emission" do

        shared_subject :state_ do  # #open [#ts-049]

          _x = entity_class_.new_with( & event_log.handle_event_selectively )

          flush_event_log_and_result_to_state _x
        end

        it "fails (`new_with` results in false)" do
          false == state_.result or fail  # ..
        end

        it "expresses" do

          _exp = "missing required attribute 'other'"

          _be_this = be_emission :error, :missing_required_attributes do |ev|
            _ = black_and_white ev
            _.should eql _exp
          end

          only_emission.should _be_this
        end
      end
    end
  end
end
