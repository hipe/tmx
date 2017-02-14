require_relative '../../test-support'

Skylab::Brazen::TestSupport.lib_( :entity ).require_common_sandbox

module Skylab::Brazen::TestSupport::Entity_Sandbox

  describe "[br] entity - meta-meta-properties - 3. mutate entity (ISLAND)" do  # :+[#sl-134]..

    # define a meta-entity by what it does to the entity.
    #
    # .. this feature is an "island" - although it may seem useful (doesn't
    #    it?), it appears that this is used nowhere in production.)

    # ( the only context ) ->

      before :all do

        MMPH_Entity = Subject_[].call do

          o :mutate_entity, -> prp, st do

              prp.wants_to_know = st.gets_one
              KEEP_PARSING_
            end,

            :meta_property, :teach_me_how_to_dougie

          self::Property.send :attr_accessor, :wants_to_know
        end

        class MMPH_Business_Widget

          MMPH_Entity.call self do

            o :teach_me_how_to_dougie, true, :property, :hi
            o :property, :hey
          end
        end
      end

      it "ok" do
        hi, hey = MMPH_Business_Widget.properties.each_value.to_a
        hi.wants_to_know.should eql true
        hey.wants_to_know.should eql nil
      end
    end
    # <-
end
