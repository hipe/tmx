require_relative '../test-support'

module Skylab::Brazen::TestSupport::Entity

  describe "[br] entity meta-meta-properties: default" do

    context "uses an event hook" do

      before :all do

        class MMD_Foo

          attr_reader :foo, :bar, :baz

          Subject_[].call self, :polymorphic_writer_method_name_suffix, :"=" do

            o :default, 22,
              :meta_property, :importance,

              :importance, 10

            def foo=
              @foo = gets_one_polymorphic_value
            end

            o :importance, 20

            def bar=
              @bar = gets_one_polymorphic_value
            end

            def baz=
              @baz = gets_one_polymorphic_value
            end

          end
        end
      end

      it "ok" do
        a = MMD_Foo.properties.each_value.to_a
        a.map( & :name_symbol ).should eql [ :foo, :bar, :baz ]
        a.map( & :importance ).should eql [ 10, 20, 22 ]
      end
    end
  end
end
