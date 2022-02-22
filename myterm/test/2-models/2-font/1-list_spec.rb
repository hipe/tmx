require_relative '../../test-support'

module Skylab::MyTerm::TestSupport

  describe "[my] models - font - list" do

    TS_[ self ]
    use :my_API

    context "you can list the fonts when the adapter is engaged (LIVE)" do

      # NOTE - if this fails try regressing to sibling test file (2)

      fake_fonts_dir '005-fake-fonts-dir'

      call_by do
        call :adapter, COMMON_ADAPTER_CONST_,
          :background_font, :list
      end

      it "result is a stream of font entities." do
        expect( _tuple.length ).to eql 2
      end

      it "the fonts can express themselves textually (as items)" do

        font = __first_font
        s = ""
        oid = s.object_id
        _ = font.express_into_under s, expression_agent_for_want_emission
        expect( _.length ).to be_nonzero
        expect( _.object_id ).to eql oid
      end

      it "the fonts are flyweighted" do

        a = _tuple
        expect( a.fetch( 0 ).fetch( 0 ) ).to eql a.fetch( 1 ).fetch( 0 )
      end

      shared_subject :_tuple do

        st = root_ACS_result
        a = []
        x = st.gets
        if x
          a.push [ x.object_id, x.dup ]
        end
        x = st.gets
        if x
          a.push [ x.object_id, x ]
        end
        a
      end

      def __first_font
        _tuple.fetch( 0 ).fetch( 1 )
      end
    end
  end
end
# #history-B.1: target Ubuntu not OS X
