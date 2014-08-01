require_relative '../test-support'

module Skylab::Brazen::TestSupport::Entity

  describe "[br] entity meta-properties examples: flag: we can" do

    context "associate with a metaproperty a hook that the property.." do

      before :all do

        MPEF_Entity = Subject_[][ -> do

          o :meta_property, :arg_aruty, :default, :one,
            :property_hook, -> prop do
              if :zero == prop.arg_aruty
                ivar = prop.as_ivar
                prop.iambic_writer_method_proc = -> do
                  instance_variable_set ivar, true ; nil
                end
              end
            end

          property_class_for_write
          class self::Property

            def is_florg
              :zero == @arg_aruty
            end

            o :iambic_writer_method_name_suffix, :"=" do
              def florg=
                @arg_aruty = :zero
              end
            end
          end
        end ]

        class MPEF_Business_Widget
          attr_reader :hi, :hey
          MPEF_Entity[ self, -> do
            o :florg, :property, :hi
            o :property, :hey
          end ]
        end
      end

      it "..will pass thru iff that metaproperty value is true-ish.." do
        hi, hey = MPEF_Business_Widget.properties.to_value_array
        hi.is_florg.should eql true
        hey.is_florg.should eql false
      end

      it "..and in this case set a custom 'iambic_writer_method_proc'." do
        o = MPEF_Business_Widget.new.send :with, :hi, :hey, :ho
        o.hi.should eql true
        o.hey.should eql :ho
      end
    end
  end
end
