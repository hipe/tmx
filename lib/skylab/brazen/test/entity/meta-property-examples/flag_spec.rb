require_relative '../test-support'

module Skylab::Brazen::TestSupport::Entity

  describe "[br] entity meta-properties examples: flag." do

    context "associate with a metaproperty a hook that the property.." do

      before :all do

        MPEF_Entity = Subject_[].call do

          entity_property_class_for_write
          class self::Entity_Property

            def initialize
              @arg_aruty = :one
              super
            end

            def is_florg
              :zero == @arg_aruty
            end

          private

            def florg=
              @arg_aruty = :zero
              add_to_write_proc_chain do |_PROP|
                -> do
                  receive_value_of_entity_property true, _PROP
                  true
                end
              end
              true
            end
          end
        end

        class MPEF_Business_Widget
          attr_reader :hi, :hey
          MPEF_Entity.call self do
            o :florg, :property, :hi
            o :property, :hey
          end

          Enhance_for_test_[ self ]
        end
      end

      it "add and write to fields to your property in the classic way" do
        hi, hey = MPEF_Business_Widget.properties.each_value.to_a
        hi.is_florg.should eql true
        hey.is_florg.should eql false
      end

      it "..and in this case set a custom 'iambic_writer_method_proc'." do
        ok = nil
        o = MPEF_Business_Widget.new do
          ok = process_fully :hi, :hey, :ho
        end

        o.hi.should eql true
        o.hey.should eql :ho
      end
    end
  end
end
