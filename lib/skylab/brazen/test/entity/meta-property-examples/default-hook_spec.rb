require_relative '../test-support'

module Skylab::Brazen::TestSupport::Entity

  describe "[br] entity meta-properties examples: default.." do

    context "..has lots of moving parts actually" do

      before :all do

        MPED_Entity = Subject_[].call do

          o :meta_property, :defolt_proc

          during_entity_normalize do |ent|
            ent.class.properties_with_defaults.each do |prop|
              x = ent.any_property_value prop
              if x.nil?
                _x = prop.defolt_proc[]
                prop_ = prop.new do  # meh #grease
                  @ivar = :"#{ as_ivar }_x"
                end
                ent.send :receive_value_of_entity_property, _x, prop_
              end
            end
            true
          end

          module self::Module_Methods
            def properties_with_defaults
              @properties_with_defaults ||= properties.reduce_by do |prop|
                ! prop.defolt_proc.nil?
              end.to_a.freeze
            end
          end
        end

        class MPED_Business_Widget

          attr_reader :mingle_x, :mongle_x

          MPED_Entity.call self do

            hehe = 0

            o :defolt_proc, -> do
              "ohai: #{ hehe += 1 }"
            end

            def mingle
              @mingle_x = iambic_property
            end

            def mongle
              @mongle_x = iambic_property
            end
          end

          Enhance_for_test_[ self ]
        end
      end

      it "ok" do
        ok = nil
        obj = MPED_Business_Widget.new do
          process_fully :mongle, :sure
          ok = normalize
        end
        obj.mongle_x.should eql :sure
        obj.mingle_x.should eql "ohai: 1"
      end
    end
  end
end
