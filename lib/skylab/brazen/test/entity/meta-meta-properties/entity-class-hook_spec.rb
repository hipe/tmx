require_relative '../test-support'

module Skylab::Brazen::TestSupport::Entity

  describe "[br] entity meta-meta-properties: entity class hook.." do

    context "lets you alter the entity class in arbitrary ways when.." do

      before :all do

        MMECH_Entity = Subject_[][ -> do
          o :meta_property, :clandestine, :entity_class_hook, -> prop, cls do
            ( cls.clandestine_i_a ||= [] ).push prop.name_i ; nil
          end
        end ]

        class MMECH_Business_Thing

          class << self
            attr_accessor :clandestine_i_a
          end

          MMECH_Entity[ self, -> do
            o :clandestine, true
            def foo
            end

            def bar
            end

            o :clandestine, nil
            def baz
            end

            o :clandestine, true
            def bif
            end
          end ]
        end
      end

      it "to its properties it applies meta-properties with this m.m.property" do
        MMECH_Business_Thing.clandestine_i_a.should eql [ :foo, :bif ]
      end
    end
  end
end
