require_relative '../../test-support'

module Skylab::Fields::TestSupport

  TS_.require_ :attributes_meta_attributes
  module Attributes::Meta_Attributes

    TS_.describe "[fi] attributes - meta-attributes - enum" do

      TS_[ self ]
      use :memoizer_methods
      use :expect_event

      context "(context)" do

        shared_subject :entity_class_ do
          class X_MA_Enum_A

            attrs = Subject_module_[].call(
              color: [ :enum, [ :red, :blue ] ],
            )

            ATTRIBUTES = attrs

            attr_reader :color

            self
          end
        end

        context "nope" do

          shared_subject :state_ do
            _where :color, :green
          end

          it "fails" do
            state_.result.should eql false
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
            _where :color, :red
          end

          it "wins" do
            _x = state_.result
            :red == _x.color or fail
          end
        end

        def _where * x_a

          cls = entity_class_

          _ent = cls.new

          _ = event_log.handle_event_selectively

          _x = cls::ATTRIBUTES.init _ent, x_a, & _

          flush_event_log_and_result_to_state _x
        end
      end
    end
  end
end
