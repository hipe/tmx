require_relative '../test-support'

module Skylab::Brazen::TestSupport::Entity

  describe "[br] entity meta-properties examples: customizing the.." do

    context "..property class w/ a boolean predicate & custom niladic writer" do

      before :all do

        MPEC_Entity = Subject_[][ -> do

          o :meta_property, :arety, :enum, [ :"0-1", :"1" ]

          property_class_for_write  # necessary to flush above and create below

          class self::Property
            def is_necessary
              arety == :"1"
            end

            o :iambic_writer_method_name_suffix, :'=' do
              def necessary=
                @arety = :"1"
              end
            end
          end
        end ]


        class MPEC_Business_Widget

          MPEC_Entity[ self, -> do

            o :necessary

            def hi
            end

            def hey
            end

          end ]
        end
      end

      it "..can make property-based code arbitrarily more readable" do
        hi, hey = MPEC_Business_Widget.properties.to_value_array
        hi.is_necessary.should eql true
        hey.is_necessary.should eql false
      end
    end
  end
end
