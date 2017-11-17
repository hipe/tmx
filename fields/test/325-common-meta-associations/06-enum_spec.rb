require_relative '../test-support'

module Skylab::Fields::TestSupport

  describe "[fi] CMA - enum" do  # :#cov2.3

    TS_[ self ]
    use :memoizer_methods
    use :want_event
    use :attributes_meta_associations

      context "(context)" do

        shared_subject :entity_class_ do
          class X_cma_Enum_A

            attrs = Attributes.lib.call(
              color: [ :enum, [ :red, :blue ] ],
            )

            ATTRIBUTES = attrs

            attr_reader :color

            self
          end
        end

        context "nope" do

          shared_subject :state_ do
            where_ :color, :green
          end

          it "fails (with nil)" do
            want_this_other_false_or_nil_ state_.result
          end

          it "emits" do

            _msg = "invalid attribute value 'green', expecting { red | blue }"

            _be_this = be_emission :error, :invalid_attribute_value do |ev|
              _ = black_and_white ev
              _.should eql _msg
            end

            only_emission.should _be_this
          end
        end

        context "yep" do

          shared_subject :state_ do
            where_ :color, :red
          end

          it "wins" do
            _x = state_.result
            :red == _x.color or fail
          end
        end
      end

    # ==
    # ==
  end
end
