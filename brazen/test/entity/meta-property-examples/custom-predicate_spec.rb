require_relative '../../test-support'

Skylab::Brazen::TestSupport.lib_( :entity ).require_common_sandbox

module Skylab::Brazen::TestSupport::Entity_Sandbox

  describe "[br] entity meta-properties examples: customizing the.." do

    context "..property class w/ a boolean predicate & custom niladic writer" do

      before :all do

        MPEC_Entity = Subject_[].call do

          o :enum, [ :"0-1", :"1" ],

            :meta_property, :arety

          self::Property.class_exec do

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
