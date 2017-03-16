require_relative '../../test-support'

module Skylab::Fields::TestSupport

  describe "[fi] entity - meta-meta-properties - mutate entity (ISLAND)" do  # :+[#sl-134]..

    TS_[ self ]
    use :memoizer_methods
    use :entity

    # define a meta-entity by what it does to the entity.
    #
    # .. this feature is an "island" - although it may seem useful (doesn't
    #    it?), it appears that this is used nowhere in production.)

    # ( the only context ) ->

      shared_subject :_subject_module do

        X_e_mmp_me_Entity = Entity.lib.call do

          o :mutate_entity, -> prp, scn do

              prp.wants_to_know = scn.gets_one
              KEEP_PARSING_
            end,

            :meta_property, :teach_me_how_to_dougie

          self::Property.send :attr_accessor, :wants_to_know
        end

        class X_e_mmp_me_Business_Widget

          X_e_mmp_me_Entity.call self do

            o :teach_me_how_to_dougie, true, :property, :hi
            o :property, :hey
          end

          self
        end
      end

      it "ok" do
        hi, hey = _subject_module.properties.each_value.to_a
        hi.wants_to_know.should eql true
        hey.wants_to_know.should eql nil
      end
    end
    # <-
end
