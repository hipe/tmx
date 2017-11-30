require_relative '../../test-support'

module Skylab::Fields::TestSupport

  describe "[fi] entity meta-properties examples: customizing the.." do

    TS_[ self ]
    use :memoizer_methods
    use :entity

    context "..property class w/ a boolean predicate & custom niladic writer" do

      shared_subject :_subject_module do

        X_e_mp_cpe_Entity = Entity.lib.call do

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

        class X_e_mp_cpe_Business_Widget

          X_e_mp_cpe_Entity.call self do

            o :necessary

            def hi
            end

            def hey
            end

          end

          self
        end
      end

      it "..can make property-based code arbitrarily more readable" do

        hi, hey = _subject_module.properties.each_value.to_a
        expect( hi.is_necessary ).to eql true
        expect( hey.is_necessary ).to eql false
      end
    end
  end
end
