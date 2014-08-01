require_relative '../test-support'

module Skylab::Brazen::TestSupport::Entity

  describe "[br] entity meta-properties examples: default.." do

    context "..has lots of moving parts actually" do

      before :all do

        MPED_Entity = Subject_[][ -> do
          o :meta_property, :defalt_proc,
              :entity_class_hook, -> prop, cls do
            cls.add_iambic_event_listener :iambuc_normalize_and_validate,
              -> obj do
                obj.aply_dflt_proc_if_necessary prop ; nil
              end
          end
        end ]

        module MPED_Entity
          def aply_dflt_proc_if_necessary prop
            ivar = :"#{ prop.as_ivar }_x"
            if ! instance_variable_defined? ivar ||
                instance_variable_get( ivar ).nil?
              instance_variable_set ivar, prop.defalt_proc.call
            end
          end
        end

        class MPED_Business_Widget

          attr_reader :mingle_x, :mongle_x

          MPED_Entity[ self, -> do
            hehe = 0
            o :defalt_proc, -> { "ohai: #{ hehe += 1 }" }
            def mingle
              @mingle_x = iambic_property
            end

            def mongle
              @mongle_x = iambic_property
            end
          end ]

          public :process_iambic_fully
        end
      end

      it "ok" do
        obj = MPED_Business_Widget.new
        obj.process_iambic_fully [ :mongle, :sure ]
        obj.notificate :iambuc_normalize_and_validate
        obj.mongle_x.should eql :sure
        obj.mingle_x.should eql "ohai: 1"
      end
    end
  end
end
