require_relative '../test-support'

module Skylab::Brazen::TestSupport::Entity

  describe "[br] entity meta-meta-properties: default", wip: true do

    context "uses an event hook" do

      before :all do

        class MMD_Foo

          attr_reader :foo, :bar, :baz

          Subject_[][ self, :iambic_writer_method_name_suffix, :"=", -> do

            o :meta_property, :importance, :default, 22

            o :importance, 10

            def foo=
              @foo = iambic_property
            end

            o :importance, 20

            def bar=
              @bar = iambic_property
            end

            def baz=
              @baz = iambic_property
            end

          end ]
        end
      end

      it "ok" do
        a = MMD_Foo.properties.each_value.to_a
        a.map( & :name_i ).should eql [ :foo, :bar, :baz ]
        a.map( & :importance ).should eql [ 10, 20, 22 ]
      end
    end
  end
end
