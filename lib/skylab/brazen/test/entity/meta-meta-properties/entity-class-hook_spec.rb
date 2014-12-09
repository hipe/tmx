require_relative '../test-support'

module Skylab::Brazen::TestSupport::Entity

  describe "[br] entity meta-meta-properties: entity class hook.." do

    context "lets you alter the entity class in arbitrary ways when.." do

      before :all do

        MMECH_Entity = Subject_[].call do


          o :entity_class_hook, -> parse_context do
              t_or_f = parse_context.upstream.gets_one
              @clandestine = t_or_f
              -> prop do
                if t_or_f
                  ( @clandestine_i_a ||= [] ).push prop.name_i
                end
                true
              end
            end,
          :meta_property, :clandestine

        end

        class MMECH_Business_Thing

          class << self
            attr_reader :clandestine_i_a
          end

          MMECH_Entity.call self do

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
          end
        end
      end

      it "to its properties it applies meta-properties with this m.m.property" do
        MMECH_Business_Thing.clandestine_i_a.should eql [ :foo, :bif ]
      end
    end
  end
end
