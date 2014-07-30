require_relative '../test-support'

module Skylab::Brazen::TestSupport::Entity

  describe "[br] entity meta-meta-properties: entity class hook once " do

    context "normative" do

      before :all do

        MMECHO_Entity = Subject_[][ -> do

          o :meta_property, :sensitive, :entity_class_hook_once, -> cls do
            cls.increment
            cls.thing = cls.properties.reduce_by( :sensitive ).map( & :name_i )
          end
        end ]

        class MMECHO_Business_Thing

          class << self
            d = 0
            define_method :increment do d += 1 end
            define_method :d do d end
            attr_accessor :thing
          end

          MMECHO_Entity[ self, -> do

            o :sensitive, true
            def foo
            end

            def bar
            end

            o :sensitive, nil
            def baz
            end
          end ]
        end
      end

      it "ok" do
        cls = MMECHO_Business_Thing
        cls.d.should eql 1
        cls.thing.should eql [ :foo, :baz ]
      end
    end
  end
end
