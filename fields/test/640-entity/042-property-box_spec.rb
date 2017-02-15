require_relative '../test-support'

module Skylab::Fields::TestSupport

  describe "[fi] entity - models - property box" do

    TS_[ self ]
    use :memoizer_methods
    use :entity

    # -

      it "`to_mutable_box_like_proxy`" do

        prps = _subject_module.properties
        bx = prps.to_mutable_box_like_proxy
        bx.a_.should eql [ :foo, :bar ]
        _foo = bx.remove :foo
        _foo.name_symbol.should eql :foo
        prps.get_keys.should eql [ :foo, :bar ]
      end

      def _subject
        _subject_module.properties
      end

      shared_subject :_subject_module do

        class X_e_pb_Hi
          Entity.lib.call self, :properties, :foo, :bar
          self
        end
      end

    # -
  end
end
