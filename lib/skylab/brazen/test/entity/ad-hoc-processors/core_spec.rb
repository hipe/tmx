require_relative '../test-support'

module Skylab::Brazen::TestSupport::Entity

  describe "[br] entity ad-hoc processors" do

    context "for e.g a DSL extension that adds properties" do

      before :all do

        class AHP_Base
          Subject_[].call self do
            o :ad_hoc_processor, :gazoink, -> x { Gazoink_.new( x ).go }
          end
        end

        class Gazoink_
          def initialize pc
            @pc = pc
          end
          def go
            @pc.upstream.advance_one  # skip name
            a = @pc.upstream.gets_one
            a.each do |i|
              @pc.edit_session.property_related_nonterminal.finish_property_with_three(
                :do_define_method, :"#{ i }=", i )
            end
            true
          end
        end

        class AHP_Child < AHP_Base
          attr_reader :foo, :baz
          Subject_[].call self do
            o :polymorphic_writer_method_name_suffix, :'='
            def foo=
              @foo = gets_one_polymorphic_value
            end
            o :gazoink, [ :bar, :baz ]
            def biff=
            end
          end

          Enhance_for_test_[ self ]
        end
      end

      it "loads" do
      end

      it "reflects" do
        AHP_Child.properties.each_value.map( & :name_symbol ).
          should eql [ :foo, :bar, :baz, :biff ]
      end

      it "writes" do
        o = AHP_Child.with :foo, :F, :baz, :B
        o.foo.should eql :F
        o.baz.should eql :B
      end
    end
  end
end
