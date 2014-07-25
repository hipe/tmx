require_relative 'test-support'

module Skylab::Brazen::TestSupport::Entity

  describe "[br] entity property" do

    context "minimal - the property name is not used for the parse method .." do

      before :all do

        class EP_Foo
          attr_reader :zig
          Subject_[][ self, -> do
            o :property, :zig
          end ]
        end
      end

      it "so you can create a reader with the same name as the property" do
        foo = EP_Foo.new.with :zig, :zag
        foo.zig.should eql :zag
      end
    end

    context "create arbitrary meta-properties and use them in the properties" do

      before :all do

        class EP_Bar
          Subject_[][ self, -> do
            o :meta_property, :fun_ness
            o :fun_ness, :really_fun, :property, :zag
          end ]

          attr_reader :zag
          public :with
        end
      end

      it "still works as a property ofc" do
        bar = EP_Bar.new.with :zag, :zig
        bar.zag.should eql :zig
      end

      it "reflect with your meta-properties" do
        EP_Bar.properties[ :zag ].fun_ness.should eql :really_fun
      end
    end
  end
end
