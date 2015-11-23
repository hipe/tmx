require_relative '../../test-support'

Skylab::Brazen::TestSupport.lib_( :entity ).require_common_sandbox

module Skylab::Brazen::TestSupport::Entity_Sandbox

  describe "[br] entity - models - property box" do

    # (no context)

      before :all do

        class M_PB_Hi

          Subject_[].call self,
            :properties, :foo, :bar

          # Enhance_for_test_[ self ]
        end
      end

      it "`to_mutable_box_like_proxy`" do

        prps = _subject
        bx = prps.to_mutable_box_like_proxy
        bx.a_.should eql [ :foo, :bar ]
        _foo = bx.remove :foo
        _foo.name_symbol.should eql :foo
        prps.get_names.should eql [ :foo, :bar ]
      end

      def _subject
        M_PB_Hi.properties
      end
  end
end
