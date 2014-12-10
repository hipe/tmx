require_relative '../test-support'

module Skylab::Brazen::TestSupport::Entity

  describe "[br] entity meta-properties examples: required fields" do

    context "didactic" do

      before :all do

        MPER_Entity = Subject_[].call do

          o :meta_property, :parameter_arety

          during_entity_normalize do |ent|
            miss_a = ent.class.requored_prop_a.reduce nil do | m, prop |
              ent.any_property_value_via_property( prop ).nil? and ( m ||= [] ).push prop.name_i
              m
            end
            if miss_a
              ent.missing = miss_a
              false
            else
              true
            end
          end

          module self::Module_Methods
            def requored_prop_a
              @requored_prop_a ||= properties.reduce_by( & :is_requored ).to_a.freeze
            end
          end

          entity_property_class_for_write
          class self::Entity_Property
            def initialize( * )
              @parameter_arety = nil
              super
            end
            def is_requored
              :one == @parameter_arety
            end
          end
        end

        class MPER_Business_Widget
          attr_accessor :missing

          MPER_Entity.call self do
            o :parameter_arety, :one, :property, :foo
            o :property, :bar
            o :parameter_arety, :one, :property, :baz
          end

          Enhance_for_test_[ self ]
        end
      end

      it 'ok' do

        ok = nil
        obj = MPER_Business_Widget.new do
          process_fully :bar, :hi
          ok = normalize
        end
        ok.should eql false
        obj.instance_variable_get( :@bar ).should eql :hi
        obj.missing.should eql [ :foo, :baz ]
      end
    end
  end
end
