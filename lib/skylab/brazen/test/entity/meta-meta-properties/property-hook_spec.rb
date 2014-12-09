require_relative '../test-support'

module Skylab::Brazen::TestSupport::Entity

  describe "[br] entity meta-meta-properties: property hook", wip: true do

    context "happens when property is build before it is frozen." do

      before :all do

        MMPH_Entity = Subject_[][ -> do

          o :meta_property, :teach_me_how_to_dougie,
            :property_hook, -> prop do
              prop.wants_to_know = true
            end

          property_class_for_write
          class self::Property
            attr_accessor :wants_to_know
          end
        end ]

        class MMPH_Business_Widget
          MMPH_Entity[ self, -> do
            o :teach_me_how_to_dougie, true, :property, :hi
            o :property, :hey
          end ]
        end
      end

      it "ok" do
        hi, hey = MMPH_Business_Widget.properties.each_value.to_a
        hi.wants_to_know.should eql true
        hey.wants_to_know.should eql nil
      end
    end
  end
end
