require_relative '../test-support'

module Skylab::Brazen::TestSupport::Entity

  describe "[br] entity meta-properties examples: required fields" do

    context "didactic" do

      before :all do

        MPER_Entity = Subject_[][ -> do
          o :meta_property, :parameter_arety, :entity_class_hook_once, -> cls do
            req = cls.properties.reduce_by( & :is_required ).to_a.freeze
            cls.add_iambic_event_listener :iamby_normalize_and_validate,
              -> obj do
                obj.whine_about_missin_reqd_fields req ; nil
              end
          end

          property_class_for_write
          class self::Property
            def initialize( * )
              @parameter_arety = nil
              super
            end
            def is_required
              :one == @parameter_arety
            end
          end
        end ]

        module MPER_Entity
          def whine_about_missin_reqd_fields prop_a
            a = prop_a.reduce [] do |m, x|
              instance_variable_defined?( x.as_ivar ) &&
                ! instance_variable_get( x.as_ivar ).nil? or m << x
              m
            end
            if a.length.nonzero?
              @missing = a.map( & :name_i )
            end ; nil
          end
        end

        class MPER_Business_Widget
          attr_reader :missing

          MPER_Entity[ self, -> do
            o :parameter_arety, :one, :property, :foo
            o :property, :bar
            o :parameter_arety, :one, :property, :baz
          end ]
        end
      end

      it 'ok' do
        obj = MPER_Business_Widget.new.send :with, :bar, :hi
        obj.send :notificate, :iamby_normalize_and_validate
        obj.instance_variable_get( :@bar ).should eql :hi
        obj.missing.should eql [ :foo, :baz ]
      end
    end
  end
end
