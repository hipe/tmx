require_relative '../test-support'

module Skylab::Brazen::TestSupport::Entity

  describe "[br] entity meta-properties examples: customizing the.." do

    context "..property class w/ a boolean predicate & custom niladic writer" do

      before :all do

        MPEC_Entity = Subject_[].call do

          o :enum, [ :"0-1", :"1" ],

            :meta_property, :arety

          entity_property_class_for_write

          class self::Entity_Property

            def is_necessary
              arety == :"1"
            end

          private

            def necessary=
              @arety = :"1"
              true
            end
          end
        end


        class MPEC_Business_Widget

          MPEC_Entity.call self do

            o :necessary

            def hi
            end

            def hey
            end

          end
        end
      end

      it "..can make property-based code arbitrarily more readable" do

        hi, hey = MPEC_Business_Widget.properties.each_value.to_a
        hi.is_necessary.should eql true
        hey.is_necessary.should eql false
      end
    end
  end
end
