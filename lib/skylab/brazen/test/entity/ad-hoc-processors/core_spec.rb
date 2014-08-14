require_relative '../test-support'

module Skylab::Brazen::TestSupport::Entity

  describe "[br] entity ad-hoc processors" do

    context "for e.g a DSL extension that adds properties" do

      before :all do

        class AHP_Base

          Entity_ = Subject_[][ -> do
            o :ad_hoc_processor, :gazoink, -> x { Gazoink_.new( x ).go }
          end ]

        end

        class Gazoink_
          def initialize scn
            @scn = scn
          end
          def go
            @scn.advance_one  # skip name
            a = @scn.gets_one
            a.each do |i|
              @scn.reader.property_scope_krnl.add_monadic_property_via_i i
            end ; nil
          end
        end

        class AHP_Child < AHP_Base
          attr_reader :foo, :baz
          Entity_[ self, -> do
            o :iambic_writer_method_name_suffix, :'='
            def foo=
              @foo = iambic_property
            end
            o :gazoink, [ :bar, :baz ]
            def biff=
            end
          end ]
        end
      end

      it "reflects" do
        AHP_Child.properties.each_value.map( & :name_i ).
          should eql [ :foo, :bar, :baz, :biff ]
      end

      it "writes" do
        o = AHP_Child.new.send :with, :foo, :F, :baz, :B
        o.foo.should eql :F
        o.baz.should eql :B
      end
    end
  end
end
